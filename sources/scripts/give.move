script {

    use Std::Signer;
    use 0x2::Coin;
    use 0x3::Fun::FunCoin;

    fun give(s: signer, to: address, amount: u64) {
        let c = Coin::get<FunCoin>(&s);
        let (c0, c1) = Coin::split(c, amount);
        Coin::put(to, c0);
        Coin::put(Signer::address_of(&s), c1);
    }
}
