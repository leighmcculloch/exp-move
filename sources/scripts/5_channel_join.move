script {

    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_join(s: signer) {
        Channel::join<FunCoin>(&s)
    }

}
