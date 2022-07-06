public class PStatusCollector : Object {
    private static Regex pid_regex;
    private static Regex kb_regex;
    private static int uid;
    private static PStatusParser parser;

    static construct {
        uid = (int) Posix.getuid();

        try {
            pid_regex = new Regex("^[0-9]+$");
            kb_regex = new Regex("([0-9]+)");
        } catch (RegexError e) {
            stderr.printf("RegexError: %s\n", e.message);
            Process.exit(1);
        }

        parser = new PStatusParser();
    }

    public Gee.List<PStatusData> collect() {
        Gee.List<PStatusData> result = new Gee.ArrayList<PStatusData>();

        string dir_path = "/proc";
        Dir dir;
        try {
            dir = Dir.open(dir_path);
        } catch (Error e) {
            stderr.printf("Failed to open directory\n");
            Process.exit(1);
        }

        string? name = null;
        while ((name = dir.read_name()) != null) {
            MatchInfo matches;
            string path = Path.build_path(Path.DIR_SEPARATOR_S, dir_path, name);
            if (name == "." || name == "..") {
                continue;
            } else if (!FileUtils.test(path, FileTest.IS_DIR)) {
                continue;
            } else if (!string_is_all_digits(name)) {
                continue;
            }
            
            int pid = int.parse(name);
            Gee.Map<string, string> pstatus = parser.parse_pstatus(pid);
            string pstatus_uid_s = pstatus["uid"].split(" ")[0];
            int pstatus_uid = int.parse(pstatus_uid_s);

            if (pstatus_uid != uid) {
                continue;
            } else if (pstatus["tgid"] != pstatus["pid"]) {
                continue;
            }

            string vm_size_s = pstatus["vmsize"];
            MatchInfo matches_2;
            kb_regex.match(vm_size_s, 0, out matches_2);
            long vm_size = long.parse(matches_2.fetch(1));

            result.add(new PStatusData() {
                name = pstatus["name"],
                pid = int.parse(pstatus["pid"]),
                vm_size = vm_size
            });
        }

        result.sort((a, b) => a.vm_size < b.vm_size ? 1 : a.vm_size == b.vm_size ? 0 : -1);
        return result;
    }
    
    private bool string_is_all_digits(string arg) {
        for (int i = 0; i < arg.length; i++) {
            if (!arg[i].isdigit()) {
                return false;
            }
        }
        return true;
    }
}
