address 0x2 {
    module Coin {
        use Std::Signer;

        const ENOT_MODULE: u64 = 0;
        const EINSUFFICIENT_VALUE: u64 = 1;

        struct Internal has key {
            circulating: u64,
        }

        struct Amount<phantom T> has key, store {
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

        public fun mint<T>(s: &signer, account: address, value: u64) acquires Internal, Amount {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            let ciculating = &mut borrow_global_mut<Internal>(@0x2).circulating;
            *ciculating = *ciculating + value;
            let amount = &mut borrow_global_mut<Amount<T>>(account).value;
            *amount = *amount + value
        }

        public fun burn<T>(amount: Amount<T>) acquires Internal {
            let Amount { value } = amount;
            let c = &mut borrow_global_mut<Internal>(@0x2).circulating;
            *c = *c - value;
        }

        public fun value<T>(amount: Amount<T>): u64 {
            let Amount { value } = amount;
            value
        }

        public fun zero<T>(): Amount<T> {
            Amount<T>{value: 0}
        }

        public fun trust<T>(account: &signer) {
            move_to(account, Amount<T>{value: 0})
        }

        public fun balance<T>(account: address): u64 acquires Amount {
            borrow_global<Amount<T>>(account).value
        }

        public fun split<T>(amount: Amount<T>, take: u64): (Amount<T>, Amount<T>) {
            let Amount { value } = amount;
            assert!(take < value, EINSUFFICIENT_VALUE);
            let c0 = Amount { value: take };
            let c1 = Amount { value: value-take };
            (c0, c1)
        }

        public fun split_out<T>(amount: &mut Amount<T>, take: u64): Amount<T> {
            assert!(take < amount.value, EINSUFFICIENT_VALUE);
            amount.value = amount.value - take;
            Amount { value: take }
        }

        public fun merge<T>(a1: Amount<T>, a2: Amount<T>): Amount<T> {
            let Amount<T> { value: v1 } = a1;
            let Amount<T> { value: v2 } = a2;
            Amount { value: v1 + v2 }
        }

        public fun merge_into<T>(a1: &mut Amount<T>, a2: Amount<T>) {
            let Amount<T> { value: v2 } = a2;
            a1.value = a1.value + v2;
        }

        public fun get<T>(account: &signer): Amount<T> acquires Amount {
            let account_addr = Signer::address_of(account);
            let value = &mut borrow_global_mut<Amount<T>>(account_addr).value;
            let amount = Amount { value: *value };
            *value = 0;
            amount
        }

        public fun put<T>(account: address, amount: Amount<T>) acquires Amount {
            let Amount { value } = amount;
            let account_value = &mut borrow_global_mut<Amount<T>>(account).value;
            *account_value = *account_value + value;
        }
    }
}
