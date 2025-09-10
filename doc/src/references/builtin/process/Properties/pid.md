/**
	Returns the process ID.
	int process::pid;
	## Returns:
		int: the PID of the process.
*/

// Example:
void main() {
	show_window("PID Test");
	process p("ping", "127.0.0.1");
	int pid = p.pid;
	alert("PID", "" + pid);
	p.close();
}
