address 0x2 {
    module Channel {
        use Std::Signer;
        use Std::Vector;
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
            observation_period: u64,
        }

        // CloseState contains values set when closing.
        struct CloseState<phantom T> has key {
            seq: u8,
            seq_time: u64,
            i_pays_r: bool,
            amount: u64,
        }

        // Membership holds amounts locked up by a member for use in the
        // channel.
        struct Membership<phantom T> has key {
            amount: Amount<T>,
        }

        public fun init<T>(s: &signer, i: address, r: address, observation_period: u64) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Config<T>{
                i: i,
                r: r,
                observation_period: observation_period,
            });
            move_to(s, CloseState<T>{
                seq: 0,
                seq_time: 0,
                i_pays_r: true,
                amount: 0,
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

        public fun leave<T>(acc: &signer): Amount<T> acquires Config, CloseState, Membership {
            let acc_addr = Signer::address_of(acc);
            assert!(is_member<T>(acc_addr), ENOT_MEMBER);
            assert!(is_closed<T>(), ENOT_CLOSED);
            let Membership { amount } = move_from<Membership<T>>(acc_addr);
            amount
        }

        public fun close<T>(msg: vector<u8>) acquires Config, CloseState {
            assert!(!is_closed<T>(), ECLOSED);

            assert!(Vector::length(&msg) == 10, EMALFORMED);
            let seq = *Vector::borrow(&msg, 0);
            let i_pays_r = *Vector::borrow(&msg, 1) & 0x80 == 0; // 0 is i pays r, 1 is r pays i. i.e. negative values r pays i.
            let amt =
                ((*Vector::borrow(&msg, 1) as u64) & 0x7F) << 7 |
                (*Vector::borrow(&msg, 2) as u64) << 6 |
                (*Vector::borrow(&msg, 3) as u64) << 5 |
                (*Vector::borrow(&msg, 4) as u64) << 4 |
                (*Vector::borrow(&msg, 5) as u64) << 3 |
                (*Vector::borrow(&msg, 6) as u64) << 2 |
                (*Vector::borrow(&msg, 7) as u64) << 1 |
                (*Vector::borrow(&msg, 8) as u64);
            let sig = *Vector::borrow(&msg, 9);

            // Signature scheme is for i's signature to set bit 2, and r's
            // signature to set bit 1.
            assert!(sig == 3, ENOT_SIGNED);

            let internal_seq = &mut borrow_global_mut<CloseState<T>>(@0x2).seq;
            assert!(seq > *internal_seq, ESUPERSEDED);
            *internal_seq = seq;

            let internal_seq_time = &mut borrow_global_mut<CloseState<T>>(@0x2).seq_time;
            *internal_seq_time = Time::now();

            let internal_i_pays_r = &mut borrow_global_mut<CloseState<T>>(@0x2).i_pays_r;
            *internal_i_pays_r = i_pays_r;

            let internal_amount = &mut borrow_global_mut<CloseState<T>>(@0x2).amount;
            *internal_amount = amt;
        }

        public fun is_member<T>(acc: address): bool acquires Config {
            let internal = borrow_global<Config<T>>(@0x2);
            acc == internal.i || acc == internal.r
        }

        public fun seq<T>(): u8 acquires CloseState {
            borrow_global<CloseState<T>>(@0x2).seq
        }

        public fun seq_time<T>(): u64 acquires CloseState {
            borrow_global<CloseState<T>>(@0x2).seq_time
        }

        public fun is_closed<T>(): bool acquires Config, CloseState {
            let observation_period = borrow_global<Config<T>>(@0x2).observation_period;
            let seq_time = borrow_global<CloseState<T>>(@0x2).seq_time;
            seq_time > 0 && (seq_time + observation_period) < Time::now()
        }
    }
}
