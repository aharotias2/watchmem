class PStatusCollector : Object
	prop static pid_regex : Regex
	prop static kb_regex : Regex
	prop static uid : int
	prop static parser : PStatusParser

	init
		uid = (int) Posix.getuid()

		try
			pid_regex = new Regex("^[0-9]+$")
			kb_regex = new Regex("([0-9]+)")
		except e : RegexError
			stderr.printf("RegexError: %s\n", e.message)
			Process.exit(1)

		parser = new PStatusParser()

	def public collect() : list of PStatusData
		var result = new list of PStatusData

		var dir_path = "/proc"
		dir : Dir
		try
			dir = Dir.open(dir_path)
		except e : Error
			stderr.printf("Failed to open directory\n")
			Process.exit(1)

		name : string? = null
		while (name = dir.read_name()) != null
			matches : MatchInfo
			path : string = Path.build_path(Path.DIR_SEPARATOR_S, dir_path, name)
			if name == "." or name == ".." or not FileUtils.test(path, FileTest.IS_DIR) or not pid_regex.match(name, 0, out matches)
				continue

			var pid = int.parse(name);
			pstatus : dict of string, string = parser.parse_pstatus(pid)
			pstatus_uid_s : string = pstatus["uid"].split(" ")[0]
			pstatus_uid : int = int.parse(pstatus_uid_s)

			if pstatus_uid != uid or pstatus["tgid"] != pstatus["pid"] or pstatus["ppid"] != "1"
				continue

			debug("uid = %s, tgid = %s, pid = %s, ppid = %s", pstatus["uid"], pstatus["tgid"], pstatus["pid"], pstatus["ppid"])

			pname : string = pstatus["name"]
			pid_2 : int = int.parse(pstatus["pid"])
			vm_size_s : string = pstatus["vmsize"]
			matches_2 : MatchInfo
			kb_regex.match(vm_size_s, 0, out matches_2)
			vm_size : long = long.parse(matches_2.fetch(1))
			result.add(new PStatusData(pname, pid_2, vm_size))

		result.sort(compare_data)
		return result

	def compare_data(a : PStatusData, b : PStatusData) : int
		if a.vm_size < b.vm_size
			return 1
		else if a.vm_size == b.vm_size
			return 0
		else
			return -1
