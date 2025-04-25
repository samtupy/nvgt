/**
	Closes the process input stream and terminates the process if it's still running.
	void process::close();
	## Remarks:
		If the process is still running after attempting to close input, it will be forcefully terminated after a short wait period.
*/

// Example:
void main() {
	show_window("Close Test");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	wait(200);
	p.close();
	alert("Status", "Process closed.");
}
