# This is a simple script that handles replacing capatalized Angelscript addon function names with lowercase underscore equivalents. No arguments or requirements other than repls.txt. Note that this does not usually need to be ran unless an addon is updated.

import os, fnmatch, sys

def recursive(directory, wildcard):
	matches = []
	for root, dirnames, filenames in os.walk(directory):
		for filename in fnmatch.filter(filenames, wildcard):
			matches.append(os.path.join(root, filename))
	return matches

replacements={}
with open("repls.txt", "rb") as f:
	for r in f.readlines():
		r=r.rstrip()
		p=r.split(b", ")
		if len(p)<2: continue
		replacements[p[0]]=p[1]

files=recursive(os.path.dirname(__file__), "*.cpp");
for f in files:
	with open(f, "rb") as F:
		data=F.read()
	for search in replacements:
		data=data.replace(search, replacements[search])
	with open(f, "wb") as F:
		F.write(data)
