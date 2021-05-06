class PStatusData : Object
	prop name : string
	prop pid : int
	prop vm_size : long

	construct(name : string, pid : int, vm_size : long)
		this.name = name;
		this.pid = pid;
		this.vm_size = vm_size;
