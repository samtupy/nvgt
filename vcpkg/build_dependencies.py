# Script to build all of NVGT's dependencies with vcpkg, setting them up for NVGT builds and optionally creating redistributable archives for the dependencies.
# This only supports the triplets that we currently use as well as IOS.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import glob
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys

vcpkg_path = Path(os.path.dirname(__file__)) / "bin" / ("vcpkg" if sys.platform != "win32" else "vcpkg.exe")

def bootstrap_vcpkg():
	os.chdir(os.path.dirname(__file__))
	if vcpkg_path.exists() and vcpkg_path.is_file():
		return
	if platform.System() == "Windows":
		subprocess.check_output("bin/bootstrap-vcpkg.bat")
	else:
		subprocess.check_output("bin/bootstrap-vcpkg.sh")
def build(triplet):
	if not triplet:
		# Try to determine, logic probably could be improved
		if sys.platform == "win32": triplet = "x64-windows"
		elif sys.platform == "darwin": triplet = "arm64-osx"
		elif sys.platform == "linux": triplet = "x64-linux"
		else: sys.exit("unable to determine platform, please pass a triplet explicitly.")
	try: subprocess.check_output([vcpkg_path, "install", "--triplet", triplet])
	except subprocess.CalledProcessError as cpe: sys.exit(f"Building packages for {triplet} failed with error code {cpe.returncode}.\n{cpe.output.decode()}")
	dev_basename = ""
	if "-windows" in triplet: dev_basename = "windev"
	elif "-osx" in triplet: dev_basename = "macosdev"
	elif "-linux" in triplet: dev_basename = "lindev"
	elif "-android" in triplet: dev_basename = "droidev"
	elif "-ios" in triplet: dev_basename = "iosdev"
	out_dir = Path("..") / dev_basename
	out_dir.mkdir(parents=True, exist_ok=True)
	if (Path("vcpkg_installed") / triplet / "bin").exists(): shutil.copytree(Path("vcpkg_installed") / triplet / "bin", out_dir / "bin", dirs_exist_ok = True)
	if (Path("vcpkg_installed") / triplet / "debug" / "bin").exists(): shutil.copytree(Path("vcpkg_installed") / triplet / "debug" / "bin", out_dir / "debug" / "bin", dirs_exist_ok = True)
	shutil.copytree(Path("vcpkg_installed") / triplet / "debug" / "lib", out_dir / "debug" / "lib", dirs_exist_ok = True)
	shutil.copytree(Path("vcpkg_installed") / triplet / "include", out_dir / "include", dirs_exist_ok = True)
	shutil.copytree(Path("vcpkg_installed") / triplet / "lib", out_dir / "lib", dirs_exist_ok = True)
	if triplet == "arm64-osx": macos_fat_binaries()
	elif triplet == "x64-windows": windows_lib_rename()
	if triplet.endswith("osx") or triplet.endswith("linux"): remove_duplicates(dev_basename)
	try:
		shutil.rmtree(out_dir / "lib" / "cmake")
		shutil.rmtree(out_dir / "lib" / "pkgconfig")
		shutil.rmtree(out_dir / "debug" / "lib" / "cmake")
		shutil.rmtree(out_dir / "debug" / "lib" / "pkgconfig")
	except FileNotFoundError: pass
	if do_archive:
		shutil.make_archive("../" + dev_basename, format = "zip", root_dir = out_dir)
		with Path("../" + dev_basename + ".zip").open("rb") as f, Path("../" + dev_basename + ".zip.blake2b").open("w") as hf:
			h = hashlib.blake2b()
			h.update(f.read())
			hf.write(h.hexdigest())
def macos_fat_binaries():
	"""We must manually build libffi and openssl for x64 as well and then run lipo on both of our builds to create universal binaries for them. This is meant to be run after the macosdev directory is created."""
	try: subprocess.check_output([vcpkg_path, "install", "--classic", "--triplet", "x64-osx", "--overlay-ports=ports", "--overlay-triplets=triplets", "libffi", "openssl"])
	except subprocess.CalledProcessError as cpe: sys.exit(f"Building libffi and openssl for x64-osx failed with error code {cpe.returncode}.\n{cpe.output.decode()}")
	for f in ["libcrypto.a", "libffi.a", "libssl.a"]:
		os.remove("../macosdev/debug/lib/" + f)
		os.remove("../macosdev/lib/" + f)
		subprocess.check_output(["lipo", "-create", "bin/installed/x64-osx/debug/lib/" + f, "vcpkg_installed/arm64-osx/debug/lib/" + f, "-output", "../macosdev/debug/lib/" + f])
		subprocess.check_output(["lipo", "-create", "bin/installed/x64-osx/lib/" + f, "vcpkg_installed/arm64-osx/lib/" + f, "-output", "../macosdev/lib/" + f])
def windows_lib_rename():
	"""Sometimes windows libraries get built with annoying names that complicate build scripts. We have to handle them somewhere, may as well be here. Temporarily we'll also copy angelscript as angelscript-nc."""
	renames = [
		("libcrypto.lib", "crypto.lib"),
		("libssl.lib", "ssl.lib"),
		("SDL3-static.lib", "SDL3.lib"),
		("utf8proc_static.lib", "utf8proc.lib")
	] # end renames list
	for r in renames:
		if (os.path.exists("../windev/lib/" + r[1])): os.remove("../windev/lib/" + r[1])
		os.rename("../windev/lib/" + r[0], "../windev/lib/" + r[1])
	shutil.copyfile("../windev/lib/angelscript.lib", "../windev/lib/angelscript-nc.lib")
def remove_duplicates(dev_basename):
	"""A couple libraries on Linux and MacOS might have created duplicate versions of themselves because of symlinks, lets get rid of them."""
	for lib in ["libarchive", "libgit2"]:
		for libdir in ["debug/lib", "lib"]:
			versions = glob.glob(f"../{dev_basename}/{libdir}/{lib}*")
			if len(versions) < 2: continue
			versions.sort(key = len)
			for v in versions[1:]: os.remove(v)

if __name__ == "__main__":
	triplets = []
	do_archive = False
	if len(sys.argv) > 1:
		for arg in sys.argv[1:]:
			if arg == "--archive": do_archive = True
			else: triplets.append(arg)
	if len(triplets) < 1: triplets.append("")
	bootstrap_vcpkg()
	for t in triplets: build(t)
