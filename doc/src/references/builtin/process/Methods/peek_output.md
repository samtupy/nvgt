/**
	Returns the current contents of the process output buffer, without clearing it.
	string process::peek_output() const;
	## Returns:
		string: the current buffered output from the process.
	## Remarks:
		Use this if you want to inspect the output multiple times without removing it.
*/

// Example:
void main() {
	show_window("Peek Output Test");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	wait(100);
	string firstPeek = p.peek_output();
	alert("First Peek", firstPeek);
	wait(2000);
	string secondPeek = p.peek_output();
	alert("Second Peek", secondPeek);
	p.close();
}
