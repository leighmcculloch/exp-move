script {

    use Std::Signer;
    use 0x2::Coin;
    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_withdraw(s: signer) {
        let amount = Channel::withdraw<FunCoin>(&s);
        Coin::put<FunCoin>(Signer::address_of(&s), amount);
    }

}
