#!/usr/bin/env bash
shopt -s expand_aliases
source ~/.bash_profile

GREEN='\033[0;32m'
NC='\033[0m'

EOSIO_CONTRACTS_ROOT=~/eosio.contracts/contracts

cd $EOSIO_CONTRACTS_ROOT
# cd ./eosio.token
# eosio-cpp -abigen -I include -contract eosio.token -o eosio.token.wasm src/eosio.token.cpp

declare -a contracts=("eosio.bios" "eosio.msig" "eosio.system" "eosio.token" "eosio.wrap")
for contract in "${contracts[@]}"
do
    echo -e "${GREEN}Compiling $contract...${NC}"
    echo eosio-cpp -abigen -I $contract/include -contract $contract -o $contract/$contract.wasm $contract/src/$contract.cpp
    eosio-cpp -abigen -I $contract/include -contract $contract -o $contract/$contract.wasm $contract/src/$contract.cpp
    cd $EOSIO_CONTRACTS_ROOT
done
