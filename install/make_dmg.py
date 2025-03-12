import ftplib
import os
from datetime import datetime
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys

# This function basically performs `chmod +x`, but as a Python function.
def make_executable(path):
	mode = os.stat(path).st_mode
	mode |= (mode & 0o444) >> 2  # copy R bits to X
	os.chmod(path, mode)

def make_app_bundle(bundle_name, release_path, version):
	if os.path.isdir(bundle_name):
		shutil.rmtree(bundle_name)  # start fresh
		print("Removing old app bundle...")
	print(f"Creating {bundle_name} app bundle...")
	bundle_basename = f"{bundle_name}/Contents"
	shutil.copytree(release_path, bundle_basename + "/MacOS")
	os.mkdir(bundle_basename + "/Resources")
	os.rename(bundle_basename + "/MacOS/lib", bundle_basename + "/Frameworks")
	os.rename(bundle_basename + "/MacOS/include", bundle_basename + "/Resources/include")
	os.rename(bundle_basename + "/MacOS/stub", bundle_basename + "/Resources/stub")
	if os.path.isdir(bundle_basename + "/MacOS/lib_linux"): os.rename(bundle_basename + "/MacOS/lib_linux", bundle_basename + "/Resources/lib_linux")
	if os.path.isdir(bundle_basename + "/MacOS/lib_windows"): os.rename(bundle_basename + "/MacOS/lib_windows", bundle_basename + "/Resources/lib_windows")

	# create an info.plist file for the app
	plist_path = os.path.join(bundle_basename, "Info.plist")
	create_info_plist(plist_path, version)

def make_dmg(src_dir, filename):
	if os.path.isfile(filename):
		os.remove(filename)
		print(f"Removing old disk image...")
	# Clear extended attributes
	print("Clearing extended attributes...")
	subprocess.check_call(["xattr", "-cr", src_dir])
	subprocess.check_call(["hdiutil", "create", "-srcfolder", src_dir, filename])

def get_version_info():
	return Path("../version").read_text().strip().replace("-", "_")

def create_info_plist(plist_path, version):
	print(f"Creating property list {plist_path}...")
	plist = {
		"CFBundleName": "nvgt",
		"CFBundleDisplayName": "nvgt",
		"CFBundleExecutable": "MacOS/nvgt",
		"CFBundleIdentifier": "gg.nvgt",
		"CFBundleInfoDictionaryVersion": "6.0",
		"CFBundlePackageType": "APPL",
		"CFBundleVersion": version.partition("_")[0],
		"CFBundleShortVersionString": version.partition("_")[0],
		"NSHumanReadableCopyright": f"Copyright {datetime.now().year} Sam Tupy, with contributions from the opensource community",
		"NSMicrophoneUsageDescription": "Allow NVGT scripts to access the microphone?",
		"LSEnvironment": {"MACOS_BUNDLED_APP": "1"},
		"CFBundleDocumentTypes": {
			"CFBundleTypeName": "NVGT Script",
			"CFBundleTypeRole": "Viewer",
			"LSHandlerRank": "Owner",
			"LSItemContentTypes": ["public.data"],
			"CFBundleTypeExtensions": ["nvgt"]
		},
		"UTExportedTypeDeclarations": {
			"UTTypeIdentifier": "com.nvgt.nvgt-script",
			"UTTypeConformsTo": ["public.data"],
			"UTTypeDescription": "NVGT Script",
			"UTTypeTagSpecification": {
				"public.filename-extension": ["nvgt"]
			}
		}
	}
	with open(plist_path, 'wb') as plist_file:
		plistlib.dump(plist, plist_file)

def main():
	relpath = "../release"
	ver = get_version_info()
	print(f"Creating NVGT {ver} release...")
	if len(sys.argv) > 1:
		relpath = sys.argv[1]
	make_app_bundle("nvgt.app", relpath, ver)
	make_dmg("nvgt.app", f"nvgt_{ver}.dmg")

if __name__ == "__main__":
	main()
