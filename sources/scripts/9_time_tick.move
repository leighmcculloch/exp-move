script {

    use Std::Debug;
    use 0x2::Time;

    fun s_time_tick() {
        let now = Time::now();
        Debug::print(&now);
    }

}
