# Script to build all of NVGT's dependencies with vcpkg, setting them up for NVGT builds and optionally creating redistributable archives for the dependencies.
# This only supports the triplets that we currently use as well as IOS.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2025 Sam Tupy
# license: zlib

import hashlib
from pathlib import Path
import shutil
import subprocess
import sys

vcpkg_path = Path(__file__, "..", "bin", "vcpkg" if sys.platform != "win32" else "vcpkg.exe").resolve()
vcpkg_installed_path = Path(__file__, "..", "vcpkg_installed").resolve()
repo_path = Path(__file__).parents[1]

def bootstrap_vcpkg():
	if vcpkg_path.exists() and vcpkg_path.is_file():
		return
	if sys.platform == "win32":
		subprocess.check_output(vcpkg_path.parent / "bootstrap-vcpkg.bat")
	else:
		subprocess.check_output(vcpkg_path.parent / "bootstrap-vcpkg.sh")
def build(triplet = "", do_archive = False, out_dir = ""):
	if not triplet:
		# Try to determine, logic probably could be improved
		if sys.platform == "win32": triplet = "x64-windows"
		elif sys.platform == "darwin": triplet = "arm64-osx"
		elif sys.platform == "linux": triplet = "x64-linux"
		else: sys.exit("unable to determine platform, please pass a triplet explicitly.")
	bootstrap_vcpkg()
	try: subprocess.check_output([vcpkg_path, "install", "--triplet", triplet, "--x-manifest-root", vcpkg_path.parents[1]])
	except subprocess.CalledProcessError as cpe: sys.exit(f"Building packages for {triplet} failed with error code {cpe.returncode}.\n{cpe.output.decode()}")
	dev_basename = ""
	if "-windows" in triplet: dev_basename = "windev"
	elif "-osx" in triplet: dev_basename = "macosdev"
	elif "-linux" in triplet: dev_basename = "lindev"
	elif "-android" in triplet: dev_basename = "droidev"
	elif "-ios" in triplet: dev_basename = "iosdev"
	if not out_dir: out_dir = repo_path / dev_basename
	else: out_dir = Path(out_dir)
	out_dir.mkdir(parents=True, exist_ok=True)
	if (vcpkg_installed_path / triplet / "bin").exists(): shutil.copytree(vcpkg_installed_path / triplet / "bin", out_dir / "bin", dirs_exist_ok = True)
	if (vcpkg_installed_path / triplet / "debug" / "bin").exists(): shutil.copytree(vcpkg_installed_path / triplet / "debug" / "bin", out_dir / "debug" / "bin", dirs_exist_ok = True)
	shutil.copytree(vcpkg_installed_path / triplet / "debug" / "lib", out_dir / "debug" / "lib", dirs_exist_ok = True)
	shutil.copytree(vcpkg_installed_path / triplet / "include", out_dir / "include", dirs_exist_ok = True)
	shutil.copytree(vcpkg_installed_path / triplet / "lib", out_dir / "lib", dirs_exist_ok = True)
	if triplet == "arm64-osx": macos_fat_binaries(out_dir)
	elif triplet == "x64-windows": windows_lib_rename(out_dir)
	if triplet.endswith("osx") or triplet.endswith("linux"): remove_duplicates(out_dir)
	try:
		shutil.rmtree(out_dir / "lib" / "cmake")
		shutil.rmtree(out_dir / "lib" / "pkgconfig")
		shutil.rmtree(out_dir / "debug" / "lib" / "cmake")
		shutil.rmtree(out_dir / "debug" / "lib" / "pkgconfig")
	except FileNotFoundError: pass
	if do_archive:
		shutil.make_archive(out_dir, format = "zip", root_dir = out_dir)
		with out_dir.with_suffix(".zip").open("rb") as f, out_dir.with_suffix(".zip.blake2b").open("w") as hf:
			h = hashlib.blake2b()
			h.update(f.read())
			hf.write(h.hexdigest())
def macos_fat_binaries(out_dir):
	"""We must manually build libffi and openssl for x64 as well and then run lipo on both of our builds to create universal binaries for them. This is meant to be run after the macosdev directory is created."""
	try: subprocess.check_output([vcpkg_path, "install", "--classic", "--triplet", "x64-osx", "--overlay-ports=" + str(Path(__file__).parent / "ports"), "--overlay-triplets=" + str(Path(__file__).parent / "triplets"), "libffi", "openssl"])
	except subprocess.CalledProcessError as cpe: sys.exit(f"Building libffi and openssl for x64-osx failed with error code {cpe.returncode}.\n{cpe.output.decode()}")
	for f in ["libcrypto.a", "libffi.a", "libssl.a"]:
		(out_dir / "debug" / "lib" / f).unlink()
		(out_dir / "lib" / f).unlink()
		subprocess.check_output(["lipo", "-create", vcpkg_path.parent / "installed" / "x64-osx" / "debug" / "lib" / f, vcpkg_installed_path / "arm64-osx" / "debug" / "lib" / f, "-output", out_dir / "debug" / "lib" / f])
		subprocess.check_output(["lipo", "-create", vcpkg_path.parent / "installed" / "x64-osx" / "lib" / f, vcpkg_installed_path / "arm64-osx" / "lib" / f, "-output", out_dir / "lib" / f])
def windows_lib_rename(out_dir):
	"""Sometimes windows libraries get built with annoying names that complicate build scripts. We have to handle them somewhere, may as well be here. Temporarily we'll also copy angelscript as angelscript-nc."""
	renames = [
		("libcrypto.lib", "crypto.lib"),
		("libssl.lib", "ssl.lib"),
		("SDL3-static.lib", "SDL3.lib"),
		("utf8proc_static.lib", "utf8proc.lib")
	] # end renames list
	for lib in ["debug/lib", "lib"]:
		for r in renames:
			(out_dir / lib / r[0]).replace(out_dir / lib / r[1])
	shutil.copyfile(out_dir / "lib" / "angelscript.lib", out_dir / "lib" / "angelscript-nc.lib")
def remove_duplicates(out_dir):
	"""A couple libraries on Linux and MacOS might have created duplicate versions of themselves because of symlinks, lets get rid of them."""
	for lib in ["libarchive", "libgit2"]:
		for libdir in ["debug/lib", "lib"]:
			versions = list((out_dir / libdir).glob(lib + "*"))
			if len(versions) < 2: continue
			versions.sort(key = lambda v: len(v.name))
			for v in versions[1:]: v.unlink()

if __name__ == "__main__":
	triplets = []
	do_archive = False
	if len(sys.argv) > 1:
		for arg in sys.argv[1:]:
			if arg == "--archive": do_archive = True
			else: triplets.append(arg)
	if len(triplets) < 1: triplets.append("")
	for t in triplets: build(t, do_archive)
