/**
	Returns and clears the current contents of the process output buffer.
	string process::consume_output();
	## Returns:
		string: the buffered output, which is cleared after calling.
	## Remarks:
		This is useful when capturing streamed output from long-running commands like ping or other CLI tools.
*/

// Example:
void main() {
	show_window("Process Test");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	while (p.is_running()) {
		wait(5);
		if (key_pressed(KEY_ESCAPE))
			break;
		string result = p.consume_output();
		if (result != "")
			screen_reader_speak(result);
	}
	p.close();
}
