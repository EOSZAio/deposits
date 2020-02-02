#!/usr/bin/env bash
#=================================================================================#
# Config Constants

clear
./compile_exchange-deposits.sh
echo
./restart.sh

sleep 1

CYAN='\033[1;36m'
GREEN='\033[0;32m'
NC='\033[0m'

# CHANGE PATH
EOSIO_CONTRACTS_ROOT=~/eosio.contracts/build/contracts
MY_CONTRACTS_BUILD=~/TCD/exchange-deposits

NODEOS_HOST="127.0.0.1"
NODEOS_PROTOCOL="http"
NODEOS_PORT="8888"
NODEOS_LOCATION="${NODEOS_PROTOCOL}://${NODEOS_HOST}:${NODEOS_PORT}"

# temp keosd setup
WALLET_DIR=/tmp/temp-eosio-wallet
UNIX_SOCKET_ADDRESS=$WALLET_DIR/keosd.sock
WALLET_URL=unix://$UNIX_SOCKET_ADDRESS

function cleos() { command cleos --url=${NODEOS_LOCATION} --wallet-url=$WALLET_URL "$@"; echo $@; }
on_exit(){
  echo -e "${CYAN}cleaning up temporary keosd process & artifacts${NC}";
  kill -9 $TEMP_KEOSD_PID &> /dev/null
  rm -r $WALLET_DIR
}

trap my_trap INT
trap my_trap SIGINT

# start temp keosd
mkdir $WALLET_DIR
keosd --wallet-dir=$WALLET_DIR --unix-socket-path=$UNIX_SOCKET_ADDRESS &> /dev/null &
TEMP_KEOSD_PID=$!
sleep 1

# create temp wallet
cleos wallet create --to-console

DEPOSITS_PUB="EOS8HuvjfQeUS7tMdHPPrkTFMnEP7nr6oivvuJyNcvW9Sx5MxJSkZ"
DEPOSITS_PRV="5JS9bTWMc52HWmMC8v58hdfePTxPV5dd5fcxq92xUzbfmafeeRo"

COOL_PUB="EOS833HgCT3egUJRDnW5k3BQGqXAEDmoYo6q1s7wWnovn6B9Mb1pd"
COOL_PRV="5JFLPVygcZZdEno2WWWkf3fPriuxnvjtVpkThifYM5HwcKg6ndu"

FAKECOOL_PUB="EOS77s45YiM8xhq7MWxuTdERBDn3ntHG8DTtcdwNVR2Srhxg5SZk7"
FAKECOOL_PRV="5HrFtXh3ycvp2rSrpJb6bHJimB14adD6WXuQW4LnXA5posqpfAG"

USR_PUB="EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u"
USR_PRV="5JKAjH9WH4XnZCEe8v5Wir7awV4YBTVa8KUSqWJbQR6QGtj4yce"

#PAYFEE_PUB="EOS7pscBeDbJTNn5SNxxowmWwoM7hGj3jDmgxp5KTv7gR89Ny5ii3"
#PAYFEE_PRV="5KgKxmnm8oh5WbHC4jmLARNFdkkgVdZ389rdxwGEiBdAJHkubBH"

echo

# EOSIO system-related keys
echo -e "${CYAN}---------------------------SYSTEM KEYS---------------------------${NC}"
cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
cleos wallet import --private-key 5JgqWJYVBcRhviWZB3TU1tN9ui6bGpQgrXVtYZtTG2d3yXrDtYX
cleos wallet import --private-key 5JjjgrrdwijEUU2iifKF94yKduoqfAij4SKk6X5Q3HfgHMS4Ur6
cleos wallet import --private-key 5HxJN9otYmhgCKEbsii5NWhKzVj2fFXu3kzLhuS75upN5isPWNL
cleos wallet import --private-key 5JNHjmgWoHiG9YuvX2qvdnmToD2UcuqavjRW5Q6uHTDtp3KG3DS
cleos wallet import --private-key 5JZkaop6wjGe9YY8cbGwitSuZt8CjRmGUeNMPHuxEDpYoVAjCFZ
cleos wallet import --private-key 5Hroi8WiRg3by7ap3cmnTpUoqbAbHgz3hGnGQNBYFChswPRUt26
cleos wallet import --private-key 5JbMN6pH5LLRT16HBKDhtFeKZqe7BEtLBpbBk5D7xSZZqngrV8o
cleos wallet import --private-key 5JUoVWoLLV3Sj7jUKmfE8Qdt7Eo7dUd4PGZ2snZ81xqgnZzGKdC
cleos wallet import --private-key 5Ju1ree2memrtnq8bdbhNwuowehZwZvEujVUxDhBqmyTYRvctaF
cleos wallet import --private-key 5JsRjdLbvRKGDKpVLsKuQr57ksLf4B8bpQEVFb5D1rDiPievt88
cleos wallet import --private-key 5J3JRDhf4JNhzzjEZAsQEgtVuqvsPPdZv4Tm6SjMRx1ZqToaray
echo
echo -e "${CYAN}--------------------------DEPOSITS KEYS--------------------------${NC}"
cleos wallet import --private-key $DEPOSITS_PRV
cleos wallet import --private-key $COOL_PRV
cleos wallet import --private-key $FAKECOOL_PRV
cleos wallet import --private-key $USR_PRV

#cleos wallet import --private-key $CLAIM_PRV
#cleos wallet import --private-key $PAYFEE_PRV

# Create system accounts
echo
echo -e "${CYAN}-------------------------SYSTEM ACCOUNTS-------------------------${NC}"
cleos create account eosio eosio.bpay EOS7gFoz5EB6tM2HxdV9oBjHowtFipigMVtrSZxrJV3X6Ph4jdPg3
cleos create account eosio eosio.msig EOS6QRncHGrDCPKRzPYSiWZaAw7QchdKCMLWgyjLd1s2v8tiYmb45
cleos create account eosio eosio.names EOS7ygRX6zD1sx8c55WxiQZLfoitYk2u8aHrzUxu6vfWn9a51iDJt
cleos create account eosio eosio.ram EOS5tY6zv1vXoqF36gUg5CG7GxWbajnwPtimTnq6h5iptPXwVhnLC
cleos create account eosio eosio.ramfee EOS6a7idZWj1h4PezYks61sf1RJjQJzrc8s4aUbe3YJ3xkdiXKBhF
cleos create account eosio eosio.saving EOS8ioLmKrCyy5VyZqMNdimSpPjVF2tKbT5WKhE67vbVPcsRXtj5z
cleos create account eosio eosio.stake EOS5an8bvYFHZBmiCAzAtVSiEiixbJhLY8Uy5Z7cpf3S9UoqA3bJb
cleos create account eosio eosio.token EOS7JPVyejkbQHzE9Z4HwewNzGss11GB21NPkwTX2MQFmruYFqGXm
cleos create account eosio eosio.vpay EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio eosio.rex EOS5tjK2jP9jAd4zUe7DG1SCFGQW95W2KbXcYxg3JSu8ERjyZ6VRf

echo
#sleep 1

# Bootstrap new system contracts
echo -e "${CYAN}-----------------------SYSTEM CONTRACTS-----------------------${NC}"
cleos set contract eosio.token $EOSIO_CONTRACTS_ROOT/eosio.token/
cleos set contract eosio.msig $EOSIO_CONTRACTS_ROOT/eosio.msig/
cleos push action eosio.token create '[ "eosio", "100000000000.0000 TLOS" ]' -p eosio.token
echo -e "      TLOS TOKEN CREATED"
cleos push action eosio.token issue '[ "eosio", "10000000000.0000 TLOS", "Genesis tokens" ]' -p eosio
echo -e "      TLOS TOKEN ISSUED"
cleos set contract eosio $EOSIO_CONTRACTS_ROOT/eosio.bios/
echo -e "      BIOS SET"
cleos set contract eosio $EOSIO_CONTRACTS_ROOT/eosio.system/
echo -e "      SYSTEM SET"
cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio@active
cleos push action eosio init '[0, "4,TLOS"]' -p eosio@active

#cleos set abi eosio.rex $EOSIO_CONTRACTS_ROOT/eosio.system/.rex/rex.results.abi

echo
#sleep 1

# Deploy eosio.wrap
echo -e "${CYAN}-----------------------EOSIO WRAP-----------------------${NC}"
cleos system newaccount eosio eosio.wrap EOS7LpGN1Qz5AbCJmsHzhG7sWEGd9mwhTXWmrYXqxhTknY2fvHQ1A --stake-cpu "50 TLOS" --stake-net "10 TLOS" --buy-ram-kbytes 50 --transfer
cleos push action eosio setpriv '["eosio.wrap", 1]' -p eosio@active
cleos set contract eosio.wrap $EOSIO_CONTRACTS_ROOT/eosio.wrap/

echo
#sleep 1

echo -e "${CYAN}----------------ACTIVATE 1.8 PROTOCOL FEATURES----------------${NC}"
cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio # GET_SENDER
cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio # FORWARD_SETCODE
cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio # ONLY_BILL_FIRST_AUTHORIZER
cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio # RESTRICT_ACTION_TO_SELF
cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio # DISALLOW_EMPTY_PRODUCER_SCHEDULE
cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio # FIX_LINKAUTH_RESTRICTION
cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio # REPLACE_DEFERRED
cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio # NO_DUPLICATE_DEFERRED_ID
cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio # ONLY_LINK_TO_EXISTING_PERMISSION
cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio # RAM_RESTRICTIONS

echo
#sleep 1
echo -e "${CYAN}-----------------------CONTRACTS ACCOUNTS------------------------${NC}"
DEPOSITS="deposits"
TESTUSER1="testuser1"
TESTUSER2="testuser2"
COOL="thecooltoken"
FAKECOOL="fakecooltken"

cleos system newaccount eosio ${DEPOSITS} $DEPOSITS_PUB --stake-cpu "5 TLOS" --stake-net "1 TLOS" --buy-ram-kbytes 500 --transfer
cleos system newaccount eosio ${COOL} $COOL_PUB --stake-cpu "5 TLOS" --stake-net "1 TLOS" --buy-ram-kbytes 250 --transfer
cleos system newaccount eosio ${FAKECOOL} $FAKECOOL_PUB --stake-cpu "5 TLOS" --stake-net "1 TLOS" --buy-ram-kbytes 250 --transfer
cleos system newaccount eosio ${TESTUSER1} $USR_PUB --stake-cpu "5 TLOS" --stake-net "1 TLOS" --buy-ram-kbytes 5 --transfer
cleos system newaccount eosio ${TESTUSER2} $USR_PUB --stake-cpu "5 TLOS" --stake-net "1 TLOS" --buy-ram-kbytes 5 --transfer

echo
#sleep 1
echo -e "${CYAN}-----------------------DEPLOYING CONTRACTS-----------------------${NC}"
cleos set contract ${DEPOSITS} $MY_CONTRACTS_BUILD/exchange-deposits
cleos set contract ${COOL} $EOSIO_CONTRACTS_ROOT/eosio.token/
cleos set contract ${FAKECOOL} $EOSIO_CONTRACTS_ROOT/eosio.token/

echo
echo -e "${CYAN}-------------------------SET PERMISSIONS-------------------------${NC}"
cleos set account permission ${DEPOSITS} active '{ "threshold": 1, "keys": [{ "key": "'$DEPOSITS_PUB'", "weight": 1 }], "accounts": [{ "permission": { "actor":"'${DEPOSITS}'","permission":"eosio.code" }, "weight":1 }] }' owner -p ${DEPOSITS}

echo
echo -e "${CYAN}--------------------------OTHER TOKENS---------------------------${NC}"
cleos push action ${COOL} create '[ "'${COOL}'", "1000000.0000 COOL" ]' -p ${COOL}
cleos push action ${COOL} issue '[ "'${COOL}'", "1000000.0000 COOL", "Genesis tokens" ]' -p ${COOL}

cleos push action ${FAKECOOL} create '[ "'${FAKECOOL}'", "1000000.0000 COOL" ]' -p ${FAKECOOL}
cleos push action ${FAKECOOL} issue '[ "'${FAKECOOL}'", "1000000.0000 COOL", "Genesis tokens" ]' -p ${FAKECOOL}

echo
echo -e "${CYAN}-------------------------FUND TEST USER--------------------------${NC}"
# Transfer to testuser1
cleos push action eosio.token transfer '[ "eosio", "'${TESTUSER1}'", "1000.0000 TLOS", "Initial test tokens" ]' -p eosio@active
cleos push action ${COOL} transfer '[ "'${COOL}'", "'${TESTUSER1}'", "1000.0000 COOL", "Initial test tokens" ]' -p ${COOL}
cleos push action ${FAKECOOL} transfer '[ "'${FAKECOOL}'", "'${TESTUSER1}'", "1000.0000 COOL", "Initial test tokens" ]' -p ${FAKECOOL}
# Transfer to testuser2
cleos push action eosio.token transfer '[ "eosio", "'${TESTUSER2}'", "1000.0000 TLOS", "Initial test tokens" ]' -p eosio@active

echo
echo -e "${CYAN}-------------------------PREP DEPOSITS---------------------------${NC}"
cleos push action ${DEPOSITS} addwhitelist '[ "eosio.token", "0.0000 TLOS" ]' -p ${DEPOSITS}@active
cleos push action ${DEPOSITS} addwhitelist '[ "thecooltoken", "50.0000 COOL" ]' -p ${DEPOSITS}@active
echo -e "${GREEN}This should fail, fakeaccount does not exist${NC}"
cleos push action ${DEPOSITS} addwhitelist '[ "fakeaccount", "50.0000 COOL" ]' -p ${DEPOSITS}@active

echo
echo -e "${CYAN}-------------------------TEST DEPOSITS---------------------------${NC}"
echo -e "${GREEN}Should allow deposits of TLOS, prevent deposits of COOL${NC}"
cleos push action ${DEPOSITS} setwhitelist '[ "COOL", 0 ]' -p ${DEPOSITS}@active

cleos push action eosio.token transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "25.0000 TLOS", "1234567890" ]' -p ${TESTUSER1}@active
cleos push action eosio.token transfer '[ "'${TESTUSER2}'", "'${DEPOSITS}'", "25.0000 TLOS", "0987654321" ]' -p ${TESTUSER2}@active
cleos push action eosio.token transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "55.0000 TLOS", "1234567890" ]' -p ${TESTUSER1}@active
cleos push action eosio.token transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "15.0000 TLOS", "1234567890" ]' -p ${TESTUSER1}@active

echo -e "${GREEN}This should fail, COOL deposits disabled${NC}"
cleos push action ${COOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "15.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active
echo -e "${GREEN}This should fail, COOL deposits disabled${NC}"
cleos push action ${COOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "75.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active

echo -e "${GREEN}Should allow deposits of TLOS and COOL${NC}"
cleos push action ${DEPOSITS} setwhitelist '[ "COOL", 1 ]' -p ${DEPOSITS}@active

cleos push action eosio.token transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "95.0000 TLOS", "1234567890" ]' -p ${TESTUSER1}@active

echo -e "${GREEN}This should fail, minimum deposit 50.0000 COOL${NC}"
cleos push action ${COOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "15.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active
cleos push action ${COOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "50.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active
cleos push action ${COOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "75.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active

echo -e "${GREEN}This should fail, ${FAKECOOL} not whitelisted${NC}"
cleos push action ${FAKECOOL} transfer '[ "'${TESTUSER1}'", "'${DEPOSITS}'", "15.0000 COOL", "1234567890" ]' -p ${TESTUSER1}@active

echo
echo -e "${CYAN}-----------------------WHITELISTED TOKENS------------------------${NC}"
cleos get table deposits deposits whitelists
echo
echo -e "${CYAN}--------------------------TLOS DEPOSITS--------------------------${NC}"
cleos get table deposits TLOS deposits
echo
echo -e "${CYAN}--------------------------COOL DEPOSITS--------------------------${NC}"
cleos get table deposits COOL deposits
echo
echo -e "${CYAN}-----------------------------------------------------------------${NC}"

cleos push action ${DEPOSITS} cleardeposit '[ "TLOS", 1 ]' -p ${DEPOSITS}@active

echo -e "${GREEN}This should fail, cannot remove whitelisted token while there are entries in the deposits table for that token${NC}"
cleos push action ${DEPOSITS} removewlist '[ "COOL" ]' -p ${DEPOSITS}@active
cleos push action ${DEPOSITS} cleardeposit '[ "COOL", 1 ]' -p ${DEPOSITS}@active
cleos push action ${DEPOSITS} refund '[ "COOL", 2 ]' -p ${DEPOSITS}@active
cleos push action ${DEPOSITS} removewlist '[ "COOL" ]' -p ${DEPOSITS}@active

echo
echo -e "${CYAN}-----------------------WHITELISTED TOKENS------------------------${NC}"
cleos get table deposits deposits whitelists
echo
echo -e "${CYAN}--------------------------TLOS DEPOSITS--------------------------${NC}"
cleos get table deposits TLOS deposits
echo
echo -e "${CYAN}--------------------------COOL DEPOSITS--------------------------${NC}"
cleos get table deposits COOL deposits
echo
echo -e "${CYAN}-----------------------------------------------------------------${NC}"

# for i in {1..3}
# do
#    echo -e "${CYAN}#${i}${NC}"
#    echo cleos push transaction testuser1.json -p ${COOL}@payfee testuser1
#    cleos push transaction testuser1.json -p ${COOL}@payfee testuser1 > trx.log
#    echo cleos push transaction testuser2.json -p ${COOL}@payfee testuser2
#    cleos push transaction testuser2.json -p ${COOL}@payfee testuser2 > trx.log
#    echo cleos push transaction testuser3.json -p ${COOL}@payfee testuser3
#    cleos push transaction testuser3.json -p ${COOL}@payfee testuser3 > trx.log
# #   cleos push action ${COOL} payfee '[ "testuser1", "1.0000 COOL", "Transaction fee paid using COOL token" ]' -p ${COOL}@payfee testuser1
# #   cleos push action ${COOL} payfee '[ "testuser2", "1.0000 COOL", "Transaction fee paid using COOL token" ]' -p ${COOL}@payfee testuser2
# #   cleos push action ${COOL} payfee '[ "testuser3", "1.0000 COOL", "Transaction fee paid using COOL token" ]' -p ${COOL}@payfee testuser3
#    sleep 0.5
# done

on_exit
echo -e "${GREEN}--> Done${NC}"
