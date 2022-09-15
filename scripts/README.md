## Note on using these scripts

These scripts contain absolute paths to folders required to run nodeos and access the exchange-deposits contract. Edit the paths in these scripts to suit your local environment.

MY_CONTRACTS_BUILD="/Users/rory/TCD/exchange-deposits"
CONTRACT="exchange-deposits"
ACCOUNT="zartknissuer"

# Bacup existing wasm
# cleos ${API} get code zartknissuer -c zartknissuer.wasm -a zartknissuer.abi --wasm

# Deploy contracts
cleos $API set contract ${ACCOUNT} ${MY_CONTRACTS_BUILD}/${CONTRACT}/
