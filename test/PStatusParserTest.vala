int test_p_status_parser_1(uint pid) {
    PStatusParser parser = new PStatusParser();
    Gee.Map<string, string> output = parser.parse_pstatus(pid);
    foreach (string key in output.keys) {
        print("%s: %s\n", key, output[key]);
    }
    return 0;
}
