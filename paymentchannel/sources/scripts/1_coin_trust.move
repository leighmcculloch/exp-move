script {

    use 0x2::Coin;
    use 0x2::Fun::FunCoin;

    fun s_coin_trust(s: signer) {
        Coin::trust<FunCoin>(&s);
    }

}
