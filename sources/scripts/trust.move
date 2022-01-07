script {

    use 0x2::Coin;

    fun trust(s: signer) {
        Coin::trust(&s);
    }

}
