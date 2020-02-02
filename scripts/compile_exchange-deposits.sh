#!/bin/bash
shopt -s expand_aliases
source ~/.bash_profile

GREEN='\033[0;32m'
NC='\033[0m'

# Edit this path to point to the folder holding the exchange-deposits contract
MY_CONTRACTS_ROOT=~/TCD/exchange-deposits

declare -a contracts=("exchange-deposits")
for contract in "${contracts[@]}"
do
    cd $MY_CONTRACTS_ROOT
    echo -e "${GREEN}Compiling $contract...${NC}"
    echo eosio-cpp -abigen -I $contract/include -contract $contract -o $contract/$contract.wasm $contract/src/$contract.cpp
    eosio-cpp -abigen -I $contract/include -contract $contract -o $contract/$contract.wasm $contract/src/$contract.cpp
done
