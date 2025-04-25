/**
	Checks if the process is still running.
	bool process::is_running() const;
	## Returns:
		bool: true if the process is running, false otherwise.
*/

// Example:
void main() {
	show_window("Is Running Test");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	if (p.is_running()) {
		alert("Status", "The process is running.");
	}
	p.close();
}
