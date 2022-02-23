script {

    use 0x2::Coin;

    fun s_init(s: signer) {
        Coin::init(&s);
    }

}
