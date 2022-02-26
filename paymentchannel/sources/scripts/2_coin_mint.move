script {

    use 0x2::Coin;
    use 0x2::Fun::FunCoin;

    fun s_coin_mint(s: signer, to: address, amount: u64) {
        Coin::mint<FunCoin>(&s, to, amount)
    }

}
