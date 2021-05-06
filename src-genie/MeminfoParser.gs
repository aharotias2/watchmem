class MeminfoParser : Object
	const LINE_FORMAT : string = "^([a-zA-Z()]+): +([0-9]+)( (kB))?$"
	prop static meminfo_regex : Regex

	init
		try
			meminfo_regex = new Regex(LINE_FORMAT)
		except e : RegexError
			stderr.printf("RegexError: %s\nExit.\n", e.message)
			Process.exit(1)

	def public parse_meminfo() : dict of (string, long)
		try
			result : dict of string, long = new dict of string, long
			meminfo : File = File.new_for_path("/proc/meminfo")
			reader : DataInputStream = new DataInputStream(meminfo.read())
			line : string? = null

			while (line = reader.read_line()) != null
				matches : MatchInfo
				if meminfo_regex.match(line, 0, out matches)
					name : string = matches.fetch(1)
					value_string : string = matches.fetch(2)
					value_long : long = long.parse(value_string)
					result[name] = value_long

			return result

		except e : IOError
			stderr.printf("IOError: %s\nExit.\n", e.message)
			Process.exit(1)

		except e : Error
			stderr.printf("Error: %s\nExit.\n", e.message)
			Process.exit(1)

