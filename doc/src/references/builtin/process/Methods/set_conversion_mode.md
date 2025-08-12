/**
	Sets the output text conversion mode (for Windows code pages).
	void process::set_conversion_mode(conversion_mode mode);
	## Arguments:
		* conversion_mode mode: the mode to use. Available values are:
			- conversion_mode_none: No conversion is applied.
			- conversion_mode_oem: Converts output from OEM code page to UTF-8.
			- conversion_mode_acp: Converts output from ANSI code page to UTF-8.
	## Remarks:
		This is mainly useful on Windows when working with native system commands that use OEM or ANSI encoding.
*/

// Example:
void main() {
	show_window("Conversion Mode Example");
	process p("ping", "127.0.0.1");
	p.set_conversion_mode(conversion_mode_oem);
	wait(500);
	string output = p.consume_output();
	alert("Output", output);
	p.close();
}
