address 0x2 {
    module Drip {
        struct Dripped<T: store> has key {
            value: T,
        }

        public fun lockup<T: store>(account: &signer, t: T) {
            move_to(account, Dripped<T>{value: t})
        }

        // Drip returns a piece of T, bit by bit until its all gone.
        //public fun drip<T: store>(account: &signer): T acquires Dripped {
        //    // TODO: How to split T?
        //}
    }
}
