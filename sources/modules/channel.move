address 0x2 {
    module Channel {
        use Std::Signer;
        use 0x2::Coin;
        use 0x2::Coin::Amount;
        use 0x2::Time;

        const ENOT_MODULE: u64 = 0;
        const ENOT_PARTICIPANT: u64 = 1;
        const ESUPERSEDED: u64 = 2;
        const ENOT_CLOSING: u64 = 3;

        struct Internal has key {
            i: address,
            r: address,
            i_seq: u64,
            r_seq: u64,
            seq_time: u64,
            closed: bool,
        }

        struct Membership<phantom T> has key, store {
            amount: Amount<T>,
        }

        public fun init(s: &signer, i: address, r: address) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Internal{
                i: i,
                r: r,
                i_seq: 0,
                r_seq: 0,
                seq_time: 0,
                closed: false,
            })
        }

        public fun join<T>(i_or_r: &signer) acquires Internal {
            let i_or_r_addr = Signer::address_of(i_or_r);
            let internal = borrow_global<Internal>(@0x2);
            assert!(i_or_r_addr == internal.i || i_or_r_addr == internal.r, ENOT_PARTICIPANT);
            let zero = Coin::zero<T>();
            move_to(i_or_r, Membership<T>{amount: zero})
        }

        public fun deposit<T>(i_or_r: address, a: Amount<T>) acquires Internal, Membership {
            let internal = borrow_global<Internal>(@0x2);
            assert!(i_or_r == internal.i || i_or_r == internal.r, ENOT_PARTICIPANT);
            let amount = &mut borrow_global_mut<Membership<T>>(i_or_r).amount;
            Coin::merge_into<T>(amount, a)
        }

        public fun leave<T>(i_or_r: &signer): Amount<T> acquires Membership {
            let i_or_r_addr = Signer::address_of(i_or_r);
            let Membership { amount } = move_from<Membership<T>>(i_or_r_addr);
            amount
        }

        public fun start_close(_i_msg: vector<u8>, _r_msg: vector<u8>) acquires Internal {
            // TODO: decode msg, and if signed by 
            // let internal = borrow_global<Internal>(@0x2);
            // assert!(seq > internal.i_seq, ESUPERSEDED);
            // let internal_i_seq = &mut borrow_global_mut<Internal>(@0x2).i_seq;
            // let internal_r_seq = &mut borrow_global_mut<Internal>(@0x2).r_seq;
            // let internal_seq_time = &mut borrow_global_mut<Internal>(@0x2).seq_time;
            // *internal_i_seq = seq;
            // *internal_r_seq = seq;
            // *internal_seq_time = Time::now();
        }

        public fun complete_close(_msg: vector<u8>) acquires Internal {
            let internal = borrow_global<Internal>(@0x2);
            assert!(internal.i_seq > 0, ENOT_MODULE);
            assert!(internal.r_seq > 0, ENOT_MODULE);
            assert!(internal.seq_time > 0, ENOT_MODULE);
        }

        public fun seq(i_or_r: address): u64 acquires Internal {
            let internal = borrow_global<Internal>(@0x2);
            if (i_or_r == internal.i) {
                internal.i_seq
            } else if (i_or_r == internal.r) {
                internal.r_seq
            } else {
                abort ENOT_PARTICIPANT
            }
        }

        public fun seq_time(): u64 acquires Internal {
            borrow_global<Internal>(@0x2).seq_time
        }
    }
}
