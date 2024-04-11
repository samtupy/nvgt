# Script to generate 3rd_party_licenses.md which attributes all third party components used by nvgt.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import glob, os, shutil

license_types = {
	"zlib": "ZLib licensed code",
	"PD": "Code in the public domain",
	"BSL": "Code released under the boost software license version 1.0",
	"apache": "Code released under an Apache 2.0 or similar license",
	"LGPL": "GNU (lesser/library/linking exception) general public licensed code (lgpl)",
	"MIT": "MIT licensed code",
	"BSD": "BSD 2 or 3 clause licensed code",
}
output_filename = "3rd_party_licenses.md"
header = "# Third party code attribution\n This application may use any amount of the following copywrited code or components, though it may not use all of them or may use some of them minimally.\n\n This document may not serve as a complete reference of all copywrited material used in this application, and thus it's distrobution should be checked for other similar documents to collect a complete list of copywrited content used in this software.\n\n"
summary = " ## Summary of components\n  The following is a convenient listing of third party material that this application may use, the full text for each license can be found below the lists.\n\n"
body = ""

f = open(output_filename, "w", encoding="UTF8")
f.write(header)
for ltype in list(license_types):
	lname = license_types[ltype]
	summary += f"  ### {lname}\n"
	body += f" ## {lname}\n\n"
	for fn in glob.glob(os.path.join(ltype, "*.txt")):
		f2 = open(fn, "r", encoding="UTF8")
		ltext = f2.read().partition("\n")
		f2.close()
		summary += f"   * [{ltext[0]}](#{ltype}_{os.path.split(fn)[1][:-4]})\n"
		body += f"  ### <a id=\"{ltype}_{os.path.split(fn)[1][:-4]}\">{ltext[0]}</a>\n   " + ltext[2].replace('\n##', '\n###').replace('\n', '\n   ').replace('\n   \n', '\n\n') + "\n"
	summary += "\n"
f.write(summary)
f.write(body)
try:
	shutil.copyfile(output_filename, os.path.join("..", "src", "appendix", "third party code attributions@.md"))
except: pass
print("open source attributions written")
