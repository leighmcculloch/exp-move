script {

    use 0x2::Coin;

    fun init(s: signer) {
        Coin::init(&s);
    }

}
