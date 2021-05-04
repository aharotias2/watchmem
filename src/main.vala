const string MESSAGE = "Memory usage is now %d%%. "
        + "If you do not close the application that uses a lot of memory, "
        + "the response may be very slow.\n"
        + "\n"
        + "It is recommended to kill one of the processes displayed below.";

const string CONFIRM = "Do you really kill the process (%d)?";

int main(string[] args)
{
    Gtk.init(ref args);
    Timeout.add(1000, () => {
        MeminfoParser meminfo_parser = new MeminfoParser();
        Gee.Map<string, long> meminfo = meminfo_parser.parse_meminfo();
        long mem_total = meminfo["MemTotal"];
        long mem_available = meminfo["MemAvailable"];
        int usage_percent = (int) ((double) (mem_total - mem_available) / (double) mem_total * 100.0);

        if (usage_percent >= 95)
        {
            PStatusCollector collector = new PStatusCollector();
            Gee.List<PStatusData> data = collector.collect();
            
            Gtk.MessageDialog dialog = new Gtk.MessageDialog(null, MODAL, WARNING, CLOSE, MESSAGE.printf(95));
            {
                Gtk.Grid grid = new Gtk.Grid() {
                    margin = 10,
                    halign = CENTER
                };
                
                grid.attach(new Gtk.Label("<b>Pid</b>") { use_markup = true }, 0, 0);
                grid.attach(new Gtk.Label("<b>Name</b>") { use_markup = true }, 1, 0);
                grid.attach(new Gtk.Label("<b>Memory</b>") { use_markup = true }, 2, 0);
                grid.attach(new Gtk.Label("<b>Action</b>") { use_markup = true }, 3, 0);
                
                for (int i = 0; i < 5 && i < data.size; i++)
                {
                    PStatusData pstatus = data[i];
                    
                    Gtk.Label label_pid = new Gtk.Label(pstatus.pid.to_string()) {
                        margin = 10,
                        halign = START
                    };
                    
                    Gtk.Label label_pname = new Gtk.Label(pstatus.name) {
                        margin = 10,
                        halign = START
                    };
                    
                    int p_usage_percent = (int) ((double) pstatus.vm_size / (double) mem_total * 100.0);
                    
                    Gtk.Label label_vm_size = new Gtk.Label(comma_long(pstatus.vm_size) + " kb (" + p_usage_percent.to_string() + "%)") {
                        margin = 10,
                        halign = END
                    };
                    
                    Gtk.Button button_kill = new Gtk.Button.with_label("Kill") {
                        margin = 10
                    };
                    
                    button_kill.clicked.connect(() => {
                        Gtk.MessageDialog confirm = new Gtk.MessageDialog(dialog, MODAL, OTHER, OK_CANCEL, CONFIRM.printf(pstatus.pid));
                        confirm.show_all();
                        int user_choice = confirm.run();
                        if (user_choice == Gtk.ResponseType.OK)
                        {
                            Posix.kill(pstatus.pid, Posix.Signal.KILL);
                            confirm.close();
                            dialog.close();
                        }
                        else
                        {
                            confirm.close();
                        }
                    });
                    
                    grid.attach(label_pid, 0, i + 1);
                    grid.attach(label_pname, 1, i + 1);
                    grid.attach(label_vm_size, 2, i + 1);
                    grid.attach(button_kill, 3, i + 1);
                }

                dialog.get_content_area().pack_start(grid, false, false);
                dialog.show_all();
            }

            dialog.run();
            dialog.close();
        }

        return Source.CONTINUE;
    });
    
    Gtk.main();
    return 0;
}

string comma_long(long value)
{
    string result = "";
    string value_s = value.to_string();
    for (int i = value_s.length - 3; i >= 0; i -= 3)
    {
        if (result == "")
        {
            result = value_s.substring(i, 3);
        }
        else
        {
            result = value_s.substring(i, 3) + "," + result;
        }
    }
    int rem = value_s.length % 3;
    if (rem > 0)
    {
        if (result.length > 0)
        {
            result = value_s.substring(0, rem) + "," + result;
        }
        else
        {
            result = value_s.substring(0, rem);
        }
    }
    
    return result;
}
