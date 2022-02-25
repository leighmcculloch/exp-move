script {

    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_init(s: signer, i: address, r: address, observation_period: u64) {
        Channel::init<FunCoin>(&s, i, r, observation_period);
    }

}
