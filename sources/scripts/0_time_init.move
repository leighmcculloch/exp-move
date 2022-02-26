script {

    use 0x2::Time;

    fun s_channel_init(s: signer) {
        Time::init(&s);
    }

}
