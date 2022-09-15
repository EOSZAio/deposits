#include <exchange-deposits/exchange-deposits.hpp>

#include <eosio/transaction.hpp>

namespace eosio {

/*
 * needed to read currency stats table of a token contract
 */
struct currency_stats {
    asset    supply;
    asset    max_supply;
    name     issuer;
    uint64_t primary_key()const { return supply.symbol.code().raw(); }
};

typedef eosio::multi_index< "stat"_n, currency_stats > stats;

/*
 * this action adds a token to the whitelist
 */
void exchange::addwhitelist( const name& contract, const asset& minimum_deposit )
{
    require_auth( get_self() );

    check_token_valid( contract, minimum_deposit );

    whitelists whitelist_table( get_self(), get_self().value );

    auto wl = whitelist_table.find( minimum_deposit.symbol.code().raw() );
    check( wl == whitelist_table.end(), "Token already in the whitelist" );

    whitelist_table.emplace( get_self(), [&]( auto& list ) {
        list.deposit_num = 0;
        list.contract = contract;
        list.minimum_deposit = minimum_deposit;
        list.enabled = 1;
    });
}

/*
 * this action enables / disables deposits of a whitelisted token
 */
void exchange::setwhitelist( const symbol_code& symbol, const bool& enabled )
{
    require_auth( get_self() );

    whitelists whitelist_table( get_self(), get_self().value );
    auto wl = whitelist_table.find( symbol.raw() );
    check( wl != whitelist_table.end(), "token not in the whitelist" );

    whitelist_table.modify(wl, same_payer, [&](auto& w) {
        w.enabled = enabled;
    });
}

/*
 * this token removes a token from the whitelist
 */
void exchange::removewlist( const symbol_code& symbol )
{
    require_auth( get_self() );

    deposits deposits_table(get_self(), symbol.raw());
    check( deposits_table.begin() == deposits_table.end(), "clear deposits table before removing token" );

    whitelists whitelist_table( get_self(), get_self().value );
    auto wl = whitelist_table.find( symbol.raw() );
    check( wl != whitelist_table.end(), "token not in the whitelist" );

    whitelist_table.erase(wl);
}

/*
 * this action removes a deposit record from the deposits table and recovers the RAM consumed by the row
 */
void exchange::cleardeposit ( const symbol_code& symbol, const uint64_t& deposit_id )
{
    require_auth( get_self() );

    deposits deposits_table(get_self(), symbol.raw());

    auto existing = deposits_table.find( deposit_id );
    check( existing != deposits_table.end(), "deposit id not found" );
    const auto &it = *existing;

    deposits_table.erase( it );
}

/*
 * this action refunds a deposit to the sender
 */
void exchange::refund ( const symbol_code& symbol, const uint64_t& deposit_id, const std::string& memo )
{
    require_auth( get_self() );

    deposits deposits_table(get_self(), symbol.raw());

    auto existing = deposits_table.find( deposit_id );
    check( existing != deposits_table.end(), "deposit id not found" );
    const auto &it = *existing;
    string memo_str = (memo.length() == 0) ? it.memo : memo;

    whitelists whitelist_table( get_self(), get_self().value );
    auto wl = whitelist_table.get( it.quantity.symbol.code().raw(), "token not whitelisted" );

    action(permission_level{ get_self(), "active"_n },
           wl.contract, "transfer"_n,
           std::make_tuple( get_self(), it.from, it.quantity, memo_str )).send();

    deposits_table.erase( it );
}

/*
 * this function checks if a token exists on the blockchain
 */
void exchange::check_token_valid ( const name& contract, const asset& token )
{
    check( is_account( contract ), "owner account does not exist" );

    auto sym_code_raw = token.symbol.code().raw();
    stats stats_table( contract, sym_code_raw );
    const auto& st = stats_table.get( sym_code_raw, "symbol does not exist" );
    check( st.supply.symbol == token.symbol, "symbol precision mismatch" );
}

/*
 * this function validated a deposit
 */
void exchange::check_deposit_valid ( const asset& quantity )
{
    whitelists whitelist_table( get_self(), get_self().value );

    auto existing = whitelist_table.find( quantity.symbol.code().raw() );
    check( existing != whitelist_table.end(), "token not whitelisted" );
    const auto &wl = *existing;

    // Prevent fake or incorrect tokens being sent
    check( wl.enabled, "deposits disabled" );
    check( wl.contract == get_first_receiver(), "invalid token contract" );
    check( wl.minimum_deposit.symbol == quantity.symbol, "token symbol or precision mismatch" );
    check( wl.minimum_deposit.amount <= quantity.amount, "amount below minimum deposit" );
}

/*
 * get autoincrement deposit id (separate series for each token in whitelist)
 */
uint64_t exchange::get_next_deposit_id ( const asset& token )
{
    whitelists whitelist_table( get_self(), get_self().value );

    auto existing = whitelist_table.find( token.symbol.code().raw() );
    check( existing != whitelist_table.end(), "token not whitelisted" );
    const auto &wl = *existing;

    auto deposit_id = wl.deposit_num + 1;

    whitelist_table.modify(wl, same_payer, [&](auto& w) {
        w.deposit_num = deposit_id;
    });

    return deposit_id;
}

/*
 * calculate transaction hash for this transaction
 * https://eosio.stackexchange.com/questions/3088/accessing-current-transaction-id-within-a-smart-contract
 */
checksum256 exchange::get_trx_id()
{
    size_t size = transaction_size();
    char buf[size];
    size_t read = read_transaction( buf, size );
    check( size == read, "read_transaction failed");
    return sha256( buf, read );
}

/*
 * handle on_transfer event for deposits
 */
void exchange::on_transfer( const name& from,
                            const name& to,
                            const asset& quantity,
                            const std::string& memo )
{
    require_auth( from );

    // allow wallet owner to manage account, ignote account ops actions and withdrawals
    if ( has_auth(get_self()) || from == get_self() || from == "eosio.ram"_n || from == "eosio.stake"_n || from == "eosio.rex"_n )
        return;

//    auto _token = _tokens_table.get( quantity.symbol.code().raw(), "token not found" );
//    check(get_first_receiver() == _token.token_info.get_contract(),"incorrect token contract");

    check( to == get_self(), "contract not involved in transfer" );
    check( quantity.symbol.is_valid(), "invalid quantity in transfer" );
    check( quantity.amount > 0, "quantity must be greater than 0" );
    check( memo.size() <= 256, "memo has more than 256 bytes" );
    check_deposit_valid( quantity );

    // memo format can be validated if it a particular format is required

    deposits deposits_table( get_self(), quantity.symbol.code().raw() );

    deposits_table.emplace( get_self(), [&]( auto & deposit ) {
        deposit.deposit_id = get_next_deposit_id( quantity );
        deposit.timestamp = eosio::time_point_sec(current_time_point());
        deposit.from = from;
        deposit.quantity = quantity;
        deposit.memo = memo;
        deposit.trxid = get_trx_id();
    });
}

} /// namespace eosio
