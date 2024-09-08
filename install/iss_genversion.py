# Create a .ish file containing NVGT version information and other constants retrieved from ../version

import os
import io
import zipfile
import urllib.request as ur

archive_data = io.BytesIO(ur.urlopen("https://github.com/thenickdude/InnoCallback/releases/download/v0.1/innocallback.zip").read())
archive = zipfile.ZipFile(archive_data)
archive.extract("InnoCallback.dll")
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
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_linux.bin")): f.write("#define have_linux_stubs\n#define have_full_linux_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_linux_upx.bin")): f.write("#define have_upx_linux_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_mac.bin")): f.write("#define have_macos_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_windows.bin")): f.write("#define have_windows_stubs\n#define have_full_windows_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_windows_nc.bin")): f.write("#define have_windows_nc_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_windows_upx.bin")): f.write("#define have_windows_upx_stubs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_windows_nc_upx.bin")): f.write("#define have_windows_nc_upx_stubs\n")
	if os.path.isfile(os.path.join("..", "doc", "nvgt.chm")): f.write("#define have_docs\n")
	if os.path.isfile(os.path.join("..", "release", "stub", "nvgt_android.bin")): f.write("#define have_android_stubs\n#define have_full_android_stubs\n")
	f.close()
