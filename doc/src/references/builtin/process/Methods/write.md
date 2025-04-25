/**
	Writes a string to the process standard input.
	void process::write(const string &in data);
	## Arguments:
		* string data: the text to send to the process.
	## Remarks:
		You must call close() after writing to commands like "sort" to signal the end of input and allow the process to output results.
*/

// Example:
void main() {
	show_window("Write Example");
	process p("sort", "");
	p.set_conversion_mode(conversion_mode_oem);
	p.write("banana\r\n");
	p.write("apple\r\n");
	p.write("orange\r\n");
	p.write("grape\r\n");
	p.close();
	string sorted = p.consume_output();
	alert("Sorted Output", sorted);
}
