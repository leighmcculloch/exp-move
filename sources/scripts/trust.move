script {

    use 0x2::Coin;
    use 0x3::Fun::FunCoin;

    fun trust(s: signer) {
        Coin::trust<FunCoin>(&s);
    }

}
