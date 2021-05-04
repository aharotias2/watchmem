[indent=4]
const MESSAGE : string = """Memory usage is now %d%%.
If you do not close the application that uses a lot of memory,
the response may be very slow.

It is recommended to kill one of the processes displayed below."""

const CONFIRM : string = "Do you really kill the process (%d)?"
const UPPER_LIMIT : int = 95
const MARGIN_ROW : int = 5
const MARGIN_COL : int = 10

init
    Gtk.init(ref args)
    Timeout.add(1000, do_interval)
    Gtk.main()

def do_interval() : bool
    var meminfo_parser = new MeminfoParser()
    meminfo : dict of string, long = meminfo_parser.parse_meminfo()
    mem_total : long = meminfo["MemTotal"]
    mem_available : long = meminfo["MemAvailable"]
    usage_percent : int = (int) ((double) (mem_total - mem_available) / (double) mem_total * 100.0)

    if usage_percent >= UPPER_LIMIT
        var collector = new PStatusCollector()
        var data = collector.collect()
        var dialog = new Gtk.MessageDialog(null, MODAL, WARNING, CLOSE, MESSAGE.printf(UPPER_LIMIT))
        var grid = new Gtk.Grid()
        grid.margin = 10
        grid.halign = CENTER

        label_head_pid : Gtk.Label = new Gtk.Label("<b>Pid</b>")
        label_head_pid.use_markup = true

        label_head_pname : Gtk.Label = new Gtk.Label("<b>Name</b>")
        label_head_pname.use_markup = true

        label_head_mem : Gtk.Label = new Gtk.Label("<b>Memory usage</b>")
        label_head_mem.use_markup = true

        label_head_action : Gtk.Label = new Gtk.Label("<b>Action</b>")
        label_head_action.use_markup = true

        grid.attach(label_head_pid, 0, 0)
        grid.attach(label_head_pname, 1, 0)
        grid.attach(label_head_mem, 2, 0, 2)
        grid.attach(label_head_action, 4, 0)

        for i : int = 0 to 4
            if i >= data.size
                break

            pstatus : PStatusData = data[i]

            var label_pid = new Gtk.Label(pstatus.pid.to_string())
            label_pid.margin_top = MARGIN_ROW
            label_pid.margin_bottom = MARGIN_ROW
            label_pid.margin_start = MARGIN_COL
            label_pid.margin_end = MARGIN_COL
            label_pid.halign = END

            var label_pname = new Gtk.Label(pstatus.name)
            label_pname.margin_top = MARGIN_ROW
            label_pname.margin_bottom = MARGIN_ROW
            label_pname.margin_start = MARGIN_COL
            label_pname.margin_end = MARGIN_COL
            label_pname.halign = START

            p_usage_percent : int = (int) ((double) pstatus.vm_size / (double) mem_total * 100.0)

            var label_vm_size_1 = new Gtk.Label(comma_long(pstatus.vm_size) + "KB")
            label_vm_size_1.margin_top = MARGIN_ROW
            label_vm_size_1.margin_bottom = MARGIN_ROW
            label_vm_size_1.margin_start = MARGIN_COL
            label_vm_size_1.margin_end = 2
            label_vm_size_1.halign = END

            var label_vm_size_2 = new Gtk.Label("(" + p_usage_percent.to_string() + "%)")
            label_vm_size_2.margin_top = MARGIN_ROW
            label_vm_size_2.margin_bottom = MARGIN_ROW
            label_vm_size_2.margin_start = 2
            label_vm_size_2.margin_end = MARGIN_COL
            label_vm_size_2.halign = END

            var button_kill = new Gtk.Button.with_label("Kill")
            button_kill.margin_top = MARGIN_ROW
            button_kill.margin_bottom = MARGIN_ROW
            button_kill.margin_start = MARGIN_COL
            button_kill.margin_end = MARGIN_COL
            button_kill.halign = CENTER
            var killer = new KillPidClosure(pstatus.pid, dialog)
            button_kill.clicked.connect(killer.kill_pid)

            grid.attach(label_pid, 0, i + 1)
            grid.attach(label_pname, 1, i + 1)
            grid.attach(label_vm_size_1, 2, i + 1)
            grid.attach(label_vm_size_2, 3, i + 1)
            grid.attach(button_kill, 4, i + 1)

        dialog.get_content_area().pack_start(grid, false, false)
        dialog.show_all()

        dialog.run()
        dialog.close()

    return Source.CONTINUE

class KillPidClosure
    pid : int
    dialog : Gtk.Dialog

    construct(pid : int, dialog : Gtk.Dialog)
        this.pid = pid
        this.dialog = dialog

    def kill_pid()
        var confirm = new Gtk.MessageDialog(dialog, MODAL, OTHER, OK_CANCEL, CONFIRM.printf(pid))
        confirm.show_all()
        user_choice : int = confirm.run()

        if user_choice == Gtk.ResponseType.OK
            Posix.kill(pid, Posix.Signal.KILL)
            confirm.close()
            dialog.close()
        else
            confirm.close()

def comma_long(value : long) : string
    result : string = ""
    value_s : string = value.to_string()
    i : int = value_s.length - 3

    while i >= 0
        if result == ""
            result = value_s.substring(i, 3)
        else
            result = value_s.substring(i, 3) + "," + result
        i -= 3

    rem : int = value_s.length % 3;

    if rem > 0
        if result.length > 0
            result = value_s.substring(0, rem) + "," + result
        else
            result = value_s.substring(0, rem)

    return result
