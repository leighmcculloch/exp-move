script {

    use Std::Signer;
    use 0x2::Coin;
    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_withdraw(s: signer, owner: address) {
        let amount = Channel::withdraw<FunCoin>(owner, &s);
        Coin::put<FunCoin>(Signer::address_of(&s), amount);
    }

}
