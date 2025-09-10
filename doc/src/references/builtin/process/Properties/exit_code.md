/**
	Returns the exit code of the process.
	int process::exit_code;
	## Returns:
		int: the process exit code. Usually 0 means success.
*/

// Example:
void main() {
	show_window("Exit Code Test");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	wait(200);
	p.close();
	int code = p.exit_code;
	alert("Exit Code", "" + code);
}
