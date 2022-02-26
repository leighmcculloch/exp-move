address 0x2 {
    // Time is a module that provides a pretend time for now, that is always
    // moving forward, and changes everytime you look at it.
    module Time {
        use Std::Signer;

        const ENOT_MODULE: u64 = 0;
        const EINSUFFICIENT_VALUE: u64 = 1;

        struct Internal has key {
            time: u64,
        }

        public fun init(s: &signer) {
            let s_addr = Signer::address_of(s);
            assert!(s_addr == @0x2, ENOT_MODULE);
            move_to(s, Internal{time: 0})
        }

        public fun now(): u64 acquires Internal {
            let time = &mut borrow_global_mut<Internal>(@0x2).time;
            *time = *time + 1;
            *time
        }
    }
}
