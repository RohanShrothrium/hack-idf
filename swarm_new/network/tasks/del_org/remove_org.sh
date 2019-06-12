#!/bin/bash

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
export CHANNEL_NAME=mychannel

echo $ORDERER_CA && echo $CHANNEL_NAME

#fetch config block from channel
peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

#decode a part of it to json
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > scripts/config.json

#get modified_config.json
node ./scripts/json.js 3 ./config.json ./scripts/before.json
jq "." ./scripts/before.json > ./scripts/modified_config.json
rm ./scripts/before.json

#get update and wrap it up in header
configtxlator proto_encode --input scripts/config.json --type common.Config --output config.pb
configtxlator proto_encode --input scripts/modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org${ORG}_update.pb
configtxlator proto_decode --input org${ORG}_update.pb --type common.ConfigUpdate | jq . > org${ORG}_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org${ORG}_update.json)'}}}' | jq . > org${ORG}_update_in_envelope.json
configtxlator proto_encode --input org${ORG}_update_in_envelope.json --type common.Envelope --output org${ORG}_update_in_envelope.pb

#sign the update transaction
peer channel signconfigtx -f org${ORG}_update_in_envelope.pb

#change identity of cli to peer0.org2
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

peer channel update -f org${ORG}_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA