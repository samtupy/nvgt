# Script to generate 3rd_party_licenses.md which attributes all third party components used by nvgt.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2025 Sam Tupy
# license: zlib

import glob, mistune, os, shutil

license_types = {
	"zlib": "ZLib licensed code",
	"PD": "Code in the public domain",
	"BSL": "Code released under the boost software license version 1.0",
	"apache": "Code released under an Apache 2.0 or similar license",
	"LGPL": "GNU (lesser/library/linking exception) general public licensed code (lgpl)",
	"MIT": "MIT licensed code",
	"BSD": "BSD 2 or 3 clause licensed code",
}

output_filename = "3rd_party_licenses"
html_base = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n<title>{title}</title>\n</head>\n<body>\n{body}\n</body>\n</html>\n"
header = "# Third party code attributions\nThis application may use any amount of the following copywrited code or components, though it may not use all of them or may use some of them minimally.\n\nThis document may not serve as a complete reference of all copywrited material used in this application, and thus it's distribution should be checked for other similar documents to collect a complete list of copywrited content used in this software.\n\n"

def main():
	summary = "## Summary of components\nThe following is a convenient listing of third party material that this application may use, the full text for each license can be found below the lists.\n\n"
	body = ""
	f = open(f"{output_filename}.md", "w", encoding="UTF8")
	f.write(header)
	for ltype in list(license_types):
		lname = license_types[ltype]
		summary += f"### {lname}\n"
		body += f"## {lname}\n\n"
		for fn in glob.glob(os.path.join(ltype, "*.txt")):
			f2 = open(fn, "r", encoding="UTF8")
			ltext = f2.read().partition("\n")
			f2.close()
			summary += f"* [{ltext[0]}](#{ltype}_{os.path.split(fn)[1][:-4]})\n"
			body += f"### <a id=\"{ltype}_{os.path.split(fn)[1][:-4]}\">{ltext[0]}</a>\n" + ltext[2].replace('\n##', '\n###') + "\n"
		summary += "\n"
	f.write(summary)
	f.write(body)
	f.close()
	f = open(f"{output_filename}.html", "w")
	f.write(html_base.format(title = "third party code attributions", body = mistune.html(header + summary + body)))
	f.close()
	try:
		shutil.copyfile(f"{output_filename}.md", os.path.join("..", "src", "appendix", "Third Party Code Attributions@.md"))
		if os.path.isdir(os.path.join("..", "..", "release")):
			if not os.path.isdir(os.path.join("..", "..", "release", "lib")): os.mkdir(os.path.join("..", "..", "release", "lib"))
			shutil.copyfile(f"{output_filename}.html", os.path.join("..", "..", "release", "lib", f"{output_filename}.html"))
	except: pass

if __name__ == "__main__":
	main()
