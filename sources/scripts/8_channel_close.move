script {

    use 0x2::Fun::FunCoin;
    use 0x2::Channel;

    fun s_channel_close(payer: signer, payee: signer, seq: u64, amount: u64, delay: u64) {
        Channel::close<FunCoin>(seq, &payer, &payee, amount, delay);
    }

}
