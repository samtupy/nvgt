# NVGT's Documentation generator. This script is not designed to be particularly fast, pretty or configurable, as it should run infrequently and at this time we cannot imagine other ways in which we would like to generate our docs. Just run the script in the same directory as the doc/src folder and if there are no errors, the docs are generated. Requires the mistune module for rendering markdown from pip and the html help workshop from microsoft to create the .chm file.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import json
import mistune
import os
import shutil
import sys

html_base = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n<title>{title}</title>\n</head>\n<body>\n{body}\n</body>\n</html>\n"
liquid_base = "---\nlayout: default.liquid\ntitle: {title}\n---\n\n{body}"
hhc_base = "<li><object type=\"text/sitemap\"><param name=\"Name\" value=\"{name}\"></object></li>\n"
hhk_base = "<li><object type=\"text/sitemap\"><param name=\"Name\" value=\"{name}\"><param name=\"Local\" value=\"{path}\"></object></li>\n"
md_nav_link = "[{text}]({url})"

def make_topicname(path):
	"""Takes any path and converts it into a topic name according to the rules in doc/src/advanced/docgen+.md."""
	if not os.path.exists(path):
		print(f"titlecase_topicname can't find {path}, skipping.\n")
		return ""
	if path.endswith("+.md"):
		return open(path, "r", encoding = "UTF8").readline().strip("# \n") # The topic name is determined from the first line of such a file.
	else:
		name = os.path.split(path)[1].lstrip("!-_") # The topic name is determined by removing any prepended punctuation characters then titlecasing the result in some cases.
		if os.path.isfile(path): name = os.path.splitext(name)[0]
		if name.endswith("@"): name = name[:-1]
		return name

def list_topics_via_index(tree, root):
	"""Parses a given .index.json file and fills the tree with topic paths and descriptions."""
	try:
		index = json.load(open(os.path.join(root, ".index.json"), "r", encoding = "UTF8"))
	except json.JSONDecodeError:
		print(f"Unable to parse {root}/.index.json!\n")
		return
	for t in index:
		elem = {"name": ""}
		if type(t) == list:
			elem["name"] = t[1]
			t = t[0]
		tp = os.path.join(root, t)
		tree[root]["topics"].append(tp)
		if not elem["name"]: elem["name"] = make_topicname(tp)
		if os.path.isfile(tp):
			elem["path"] = tp
			if tp.endswith("@.md"): elem["markdown"] = None
		else:
			elem["topics"] = []
			if os.path.isfile(os.path.join(tp, ".MDRoot")):
				elem["markdown"] = None # Will contain a file object later.
		tree[tp] = elem

def list_topics_via_walk(tree, root, dirs, files):
	"""Adds topics to the tree given information from a step of a directory walk."""
	items = list(dirs)
	for f in files:
		if f.endswith(".md") or f.endswith(".nvgt"): items.append(f)
	items = sorted(items, key = str.casefold)
	for i in items:
		tp = os.path.join(root, i)
		tree[tp] = {"name": make_topicname(tp)}
		if os.path.isfile(tp):
			tree[tp]["path"] = tp
			if tp.endswith("@.md"): tree[tp]["markdown"] = None
		else:
			tree[tp]["topics"] = []
			if os.path.isfile(os.path.join(tp, ".MDRoot")):
				tree[tp]["markdown"] = None # Will contain a file object later.
		tree[root]["topics"].append(tp)

def make_topic_map():
	"""Scans the doc/src directory for topics according to the rules in doc/src/advanced/docgen+.md."""
	tree = {"src": {"name": "NVGT Documentation", "topics": [], "markdown": None}}
	for root, dirs, files in os.walk("src"):
		if os.path.isfile(os.path.join(root, ".index.json")): list_topics_via_index(tree, root)
		else: list_topics_via_walk(tree, root, dirs, files)
	return tree

def make_slug(path):
	"""Used for html and markdown filenames, returns a filename safe slug derived from the given path which is expected to be valid."""
	# Todo: Should we use something like python-slugify? In the end I'm not sure are topic names require that.
	return os.path.splitext(path)[0].replace(os.path.sep, "_").replace(" ", "_").replace("+", "").replace("(", "").replace(")", "").replace(".", "_").replace("!", "").replace("@", "").replace("-", "")

def make_chm_filename(path):
	"""Derive a temporary html filename from a topic path for the creation of a .chm file. Path is expected to be valid."""
	return make_slug(os.path.splitext(path)[0][4:]) + ".htm"

def create_markdown_document(path):
	"""Given a path to a markdown root, creates the markdown document and returns the file object used to create the document for writing. The markdown directory is expected to exist by the time this is called, path is expected to be valid, and this function shouldn't be called more than once per path."""
	filename = ""
	if filename.lower().endswith("@.md"): filename = filename[:-4]
	if path == "src": # edgecase (rootmost document)
		filename = os.path.join("md", "nvgt.md")
	else: filename = os.path.join("md", make_slug("nvgt_" + path[4:]) + ".md")
	return open(filename, "w", encoding = "utf8")

def get_markdown_document(tree, path):
	"""Returns a tuple containing a file object in which markdown should be written to for a topic as well as an integer containing a heading level that this topic should be printed as within the given markdown document."""
	if not tree or not path: return (None, 0) # We check this to avoid a potential infinent loop.
	root = ""
	temp_path = path # We'll slowly break this down until we find the root document.
	depth = temp_path.count(os.path.sep) # Todo: Perhaps convert to pathlib?
	while not root:
		if not temp_path in tree: return (None, 0) # if this edgecase is reached something has gone terribly wrong.
		if "markdown" in tree[temp_path]: # Root found!
			if not tree[temp_path]["markdown"]: # This markdown file hasn't been created, do that now.
				tree[temp_path]["markdown"] = create_markdown_document(temp_path)
			if temp_path != "src": depth -= temp_path.count(os.path.sep) -1
			return (tree[temp_path]["markdown"], depth)
		temp_path = os.path.split(temp_path)[0]
	return (None, 0)

def parse_nvgt_markdown(tree, path, data):
	"""Parses a .nvgt file within the doc/src directory to derive markdown from it according to the rules in doc/src/advanced/docgen+.md. The file's data is expected to be provided."""
	markdown = "# " + tree[path]["name"] + "\n"
	lines = data.split("\n")
	in_markdown = data.startswith("/**")
	if not in_markdown: markdown += "\n```NVGT\n" # Starting with code block.
	linebreaks = False # if false each line is a paragraph.
	started_codeblock = False # A codeblock could start after a // Example comment or before the start of code if such a comment is missing.
	for l in lines:
		ls = l.strip()
		if not ls: continue
		if in_markdown and ls == "/**\\": linebreaks = True # User controls paragraphs with blank lines.
		if ls.startswith("/**"):
			if not markdown: markdown += "```\n" # end code block.
			in_markdown = True
			started_codeblock = False
		elif in_markdown and ls == "*/":
			in_markdown = False
			started_codeblock = False
		elif in_markdown:
			was_codeblock = started_codeblock
			if ls == "```": started_codeblock = not started_codeblock
			if not was_codeblock and not started_codeblock and not linebreaks: markdown += "\n"
			markdown += l.lstrip() + "\n"
		elif not started_codeblock and (l.lower().startswith("// example") or l.lower().startswith("//example")):
			markdown += "\n## Example:\n\n```NVGT\n"
			started_codeblock = True
		else:
			if not started_codeblock:
				markdown += "```NVGT\n"
				started_codeblock = True
			# Todo: The markdown parser is ending codeblocks if # characters are in code sometimes such as #include. For now we hack around that, but it should be properly fixed later if possible.
			markdown += l.replace("#", "!!!") + "\n"
	if started_codeblock and not in_markdown: markdown += "```\n\n" # end code block.
	return markdown

def process_topic(tree, path, indent):
	"""Processes a topic. Returns the plain text version of a topic given it's path, including indenting it's text, this is used in the output_documentation_section function below. Prior to returning the plaintext, outputs the chm source and markdown formats for this topic. Tree is required for cached topic names."""
	if not os.path.isfile(path): return
	data = ""
	try :
		with open(path, "r", encoding = "UTF8") as f:
			data = f.read()
	except Exception as e:
		print(f"Error processing {path}: {e!s}")
		sys.exit(1)

	markdown = "\n"
	if path.endswith(".nvgt"): markdown += parse_nvgt_markdown(tree, path, data)
	else: markdown += data
	# Print the html which will be used for the .chm file.
	chm = make_chm_filename(path)
	if chm:
		try: #Todo: cleanup next line, particularly figure out how to get rid of the <pre><code> replacements.
			open(os.path.join("chm", chm), "w", encoding = "UTF8").write(html_base.format(title = tree[path]["name"], body = mistune.html(markdown).replace("<p><code>", "<pre><code>").replace("</code></p>", "</code></pre>").replace("!!!", "#")))
		except Exception as e: print(f"Error creating {chm}, {e}\n")
	# output the markdown of the topic.
	md_file, heading_indent = get_markdown_document(tree, path)
	if md_file is not None:
		# Check if this is the first topic in a category who's heading has just been written. If it is and if the markdown we are handling also begins with a heading that is the same name as the category, delete the duplicate heading from the markdown we are about to print.
		parent_cat = os.path.split(path)[0]
		if "category_heading" in tree[parent_cat]:
			del(tree[parent_cat]["category_heading"])
			if markdown[:len(tree[parent_cat]["name"]) + 32].lstrip("\n\t# ").lower().startswith(tree[parent_cat]["name"].lower()):
				markdown = "\n" + markdown[1:].partition("\n")[2].replace("!!!", "#")
				heading_indent -= 1
				indent -= 1
		# fix heading levels in the document.
		heading = "#" * heading_indent
		lines = markdown.split("\n")[1:]
		in_codeblock = False
		for i, l in enumerate(lines):
			if not l: continue
			if l.lstrip().startswith("```"): in_codeblock = not in_codeblock
			if in_codeblock or not l.lstrip().startswith("#"): continue
			lines[i] = heading + l.lstrip("\t ")[1:] # [1:] because previously we globally replaced # with contents of heading variable, so now we must strip first # to simulate
		md_file.write('\n'.join(lines).replace('!!!', '#') + "\n\n")
	# Now we prepare to return the plain text/indented version of the document.
	tab_indent = "\t" * indent
	tab_heading_indent = "\t" * (indent -1)
	for i, l in enumerate(lines):
		if l == "": continue
		elif l.strip("\t") == "```":
			lines[i] = "```"
			continue # Lines that are equal to "```" will not be included in the output.
		if l.lstrip("\t").startswith("#"): lines[i] = tab_heading_indent + l.strip("\t#: ") + ":"
		else: lines[i] = tab_indent + l.replace("!!!", "#")
	return "\n".join([i for i in lines if i != "```"]) + "\n\n"

def output_documentation_section(tree, path, txt_output_file, hhc_output_file, hhk_output_file, indent = 0):
	"""Recursively output a section of documentation to the file objects given."""
	md_output_file, heading_indent = get_markdown_document(tree, path)
	if path != "src" and "topics" in tree[path]:
		md_output_file.write(("#" * heading_indent) + " " + tree[path]["name"] + "\n")
		tree[path]["category_heading"] = True # edgecase: Sometimes the first topic in a category will begin with a heading with the same name of the category, thus creating a double heading that we don't want. Mark the fact that a category was hidden so that the first processed topic in the category can avoid printing such a double heading.
		txt_output_file.write(("\t" * (indent -1)) + tree[path]["name"] + ":\n")
		hhc_output_file.write(hhc_base.format(name = tree[path]["name"]) + "<ul>\n")
	md_extra_newline = False
	md_next_root = None
	md_nav_last_was_subsection = False # Edgecase: When traversing out of a subsection then directly into a new subsection with a different MDRoot, print a heading.
	for idx, t in enumerate(tree[path]["topics"]):
		if md_extra_newline:
			md_output_file.write("\n")
			md_extra_newline = False
		if "path" in tree[t]:
			txt_output_file.write(process_topic(tree, t, indent + 1))
			md_nav_last_was_subsection = False
			if "markdown" in tree[t]: # Markdown root document, print a navigation link.
				md_next_root, next_indent = get_markdown_document(tree, t)
				if md_next_root:
					# If the element before or after this one is also a link, prepend "* " to the links to make a markdown list.
					if idx > 0 and "markdown" in tree[tree[path]["topics"][idx -1]] or idx < len(tree[path]["topics"]) -1 and "markdown" in tree[tree[path]["topics"][idx+1]]: md_output_file.write("* ");
					md_output_file.write(md_nav_link.format(url = os.path.split(md_next_root.name.lower())[1], text = tree[t]["name"]) + "\n")
			if os.path.isfile(os.path.join("chm", make_chm_filename(t))):
				hhc_output_file.write(hhk_base.format(name = tree[t]["name"], path = make_chm_filename(t))) # hhk_base string template should work here.
				hhk_output_file.write(hhk_base.format(name = tree[t]["name"], path = make_chm_filename(t)))
		elif "topics" in tree[t]:
			if "markdown" in tree[t]: # Markdown root document, print a navigation link.
				if md_nav_last_was_subsection: md_output_file.write(("#" * heading_indent) + "# " + tree[t]["name"] + "\n")
				md_next_root, next_indent = get_markdown_document(tree, t)
				if md_next_root:
					if idx > 0 and "markdown" in tree[tree[path]["topics"][idx -1]] or idx < len(tree[path]["topics"]) -1 and "markdown" in tree[tree[path]["topics"][idx+1]]: md_output_file.write("* ");
					md_output_file.write(md_nav_link.format(url = os.path.split(md_next_root.name.lower())[1], text = tree[t]["name"]) + "\n")
				md_nav_last_was_subsection = False
			elif md_next_root: # end of nav block, in this case md_next_root was set by the previous iteration of this loop where as the subsection we are dealing with doesn't contain one.
				md_extra_newline = True
				md_next_root = None
			else: md_nav_last_was_subsection = True
			output_documentation_section(tree, t, txt_output_file, hhc_output_file, hhk_output_file, indent + 1)
	hhc_output_file.write("</ul>\n")
	md_output_file.write("\n")

def output_html_section(md_path, title):
	"""Given a path to a completed markdown document, outputs the html version of it, including some replacements in regards to navigation links."""
	f = open(md_path, "r", encoding = "utf8")
	md = f.read()
	f.close()
	# Todo: A bit hacky and not cross project compatible here, sorry.
	md = md.replace("](nvgt_", "](").replace(".md)", ".html)")
	md_path = os.path.split(md_path)[1]
	if md_path == "nvgt.md": md_path = "index.html"
	elif md_path.startswith("nvgt_"): md_path = md_path[5:]
	if md_path.endswith(".md"): md_path = md_path[:-3] + ".html"
	html_body = mistune.html(md)
	md_path = md_path.lower()
	with open(os.path.join("html", md_path), "w", encoding = "utf8") as f:
		f.write(html_base.format(title = title, body = html_body))
	# The NVGT website is built using cobalt (a tiny static site generator that uses liquid templates), and an html version of the docs are hosted on that website. We want this version of the docs to use the liquid layout that the static site uses, so we simply create very basic .liquid files in the nvgt repo's web directory, if that exists.
	liquid_path = md_path[:-5] + ".liquid"
	if os.path.isdir(os.path.join("..", "web", "src", "docs")):
		with open(os.path.join("..", "web", "src", "docs", liquid_path), "w", encoding = "utf8") as f:
			f.write(liquid_base.format(title = title, body = html_body.replace("{{", "\\{\\{").replace("}}", "\\}\\}")))


def main():
	"""NVGT Documentation Generator."""
	tree = make_topic_map()
	# json.dump(tree, open("docgen.json", "w"), indent = 1) # Uncomment if needed for debugging.
	if not os.path.exists("chm"): os.mkdir("chm")
	if not os.path.exists("html"): os.mkdir("html")
	if not os.path.exists("md"): os.mkdir("md")
	website_exists = False
	if os.path.exists(os.path.join("..", "web")):
		if not os.path.exists(os.path.join("..", "web", "src", "docs")): os.makedirs(os.path.join("..", "web", "src", "docs"))
		website_exists = True
	txt_output = open("nvgt.txt", "w", encoding = "UTF8")
	hhc_output = open("chm/nvgt.hhc", "w")
	hhc_output.write("<html>\n<head>\n</head>\n<body>\n<ul>\n")
	hhk_output = open("chm/nvgt.hhk", "w")
	hhk_output.write("<html>\n<head>\n</head>\n<body>\n<ul>\n")
	output_documentation_section(tree, "src", txt_output, hhc_output, hhk_output)
	hhc_output.write("</body>\n</html>\n") # </ul> in this case is written by output_documentation_section.
	hhk_output.write("</ul>\n</body>\n</html>\n")
	txt_output.close()
	# Close the still open handles to markdown documents and output their html.
	for t in tree:
		if not "markdown" in tree[t]: continue
		f = tree[t]["markdown"]
		fn = f.name
		f.close()
		output_html_section(fn, tree[t]["name"])
	hhc_output.close()
	hhk_output.close()
	hhp_output=open(os.path.join("chm", "nvgt.hhp"), "w")
	hhp_output.write("[OPTIONS]\nContents file=nvgt.hhc\nIndex file=nvgt.hhk\nDefault topic=Introduction.htm\nTitle=NVGT Documentation\n\n[FILES]\n")
	for f in os.listdir("chm"):
		if f.endswith(".htm"): hhp_output.write(f + "\n")
	hhp_output.close()
	# Todo: Make the following more generic, for example if someone doesn't have windows installed on the C drive.
	if os.path.isfile("C:\\Program Files (x86)\\HTML Help Workshop\\hhc.exe"):
		os.system("\"C:\\Program Files (x86)\\HTML Help Workshop\\hhc.exe\" chm\\nvgt.hhp>nul")
		if os.path.isfile(os.path.join("chm", "nvgt.chm")):
			if os.path.isfile("nvgt.chm"): os.remove("nvgt.chm")
			os.rename(os.path.join("chm", "nvgt.chm"), "nvgt.chm")
			if website_exists: shutil.copy("nvgt.chm", os.path.join("..", "web", "src", "docs"))
		if website_exists:
			shutil.make_archive(os.path.join("..", "web", "src", "docs", "nvgt-html"), "zip", "html")
			shutil.make_archive(os.path.join("..", "web", "src", "docs", "nvgt-markdown"), "zip", "md")
			shutil.copy("nvgt.txt", os.path.join("..", "web", "src", "docs"))

if __name__ == "__main__":
	main()
