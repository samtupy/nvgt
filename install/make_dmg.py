import glob
import os
from pathlib import Path
import shutil
import subprocess
import sys

# This function basically performs `chmod +x`, but as a Python function. Thanks to https://stackoverflow.com/questions/12791997/
def make_executable(path):
	mode = os.stat(path).st_mode
	mode |= (mode & 0o444) >> 2    # copy R bits to X
	os.chmod(path, mode)

def make_app_bundle(bundle_name, release_path):
	bundle_basename = f"{bundle_name}/Contents"
	shutil.copytree(release_path, bundle_basename + "/MacOS")
	os.mkdir(bundle_basename + "/Resources")
	os.rename(bundle_basename + "/MacOS/stub", bundle_basename + "/Resources/stub")

def make_dmg(src_dir, filename):
	subprocess.check_call(["hdiutil", "create", "-srcfolder", src_dir, filename])

def get_version_info():
	return Path("../version").read_text().replace("-", "_")

relpath = "../release"
if len(sys.argv) > 1:
	relpath = " ".join(sys.argv[1:])
make_app_bundle("nvgt.app", relpath)
