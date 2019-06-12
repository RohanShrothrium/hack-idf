#!/bin/bash
export ORG=6
export port1=17051
export port2=18051

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CHANNEL_NAME=mychannel
export CORE_PEER_LOCALMSPID="Org${ORG}MSP"
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/msp

# change cli identity as peer0.org${ORG} 
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${ORG}.example.com/peers/peer0.org${ORG}.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=peer0.org${ORG}.example.com:${port1}

# get the channel block and join the channel
peer channel fetch 0 mychannel.block -o orderer0.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
peer channel join -b mychannel.block
echo "================Peer0.org${ORG} joined the channel================"
# install chaincode
peer chaincode install -n simple -v 1.0 -p github.com/chaincode
echo "==============Installed chaincode on Peer0.org${ORG}=============="

#change your identity as peer1.org${ORG}
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${ORG}.example.com/peers/peer1.org${ORG}.example.com/tls/ca.crt 
export CORE_PEER_ADDRESS=peer1.org${ORG}.example.com:${port2}
peer channel join -b mychannel.block
echo "================Peer1.org${ORG} joined the channel================"
# install chaincode
peer chaincode install -n simple -v 1.0 -p github.com/chaincode/
echo "==============Installed chaincode on Peer1.org${ORG}=============="

# Query chaincode
echo
echo "===============Querying chaincode on Peer1.org${ORG}=============="
peer chaincode query -C $CHANNEL_NAME -n simple -c '{"Args":["query","a"]}'