# exchange-deposits

## Overview

The EOSIO V1 history plugin is widely used to receiving Telos token deposits into centralised system such as an exchange. The V1 history plugin was depricated in 2018 but continues to be shipped with the EOSIO software (presumably because it is useful in development). The plugin is prone to corruption and requires a full replay of the blockchain when new protocol features are activated making it unsuitable for production environments.

This contract provides an alternative approach to receiving deposits. When deployed to an account it records all deposits in a deposits table. The table contains all fields needed by downstream systems. The contract requires only that a Telos API server be deployed or a trusted API point be utilised. A Telos API server can be initialised using a snapshot making it substainially quicker to deploy and significantly lighter on resource than a full V1 history node.

## How it works

The contract intercepts transfer notification events on it's host account, validates the transfer details and writes the details to a deposits table. The table resides in memory which is billed to the host account. Actions are provided to manage which deposits are accepted and to free up account memory as records are no longer needed in the table. The account will not be able to accept deposits if all RAM allocated to the account is consumed.

## Features

* Only accept deposits of whitelisted tokens. A minimum limit can be set on whitelisted tokens preventing the account from being spammed by small transactions. Deposits below the minimum limit wo whitelisetd tokens and non-whitelisted tokens are rejected.
* The contract can be used to receive multiple Telos tokens in the same account. Each token has its own deposits table.
* The deposits table consumes 199 bytes of RAM per row. Over time it will become necessary to release this RAM. Once deposits are processed by downstream processes they can be removed from the deposits table, freeing up RAM for new deposits.
* The contract can refund a deposit if the recipient chooses not to receive it. The tokens are refunded to the account who originally sent them.

## Actions

### addwhitelist ["contract", "minimum_deposit"]

This action adds a token to the deposits account whitelist. It requires the following parameters;
* contract - the token contract account, eg. "eosio.token" for TLOS
* minimum_deposit - the minimum allowed deposit. eg. "10.0000 TLOS" for TLOS

### setwhitelist ["symbol", "enabled"]

This action enables / disables deposits for a specified token. If deposits are disabled all transfers to the deposit account will fail. It requires the following parameters;
* symbol - Token symbok, eg. "TLOS"
* enabled - 1 (enabled) / 0 (disabled)

### removewlist ["symbol"]

This action permenently remove a token from the whitelist. It requires the following parameter;
* symbol - Token symbol, eg. "TLOS"

### cleardeposit ["symbol", "deposit_id"]

This action clears a deposit record from the deposits table. The deposit records for each whitelisted token are stored in their own scope (partitioned by token code). A deposit record is identified by symbol and deposit_id;
* symbol - Token symbol, eg. "TLOS"
* deposit_id - Autoincremented deposit id automatically added to the deposit record on creation

### refund ["symbol", "deposit_id"]

This action reverses a deposit transaction, returning tokens to the account that sent them. The deposit records for each whitelisted token are stored in their own scope (partitioned by token code). A deposit record is identified by symbol and deposit_id;
* symbol - Token symbol, eg. "TLOS"
* deposit_id - Autoincremented deposit id automatically added to the deposit record on creation

## Whitelist table structure

This contract only accepts deposits from whitelisted tokens. The whitelist table is also used to store the deposit id autoincrement counter and to enable / disable depisits.

| Field | Type | Description |
| --- |:---:| ---|
| deposit_num | uint64_t | An autoincrement counter used to populate the deposit id of the deposit record for this token |
| contract | name | The contract account of the token |
| minimum_deposit | asset | The minimum value and symbol of the whitelisted token |
| enabled | bool | Token deposits enabled (1) or disabled (0) |

## Deposit table structure

The deposits table is created using the deposits account as the table code and the symbol code as the deposit scope. This results in deposits on tokens being partitioned by token code.

| Field | Type | Description |
| --- |:---:| ---|
| deposit_id | uint64_t | A unique autoincremented sequence number for the deposit |
| timestamp | time_point_sec | The block time for the block containing the deposit |
| from | name | The name of the account who sent the deposit |
| quantity | asset | The deposit value comprising quantity and token symbol |
| memo | string | The original transfer memo |
| block_num | uint64_t | The block containing the deposit transfer transaction |
| trxid | checksum256 | The transaction id (hash) of the deposits transfer transaction |

## How to deploy the contract

Still to be completed.

## How to use the contract

### Whitelist a token

The commandline needed to add TLOS to the whitelist with no minimum limit is shown below.
```commandline
DEPOSITS="your deposit account name"
cleos push action $DEPOSITS addwhitelist '[ "eosio.token", "0.0000 TLOS" ]' -p $DEPOSITS@active
```
A custom Telos token (MYTOKEN) is whitelisted with a minimum deposit limit (of 50.0000 MYTOKEN) as follows.
```commandline
DEPOSITS="your deposit account name"
CUSTOMTOKEN="my custom token"
cleos push action $DEPOSITS addwhitelist '[ "'${CUSTOMTOKEN}'", "50.0000 MYTOKEN" ]' -p $DEPOSITS@active
```
Whitelisted tokens may be listed using
```commandline
DEPOSITS="your deposit account name"
TOKENSYMBOL="your token symbol"
cleos get table $DEPOSITS $TOKENSYMBOL deposits
```
**example**
```commandline
$ cleos get table deposits deposits whitelists

{
  "rows": [{
      "deposit_num": 3,
      "contract": "eosio.token",
      "minimum_deposit": "0.0000 TLOS"
    }
  ],
  "more": false
}
```

### List all deposits

```commandline
DEPOSITS="your deposit account name"
TOKENSYMBOL="your token symbol"
cleos get table $DEPOSITS $TOKENSYMBOL deposits
```
**example**
```commandline
$ cleos get table deposits TLOS deposits

{
  "rows": [{
      "deposit_id": 2,
      "timestamp": "2020-02-02T13:12:53",
      "from": "testuser1",
      "quantity": "55.0000 TLOS",
      "memo": "1234567890",
      "block_num": 17,
      "trxid": "f06e03cba2907990840083be44767bcd3dd9f6dfc67356d7949a397d485f9c52"
    },{
      "deposit_id": 3,
      "timestamp": "2020-02-02T13:12:53",
      "from": "testuser1",
      "quantity": "15.0000 TLOS",
      "memo": "1234567890",
      "block_num": 17,
      "trxid": "7e074acf2fb301e8b101502b53091dd460888f1956492c3ebfe4c4920e37c131"
    }
  ],
  "more": false
}
```

### Clear a deposit record