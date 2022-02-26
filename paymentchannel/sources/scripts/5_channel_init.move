script {

    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_init(i: signer, r: address) {
        Channel::init<FunCoin>(&i, r);
    }

}
