#!/bin/bash
export PATH=$PATH:$PWD/bin
# export ORG=6
cd org$ORG
cryptogen generate --config=./org${ORG}-crypto.yaml
mv -R crypto-config/peerOrganizations/org6.example.com/ /var/mynetwork/certs/crypto-config/peerOrganizations/
cd ..
# print the org info in a json
# this info will be added in the channel config transaction
# fabric cfg path is where the configtx.yaml file is
export FABRIC_CFG_PATH=$PWD/org${ORG}
configtxgen -printOrg Org${ORG}MSP > /var/mynetwork/certs/scripts/org${ORG}.json