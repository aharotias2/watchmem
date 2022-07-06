const string MESSAGE = "Memory usage is now %d%%. "
        + "If you do not close the application that uses a lot of memory, "
        + "the response may be very slow.\n"
        + "\n"
        + "It is recommended to kill one of the processes displayed below.";

const string CONFIRM = "Do you really kill the process (%d)?";
const int upper_limit = 95;
const int MARGIN_ROW = 5;
const int MARGIN_COL = 10;

int main(string[] args) {
    Gtk.init(ref args);
    Timeout.add(1000, watch_mem);
    Gtk.main();
    return 0;
}

bool watch_mem() {
    MeminfoParser meminfo_parser = new MeminfoParser();
    Gee.Map<string, long> meminfo = meminfo_parser.parse_meminfo();
    long mem_total = meminfo["MemTotal"];
    long mem_available = meminfo["MemAvailable"];
    int usage_percent = (int) ((double) (mem_total - mem_available) / (double) mem_total * 100.0);

    if (usage_percent >= upper_limit) {
        PStatusCollector collector = new PStatusCollector();
        Gee.List<PStatusData> data = collector.collect();

        Gtk.MessageDialog dialog = new Gtk.MessageDialog(null, MODAL, WARNING, CLOSE, MESSAGE.printf(upper_limit));
        {
            Gtk.Grid grid = new Gtk.Grid() {
                margin = 10,
                halign = CENTER
            };

            grid.attach(new Gtk.Label("<b>Pid</b>") { use_markup = true }, 0, 0);
            grid.attach(new Gtk.Label("<b>Name</b>") { use_markup = true }, 1, 0);
            grid.attach(new Gtk.Label("<b>Memory usage</b>") { use_markup = true }, 2, 0, 2);
            grid.attach(new Gtk.Label("<b>Action</b>") { use_markup = true }, 4, 0);

            for (int i = 0; i < 10 && i < data.size; i++) {
                PStatusData pstatus = data[i];

                Gtk.Label label_pid = new Gtk.Label(pstatus.pid.to_string()) {
                    margin_top = MARGIN_ROW,
                    margin_bottom = MARGIN_ROW,
                    margin_start = MARGIN_COL,
                    margin_end = MARGIN_COL,
                    halign = END
                };

                Gtk.Label label_pname = new Gtk.Label(pstatus.name) {
                    margin_top = MARGIN_ROW,
                    margin_bottom = MARGIN_ROW,
                    margin_start = MARGIN_COL,
                    margin_end = MARGIN_COL,
                    halign = START
                };

                int p_usage_percent = (int) ((double) pstatus.vm_size / (double) mem_total * 100.0);

                Gtk.Label label_vm_size_1 = new Gtk.Label(comma_long(pstatus.vm_size) + "KB") {
                    margin_top = MARGIN_ROW,
                    margin_bottom = MARGIN_ROW,
                    margin_start = MARGIN_COL,
                    margin_end = 2,
                    halign = END
                };

                Gtk.Label label_vm_size_2 = new Gtk.Label("(" + p_usage_percent.to_string() + "%)") {
                    margin_top = MARGIN_ROW,
                    margin_bottom = MARGIN_ROW,
                    margin_start = 2,
                    margin_end = MARGIN_COL,
                    halign = END
                };

                Gtk.Button button_kill = new Gtk.Button.with_label("Kill") {
                    margin_top = MARGIN_ROW,
                    margin_bottom = MARGIN_ROW,
                    margin_start = MARGIN_COL,
                    margin_end = MARGIN_COL,
                    halign = CENTER
                };

                button_kill.clicked.connect(() => {
                    Gtk.MessageDialog confirm = new Gtk.MessageDialog(dialog, MODAL, OTHER, OK_CANCEL, CONFIRM.printf(pstatus.pid));
                    confirm.show_all();
                    int user_choice = confirm.run();
                    if (user_choice == Gtk.ResponseType.OK) {
                        Posix.kill(pstatus.pid, Posix.Signal.KILL);
                        confirm.close();
                        dialog.close();
                    } else {
                        confirm.close();
                    }
                });

                grid.attach(label_pid, 0, i + 1);
                grid.attach(label_pname, 1, i + 1);
                grid.attach(label_vm_size_1, 2, i + 1);
                grid.attach(label_vm_size_2, 3, i + 1);
                grid.attach(button_kill, 4, i + 1);
            }

            dialog.get_content_area().pack_start(grid, true, true);
            dialog.show_all();
        }

        dialog.run();
        dialog.close();
    }

    return Source.CONTINUE;
}
