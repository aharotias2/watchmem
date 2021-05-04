class PStatusParser : Object
{
    private const string FILE_FORMAT = "^([a-zA-Z0-9-_]+):[ \\t]*(.+)$";
    private static Regex regex;

    static construct
    {
        try
        {
            regex = new Regex(FILE_FORMAT);
        }
        catch (RegexError e)
        {
            stderr.printf("RegexError: %s\n", e.message);
            Process.exit(1);
        }
    }

    public Gee.Map<string, string> parse_pstatus(uint pid)
    {
        Gee.Map<string, string> result = new Gee.HashMap<string, string>();
        File file = File.new_for_path(@"/proc/$(pid)/status");
        if (!file.query_exists())
        {
            return result;
        }

        try
        {
            DataInputStream reader = new DataInputStream(file.read());
            string? line = null;

            while ((line = reader.read_line()) != null)
            {
                debug("parser: %s", line);
                MatchInfo matches;
                if (regex.match(line, 0, out matches))
                {
                    string key = matches.fetch(1);
                    string value = matches.fetch(2);
                    debug("parser: %s => %s", key, value);
                    result[key.down()] = value;
                }
            }

            return result;
        }
        catch (FileError e)
        {
            stderr.printf("FileError: %s\n", e.message);
            Process.exit(1);
        }
        catch (Error e)
        {
            stderr.printf("Error: %s\n", e.message);
            Process.exit(1);
        }
    }
}
