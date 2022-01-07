script {

    use 0x2::Coin;

    fun mint(s: signer, to: address, amount: u64) {
        Coin::mint(&s, to, amount)
    }

}
