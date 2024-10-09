# Create a .ish file containing NVGT version information and other constants retrieved from ../version

import os

with open("../version", "r") as vf:
	ver_string = vf.read().rstrip()
	ver_filename_string = ver_string.replace("-", "_")
	if ver_filename_string.endswith("_stable"): ver_filename_string = ver_filename_string [:-7]
	ver = ver_string.split("-")[0]
	f = open("nvgt_version.ish", "w")
	f.write("; This is an automatically generated header containing version constants.\n\n")
	f.write(f"#define NVGTVer \"{ver}\"\n")
	f.write(f"#define NVGTVerString \"{ver_string}\"\n")
	f.write(f"#define NVGTVerFilenameString \"{ver_filename_string}\"\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_android.bin")): f.write("#define have_android_stubs\n#define have_full_android_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_linux.bin")): f.write("#define have_linux_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_mac.bin")): f.write("#define have_macos_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_windows.bin")): f.write("#define have_windows_stubs\n")
	if os.path.isfile(os.path.join("..", "doc", "nvgt.chm")): f.write("#define have_docs\n")
	f.close()
