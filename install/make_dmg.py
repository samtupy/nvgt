import ftplib
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
	if os.path.isdir(bundle_name): shutil.rmtree(bundle_name) # start fresh
	bundle_basename = f"{bundle_name}/Contents"
	shutil.copytree(release_path, bundle_basename + "/MacOS")
	os.mkdir(bundle_basename + "/Resources")
	os.rename(bundle_basename + "/MacOS/lib", bundle_basename + "/Frameworks")
	os.rename(bundle_basename + "/MacOS/include", bundle_basename + "/Resources/include")
	os.rename(bundle_basename + "/MacOS/stub", bundle_basename + "/Resources/stub")
	shutil.copy("macos_info.plist", bundle_basename + "/info.plist")
	shutil.copy("macos_icon.icns", bundle_basename + "/Resources/unicon.icns")

def make_dmg(src_dir, filename):
	if os.path.isfile(filename): os.remove(filename)
	subprocess.check_call(["hdiutil", "create", "-srcfolder", src_dir, filename])

def get_version_info():
	return Path("../version").read_text().strip().replace("-", "_")

relpath = "../release"
ver = get_version_info()
ftp_creds = []
if len(sys.argv) > 1:
	relpath = sys.argv[1]
	if len(sys.argv) > 2:
		ftp_creds = sys.argv[2].split(":")
make_app_bundle("nvgt.app", relpath)
make_dmg("nvgt.app", f"nvgt_{ver}.dmg")
if ftp_creds:
	try:
		ftp = ftplib.FTP("nvgt.gg", ftp_creds[0], ftp_creds[1])
		f = open(f"nvgt_{ver}.dmg", "rb")
		ftp.storbinary(f"STOR nvgt_{ver}.dmg", f)
		f.close()
		ftp.quit()
	except Exception as e:
		print(f"Warning, cannot upload to ftp {e}")
