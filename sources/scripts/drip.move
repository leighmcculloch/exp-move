script {

    use 0x2::Coin;
    use 0x2::Drip;

    fun drip(s: signer) {
        let c = Coin::get(&s);
        Drip::lockup(&s, c, Coin::split);
        // TODO: drip
    }

}
