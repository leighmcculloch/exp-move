script {

    use 0x2::Coin;

    fun s_coin_init(s: signer) {
        Coin::init(&s);
    }

}
