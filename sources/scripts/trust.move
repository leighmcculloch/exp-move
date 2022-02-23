script {

    use 0x2::Coin;
    use 0x3::Fun::FunCoin;

    fun s_trust(s: signer) {
        Coin::trust<FunCoin>(&s);
    }

}
