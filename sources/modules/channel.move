address 0x2 {
    module Channel {
        use Std::Signer;
        use Std::Vector;
        use 0x2::Coin;
        use 0x2::Coin::Amount;
        use 0x2::Time;

        const ENOT_MODULE: u64 = 0;
        const ENOT_PARTICIPANT: u64 = 1;
        const ESUPERSEDED: u64 = 2;
        const ENOT_CLOSING: u64 = 3;
        const ENOT_CLOSED: u64 = 4;
        const EMALFORMED: u64 = 5;
        const ENOT_SIGNED: u64 = 6;
        const ECLOSED: u64 = 7;

        struct Internal<phantom T> has key {
            i: address,
            r: address,
            seq: u8,
            seq_time: u64,
            closed: bool,
        }

        struct Membership<phantom T> has key, store {
            amount: Amount<T>,
        }

        public fun init<T>(s: &signer, i: address, r: address) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Internal<T>{
                i: i,
                r: r,
                seq: 0,
                seq_time: 0,
                closed: false,
            })
        }

        public fun join<T>(i_or_r: &signer) acquires Internal {
            let i_or_r_addr = Signer::address_of(i_or_r);
            let internal = borrow_global<Internal<T>>(@0x2);
            assert!(i_or_r_addr == internal.i || i_or_r_addr == internal.r, ENOT_PARTICIPANT);
            let zero = Coin::zero<T>();
            move_to(i_or_r, Membership<T>{amount: zero})
        }

        public fun deposit<T>(i_or_r: address, a: Amount<T>) acquires Internal, Membership {
            let internal = borrow_global<Internal<T>>(@0x2);
            assert!(i_or_r == internal.i || i_or_r == internal.r, ENOT_PARTICIPANT);
            let amount = &mut borrow_global_mut<Membership<T>>(i_or_r).amount;
            Coin::merge_into<T>(amount, a)
        }

        public fun leave<T>(i_or_r: &signer): Amount<T> acquires Internal, Membership {
            let internal = borrow_global<Internal<T>>(@0x2);
            assert!(internal.closed, ENOT_CLOSED);
            let i_or_r_addr = Signer::address_of(i_or_r);
            let Membership { amount } = move_from<Membership<T>>(i_or_r_addr);
            amount
        }

        public fun close<T>(msg: vector<u8>) acquires Internal {
            assert!(Vector::length(&msg) == 10, EMALFORMED);
            let seq = *Vector::borrow(&msg, 0);
            let dir = *Vector::borrow(&msg, 1) & 0x80; // 0 is i pay r, 1 is r pays i.
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

            let internal = borrow_global<Internal<T>>(@0x2);
            assert!(!internal.closed, ECLOSED);
            assert!(seq > internal.seq, ESUPERSEDED);


            // let internal_i_seq = &mut borrow_global_mut<Internal>(@0x2).i_seq;
            // let internal_r_seq = &mut borrow_global_mut<Internal>(@0x2).r_seq;
            // let internal_seq_time = &mut borrow_global_mut<Internal>(@0x2).seq_time;
            // *internal_i_seq = seq;
            // *internal_r_seq = seq;
            // *internal_seq_time = Time::now();
        }

        public fun seq<T>(i_or_r: address): u8 acquires Internal {
            borrow_global<Internal<T>>(@0x2).seq
        }

        public fun seq_time<T>(): u64 acquires Internal {
            borrow_global<Internal<T>>(@0x2).seq_time
        }

        public fun closed<T>(): bool acquires Internal {
            let seq_time = borrow_global<Internal<T>>(@0x2).seq_time;
            seq_time > 0 && seq_time < Time::now()
        }
    }
}
