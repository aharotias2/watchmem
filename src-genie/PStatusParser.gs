class PStatusParser : Object
	const FILE_FORMAT : string = "^([a-zA-Z0-9-_]+):[ \\t]*(.+)$"
	prop static regex : Regex

	init
		try
			regex = new Regex(FILE_FORMAT)
		except e : RegexError
			stderr.printf("RegexError: %s\n", e.message)
			Process.exit(1)

	def public parse_pstatus(pid : int) : dict of string, string
		var result = new dict of string, string
		var file = File.new_for_path(@"/proc/$(pid)/status")

		if not file.query_exists()
			return result

		try
			var reader = new DataInputStream(file.read())
			line : string? = null

			while (line = reader.read_line()) != null
				debug("parser: %s", line)
				matches : MatchInfo
				if regex.match(line, 0, out matches)
					key : string = matches.fetch(1)
					value : string = matches.fetch(2)
					debug("parser: %s => %s", key, value)
					result[key.down()] = value

			return result

		except e : FileError
			stderr.printf("FileError: %s\n", e.message)
			Process.exit(1)

		except e : Error
			stderr.printf("Error: %s\n", e.message)
			Process.exit(1)
