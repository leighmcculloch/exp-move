address 0x2 {
    module Channel {
        use Std::Signer;
        use 0x2::Coin;
        use 0x2::Coin::Amount;
        use 0x2::Time;

        const ENOT_MODULE: u64 = 0;
        const ENOT_MEMBER: u64 = 1;
        const ESUPERSEDED: u64 = 2;
        const ENOT_CLOSING: u64 = 3;
        const ENOT_CLOSED: u64 = 4;
        const EMALFORMED: u64 = 5;
        const ENOT_SIGNED: u64 = 6;
        const ECLOSED: u64 = 7;

        // Config contains values fixed at initialization.
        struct Config<phantom T> has key {
            i: address,
            r: address,
        }

        // CloseState contains values set when closing.
        struct CloseState<phantom T> has key {
            seq: u64,
            seq_time: u64,
            i_pays_r: bool,
            amount: u64,
            delay: u64,
        }

        // Membership holds amounts locked up by a member for use in the
        // channel.
        struct Membership<phantom T> has key {
            amount: Amount<T>,
        }

        public fun init<T>(s: &signer, i: address, r: address) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Config<T>{
                i: i,
                r: r,
            });
            move_to(s, CloseState<T>{
                seq: 0,
                seq_time: 0,
                i_pays_r: true,
                amount: 0,
                delay: 0,
            });
        }

        public fun join<T>(acc: &signer) acquires Config {
            let acc_addr = Signer::address_of(acc);
            assert!(is_member<T>(acc_addr), ENOT_MEMBER);
            let zero = Coin::zero<T>();
            move_to(acc, Membership<T>{amount: zero})
        }

        public fun deposit<T>(acc: address, a: Amount<T>) acquires Config, Membership {
            assert!(is_member<T>(acc), ENOT_MEMBER);
            let amount = &mut borrow_global_mut<Membership<T>>(acc).amount;
            Coin::merge_into<T>(amount, a)
        }

        public fun withdraw<T>(acc: &signer): Amount<T> acquires Config, CloseState, Membership {
            let acc_addr = Signer::address_of(acc);
            assert!(is_member<T>(acc_addr), ENOT_MEMBER);
            assert!(is_closed<T>(), ENOT_CLOSED);
            let Membership { amount } = move_from<Membership<T>>(acc_addr);
            amount
        }

        public fun close<T>(seq: u64, payer: &signer, payee: &signer, amount: u64, delay: u64) acquires Config, CloseState {
            assert!(!is_closed<T>(), ECLOSED);

            let payer_addr = Signer::address_of(payer);
            let payee_addr = Signer::address_of(payee);
            assert!(payer_addr != payee_addr, EMALFORMED);
            assert!(is_member<T>(payer_addr), ENOT_MEMBER);
            assert!(is_member<T>(payee_addr), ENOT_MEMBER);

            let close_seq = &mut borrow_global_mut<CloseState<T>>(@0x2).seq;
            assert!(seq > *close_seq, ESUPERSEDED);
            *close_seq = seq;

            let close_seq_time = &mut borrow_global_mut<CloseState<T>>(@0x2).seq_time;
            *close_seq_time = Time::now();

            let config_i = borrow_global<Config<T>>(@0x2).i;
            let close_i_pays_r = &mut borrow_global_mut<CloseState<T>>(@0x2).i_pays_r;
            *close_i_pays_r = payer_addr == config_i;

            let close_amount = &mut borrow_global_mut<CloseState<T>>(@0x2).amount;
            *close_amount = amount;

            let close_delay = &mut borrow_global_mut<CloseState<T>>(@0x2).delay;
            *close_delay = delay;
        }

        public fun is_member<T>(acc: address): bool acquires Config {
            let internal = borrow_global<Config<T>>(@0x2);
            acc == internal.i || acc == internal.r
        }

        public fun seq<T>(): u64 acquires CloseState {
            borrow_global<CloseState<T>>(@0x2).seq
        }

        public fun seq_time<T>(): u64 acquires CloseState {
            borrow_global<CloseState<T>>(@0x2).seq_time
        }

        public fun is_closed<T>(): bool acquires CloseState {
            let seq_time = borrow_global<CloseState<T>>(@0x2).seq_time;
            let delay = borrow_global<CloseState<T>>(@0x2).delay;
            seq_time > 0 && (seq_time + delay) < Time::now()
        }
    }
}
