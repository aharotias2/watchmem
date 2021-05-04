class PStatusData : Object
{
    public string name { get; set; }
    public int pid { get; set; }
    public long vm_size { get; set; }
    
    public PStatusData(string name, int pid, long vm_size)
    {
        this.name = name;
        this.pid = pid;
        this.vm_size = vm_size;
    }
}
