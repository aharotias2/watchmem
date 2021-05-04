class MeminfoParser : Object
{
    private const string LINE_FORMAT = "^([a-zA-Z()]+): +([0-9]+)( (kB))?$";
    private static Regex meminfo_regex;
    
    static construct
    {
        try
        {
            meminfo_regex = new Regex(LINE_FORMAT);
        }
        catch (RegexError e)
        {
            stderr.printf("RegexError: %s\nExit.\n", e.message);
            Process.exit(1);
        }
    }

    public Gee.Map<string, long> parse_meminfo()
    {
        try
        {
            Gee.Map<string, long> result = new Gee.HashMap<string, long>();
            File meminfo = File.new_for_path("/proc/meminfo");
            DataInputStream reader = new DataInputStream(meminfo.read());
            string? line = null;

            while ((line = reader.read_line()) != null)
            {
                MatchInfo matches;
                if (meminfo_regex.match(line, 0, out matches))
                {
                    string name = matches.fetch(1);
                    string value_string = matches.fetch(2);
                    long value_long = long.parse(value_string);
                    result[name] = value_long;
                }
            }

            return result;
        }
        catch (IOError e)
        {
            stderr.printf("IOError: %s\nExit.\n", e.message);
            Process.exit(1);
        }
        catch (Error e)
        {
            stderr.printf("Error: %s\nExit.\n", e.message);
            Process.exit(1);
        }
    }
}

