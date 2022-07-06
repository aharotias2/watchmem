int main(string[] argv) {
    if (argv.length < 3) {
        return 1;
    }
    string test_name = argv[1];
    int test_case = int.parse(argv[2]);
    if (test_case == 0) {
        return 3;
    }
    print("test %s-%d: \n", test_name, test_case);
    switch (test_name) {
      case "PStatusParser":
        switch (test_case) {
          case 1:
            if (argv.length < 4) {
                print("pid is required.\n");
                return 2;
            }
            uint pid = uint.parse(argv[3]);
            return test_p_status_parser_1(pid);
          default:
            break;
        }
        break;
      case "PStatusCollector":
        switch (test_case) {
          case 1:
            return test_p_status_collector_1();
          default:
            break;
        }
        break;
      case "PStatusDialog":
        switch (test_case) {
          case 1:
            return test_p_status_dialog_1();
          default:
            break;
        }
        break;
      default:
        break;
    }
    return 1;
}
