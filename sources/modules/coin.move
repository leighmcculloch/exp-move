address 0x2 {
    module Coin {
        use Std::Signer;

        const ENOT_MODULE: u64 = 0;
        const EINSUFFICIENT_VALUE: u64 = 1;

        struct Internal has key {
            circulating: u64,
        }

        struct Amount has key, store {
            value: u64,
        }

        public fun init(s: &signer) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Internal{circulating: 0})
        }

        public fun circulating(): u64 acquires Internal {
            borrow_global<Internal>(@0x2).circulating
        }

        public fun mint(s: &signer, account: address, value: u64) acquires Internal, Amount {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            let ciculating = &mut borrow_global_mut<Internal>(@0x2).circulating;
            *ciculating = *ciculating + value;
            let amount = &mut borrow_global_mut<Amount>(account).value;
            *amount = *amount + value
        }

        public fun burn(amount: Amount) acquires Internal {
            let Amount { value } = amount;
            let c = &mut borrow_global_mut<Internal>(@0x2).circulating;
            *c = *c - value;
        }

        public fun value(amount: Amount): u64 {
            let Amount { value } = amount;
            value
        }

        public fun trust(account: &signer) {
            move_to(account, Amount{value: 0})
        }

        public fun balance(account: address): u64 acquires Amount {
            borrow_global<Amount>(account).value
        }

        public fun split(amount: Amount, take: u64): (Amount, Amount) {
            let Amount { value } = amount;
            assert!(take < value, EINSUFFICIENT_VALUE);
            let c0 = Amount { value: take };
            let c1 = Amount { value: value-take };
            (c0, c1)
        }

        public fun get(account: &signer): Amount acquires Amount {
            let account_addr = Signer::address_of(account);
            let value = &mut borrow_global_mut<Amount>(account_addr).value;
            let amount = Amount { value: *value };
            *value = 0;
            amount
        }

        public fun put(account: address, amount: Amount) acquires Amount {
            let Amount { value } = amount;
            let account_value = &mut borrow_global_mut<Amount>(account).value;
            *account_value = *account_value + value;
        }
    }
}
