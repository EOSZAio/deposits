#pragma once

#include <eosio/asset.hpp>
#include <eosio/system.hpp>
#include <eosio/eosio.hpp>
#include <eosio/crypto.hpp>

#include <string>

namespace eosiosystem {
    class system_contract;
}

namespace eosio {

    using std::string;

    /**
     * exchange-deposits contract records deposits received by an account in a deposits table. This is offered as an alternative to using the nodeos V1 history plugin.
     */
    class [[eosio::contract("exchange-deposits")]] exchange : public contract {
    public:
        using contract::contract;

        /**
         * @brief whitelist a token
         * @details this action adds a token to the token whitelist. the contract only accepts deposits of whitelisted tokens.
         * @param contract
         * @param minimum_deposit
         */
        [[eosio::action]]
        void addwhitelist( const name& contract, const asset& minimum_deposit );

        /**
         * @brief enable / disable whitelisted token
         * @details this action enables and disables a token that is already in the whitelist
         * @param symbol
         * @param enabled
         */
        [[eosio::action]]
        void setwhitelist( const symbol_code& symbol, const bool& enabled );

        /**
         * @brief remove a token from the whitelist
         * @details this action removes a token from the token whitelist.
         * @param symbol
         */
        [[eosio::action]]
        void removewlist( const symbol_code& symbol );

        /**
         * @brief remove a depisit record from the deposits table
         * @details this action removes a deposit record from the deposits table and frees the RAM used by that record
         * @param deposit_id
         */
        [[eosio::action]]
        void cleardeposit ( const symbol_code& symbol, const uint64_t& deposit_id);

        /**
         * @brief reverse a deposit
         * @details this action will refund a deposit
         * @param deposit_id
         */
        [[eosio::action]]
        void refund ( const symbol_code& symbol,
                      const uint64_t& deposit_id,
                      const std::string& memo );


        /**
         * @brief intercepts transfers
         * @details This notification handler allows a reward uniquely identified by owner name and reward name to be funded by including the reward identifier in the transaction memo
         * @param from - the sender of the transfer
         * @param to - the receiver of the transfer
         * @param quantity - the quantity for the transfer
         * @param memo - the memo for the transfer
         */
        [[eosio::on_notify("*::transfer")]]
        void on_transfer( const name& from,
                          const name& to,
                          const asset& quantity,
                          const std::string& memo );

        using addwhitelist_action = eosio::action_wrapper<"addwhitelist"_n, &exchange::addwhitelist>;
        using setwhitelist_action = eosio::action_wrapper<"setwhitelist"_n, &exchange::setwhitelist>;
        using removewlist_action = eosio::action_wrapper<"removewlist"_n, &exchange::removewlist>;
        using cleardeposit_action = eosio::action_wrapper<"cleardeposit"_n, &exchange::cleardeposit>;
        using refund_action = eosio::action_wrapper<"refund"_n, &exchange::refund>;

    private:

        struct [[eosio::table]] deposit {
            uint64_t deposit_id;
            time_point_sec timestamp;
            name from;
            asset quantity;
            string memo;
            checksum256 trxid;

            uint64_t primary_key()const { return deposit_id; }
        };

        struct [[eosio::table]] whitelist {
            uint64_t deposit_num;
            name contract;
            asset minimum_deposit;
            bool enabled;

            uint64_t primary_key()const { return minimum_deposit.symbol.code().raw(); }
        };

        typedef eosio::multi_index<"deposits"_n, deposit> deposits;
        typedef eosio::multi_index<"whitelists"_n, whitelist> whitelists;

        checksum256 get_trx_id();
        void check_token_valid ( const name& contract, const asset& token );
        void check_deposit_valid ( const asset& quantity );
        uint64_t get_next_deposit_id ( const asset& token );

    };

}
