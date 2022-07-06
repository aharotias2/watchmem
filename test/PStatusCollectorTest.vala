int test_p_status_collector_1() {
    debug("test_p_status_collector_1 begin\n");
    PStatusCollector collector = new PStatusCollector();
    Gee.List<PStatusData>? data = collector.collect();
    if (data == null) {
        printerr("data is null\n");
        return 1;
    } else if (data.size == 0) {
        printerr("data is empty\n");
        return 1;
    }
    foreach (PStatusData item in data) {
        print("%10d %-30s %ld\n", item.pid, item.name, item.vm_size);
    }
    debug("test_p_status_collector_1 end\n");
    return 0;
}
