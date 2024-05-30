from pathlib import Path
import subprocess

def make_dmg(src_dir, filename):
	subprocess.check_call(["hdiutil", "create", "-srcfolder", src_dir, filename])

def get_version_info():
	return Path("../version").read_text().replace("-", "_")

make_dmg("../release", "nvgt_" + get_version_info() + ".dmg")
