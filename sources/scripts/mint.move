script {

    use 0x2::Coin;
    use 0x3::Fun::FunCoin;

    fun s_mint(s: signer, to: address, amount: u64) {
        Coin::mint<FunCoin>(&s, to, amount)
    }

}
