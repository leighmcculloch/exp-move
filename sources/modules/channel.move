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
            payer: address,
            payee: address,
            amount: Amount<T>,
            delay: u64,
        }

        // Membership holds amounts locked up by a member for use in the
        // channel.
        struct Membership<phantom T> has key {
            amount: Amount<T>,
        }

        public fun init<T>(i: &signer, r: address) acquires Config {
            let i_addr = Signer::address_of(i);
            move_to(i, Config<T>{
                i: i_addr,
                r: r,
            });
            move_to(i, CloseState<T>{
                seq: 0,
                seq_time: 0,
                payer: i_addr,
                payee: r,
                amount: Coin::zero<T>(),
                delay: 0,
            });
            join<T>(i_addr, i);
        }

        public fun join<T>(owner: address, acc: &signer) acquires Config {
            let acc_addr = Signer::address_of(acc);
            assert!(is_member<T>(owner, acc_addr), ENOT_MEMBER);
            let zero = Coin::zero<T>();
            move_to(acc, Membership<T>{amount: zero})
        }

        public fun deposit<T>(owner: address, acc: address, a: Amount<T>) acquires Config, Membership {
            assert!(is_member<T>(owner, acc), ENOT_MEMBER);
            let amount = &mut borrow_global_mut<Membership<T>>(acc).amount;
            Coin::merge_into<T>(amount, a)
        }

        public fun withdraw<T>(owner: address, acc: &signer): Amount<T> acquires Config, CloseState, Membership {
            let acc_addr = Signer::address_of(acc);
            assert!(is_member<T>(owner, acc_addr), ENOT_MEMBER);
            assert!(is_closed<T>(owner), ENOT_CLOSED);
            let Membership { amount } = move_from<Membership<T>>(acc_addr);
            let close_payee = borrow_global<CloseState<T>>(owner).payee;
            if (acc_addr == close_payee) {
                let close_amount = &mut borrow_global_mut<CloseState<T>>(owner).amount;
                Coin::merge_into_from(amount, close_amount);
            }
            amount
        }

        public fun close<T>(owner: address, seq: u64, payer: &signer, payee: &signer, amount: u64, delay: u64) acquires Config, CloseState, Membership {
            assert!(!is_closed<T>(owner), ECLOSED);

            let payer_addr = Signer::address_of(payer);
            let payee_addr = Signer::address_of(payee);
            assert!(payer_addr != payee_addr, EMALFORMED);
            assert!(is_member<T>(owner, payer_addr), ENOT_MEMBER);
            assert!(is_member<T>(owner, payee_addr), ENOT_MEMBER);

            let close_seq = &mut borrow_global_mut<CloseState<T>>(owner).seq;
            assert!(seq > *close_seq, ESUPERSEDED);
            *close_seq = seq;

            let close_seq_time = &mut borrow_global_mut<CloseState<T>>(owner).seq_time;
            *close_seq_time = Time::now();

            let close_payer = borrow_global<CloseState<T>>(owner).payer;
            let close_payer_amount = &mut borrow_global_mut<Membership<T>>(close_payer).amount;
            let close_amount = &mut borrow_global_mut<CloseState<T>>(owner).amount;
            Coin::merge_into_from(close_payer_amount, close_amount);

            let payer_amount = &mut borrow_global_mut<Membership<T>>(payer_addr).amount;
            let payment_amount = Coin::split_out(payer_amount, amount);
            Coin::merge_into(close_amount, payment_amount);

            let close_payer = &mut borrow_global_mut<CloseState<T>>(owner).payer;
            *close_payer = payer_addr;

            let close_payee = &mut borrow_global_mut<CloseState<T>>(owner).payee;
            *close_payee = payee_addr;

            let close_delay = &mut borrow_global_mut<CloseState<T>>(owner).delay;
            *close_delay = delay;
        }

        public fun is_member<T>(owner: address, acc: address): bool acquires Config {
            let internal = borrow_global<Config<T>>(owner);
            acc == internal.i || acc == internal.r
        }

        public fun seq<T>(owner: address): u64 acquires CloseState {
            borrow_global<CloseState<T>>(owner).seq
        }

        public fun seq_time<T>(owner: address): u64 acquires CloseState {
            borrow_global<CloseState<T>>(owner).seq_time
        }

        public fun is_closed<T>(owner: address): bool acquires CloseState {
            let seq_time = borrow_global<CloseState<T>>(owner).seq_time;
            let delay = borrow_global<CloseState<T>>(owner).delay;
            seq_time > 0 && (seq_time + delay) < Time::now()
        }
    }
}
