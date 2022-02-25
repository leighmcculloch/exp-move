script {

    use Std::Debug;

    fun scratch(_s: signer) {
        let i = 100;
        Debug::print(&i);
    }

}
