script {

    use Std::Signer;
    use 0x2::Coin;
    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_close_1(s: signer, to: address, amount: u64) {
        let c = Coin::get<FunCoin>(&s);
        let (c0, c1) = Coin::split(c, amount);
        Channel::deposit<FunCoin>(to, c0);
        Coin::put(Signer::address_of(&s), c1);
    }

}
