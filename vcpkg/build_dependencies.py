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
import platform
import os
from xml.etree.ElementTree import ParseError, parse
if sys.platform == "linux":
	from gi.repository import Gio

vcpkg_path = Path(__file__, "..", "bin", "vcpkg" if sys.platform != "win32" else "vcpkg.exe").resolve()
implib_gen_path = Path(__file__, "..", "Implib.so")
vcpkg_installed_path = Path(__file__, "..", "vcpkg_installed").resolve()
repo_path = Path(__file__).parents[1]
glib_min_required = "2.70"
gdbus_codegen = "gdbus-codegen"

def bootstrap_vcpkg():
	if vcpkg_path.exists() and vcpkg_path.is_file():
		return
	if sys.platform == "win32":
		subprocess.check_output(vcpkg_path.parent / "bootstrap-vcpkg.bat")
	else:
		subprocess.check_output(vcpkg_path.parent / "bootstrap-vcpkg.sh")

def is_well_formed(xml_path: Path) -> bool:
	try:
		parse(xml_path)
		return True
	except ParseError:
		print(f"Warning: Skipping {xml_path}: not well-formed XML", file=sys.stderr)
		return False

def has_interfaces(xml_bytes: bytes) -> bool:
	try:
		node = Gio.DBusNodeInfo.new_for_xml(xml_bytes.decode())
		return bool(node.interfaces)
	except Exception as e:
		print(f"Warning: Skipping XML: {e}", file=sys.stderr)
		return False

def derive_c_paths(xml_path: Path, out_base: Path) -> tuple[Path, Path]:
	parts = xml_path.stem.split('.')
	if len(parts) < 2:
		raise ValueError(f"Unexpected XML filename format: {xml_path.name!r}")
	namespace, iface = parts[:-1], parts[-1]
	target_dir = out_base
	target_dir = target_dir.joinpath(*namespace)
	return (target_dir / f"{iface}.h", target_dir / f"{iface}.c")

def run_gdbus_codegen(iface: str, target_dir: Path, xml_spec: Path) -> None:
	common_args = [gdbus_codegen, "--pragma-once", "--c-generate-object-manager", "--c-generate-autocleanup", "all", "--glib-min-required", glib_min_required]
	subprocess.run([*common_args, "--header", "--output", str(target_dir / f"{iface}.h"), str(xml_spec)], check=True)
	subprocess.run([*common_args, "--body", "--output", str(target_dir / f"{iface}.c"), str(xml_spec)], check=True)

def generate_gdbus_code(xml_path: Path, out_base: Path) -> None:
	if not is_well_formed(xml_path):
		return
	xml_bytes = xml_path.read_bytes()
	if not has_interfaces(xml_bytes):
		return
	iface_name = xml_path.stem.split('.')[-1]
	try:
		c_header_path, c_source_path = derive_c_paths(xml_path, out_base)
	except ValueError as e:
		print(e, file=sys.stderr)
		return
	c_header_path.parent.mkdir(parents=True, exist_ok=True)
	if c_header_path.exists() and c_source_path.exists():
		print(f"Skipping invocation of gdbus-codegen for {xml_path}: outputs already exist")
	else:
		try:
			run_gdbus_codegen(iface_name, c_header_path.parent, xml_path)
		except subprocess.CalledProcessError as e:
			print(f"gdbus-codegen failed for {xml_path}: {e}", file=sys.stderr)
			sys.exit(1)

def build(triplet = "", do_archive = False, out_dir = ""):
	if not triplet:
		machine = platform.machine().lower()
		if machine in ("x86_64", "amd64", "x64"): arch = "x64"
		elif machine in ("arm64", "aarch64"): arch = "arm64"
		else: sys.exit(f"Error: Unsupported architecture: {machine}")
		if sys.platform == "win32": triplet = f"{arch}-windows"
		elif sys.platform == "darwin": triplet = f"{arch}-osx"
		elif sys.platform == "linux": triplet = f"{arch}-linux"
		else: sys.exit("Unable to determine platform, please pass a triplet explicitly.")
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
	fix_debug(out_dir)
	if triplet == "arm64-osx": macos_fat_binaries(out_dir)
	elif triplet == "x64-windows": windows_lib_rename(out_dir)
	if triplet.endswith("osx") or triplet.endswith("linux"): remove_duplicates(out_dir)
	try:
		shutil.rmtree(out_dir / "lib" / "cmake")
		shutil.rmtree(out_dir / "lib" / "pkgconfig")
		shutil.rmtree(out_dir / "debug" / "lib" / "cmake")
		shutil.rmtree(out_dir / "debug" / "lib" / "pkgconfig")
	except FileNotFoundError: pass
	if sys.platform == "linux":
		implib_archs = ["x86_64-linux-gnu", "aarch64-linux-gnu"]
		oldcwd = os.getcwd()
		for arch in implib_archs:
			out_dir_arch = out_dir / "autogen" / "arch" / arch
			out_dir_arch.mkdir(parents = True, exist_ok = True)
			os.chdir(str(implib_gen_path.resolve()))
			for f in (out_dir / "lib").glob("*.so"):
				try:
					subprocess.check_output([sys.executable, "implib-gen.py", "--target", arch, "--dlopen-callback", "nvgt_dlopen", "--dlsym-callback", "nvgt_dlsym", "-o", str(out_dir_arch.resolve()), str(f.resolve())], stderr=subprocess.STDOUT)
				except subprocess.CalledProcessError as cpe:
					print(f"Warning: could not generate implib for {f} for arch {arch}: implib-gen returned {cpe.returncode}", file=sys.stderr)
					print (f"Warning: if generated, implib for {f} may be incomplete")
			try:
				subprocess.check_output([sys.executable, "implib-gen.py", "--target", arch, "--dlopen-callback", "nvgt_dlopen", "--dlsym-callback", "nvgt_dlsym", "-o", str(out_dir_arch.resolve()), "/usr/lib/libspeechd.so"], stderr=subprocess.STDOUT)
			except subprocess.CalledProcessError as cpe:
				sys.exit(f"Warning: could not generate implib for {f} for arch {arch}: implib-gen returned {cpe.returncode}")
		os.chdir(oldcwd)
		out_dir_dbus = out_dir / "autogen" / "dbus"
		out_dir_dbus.mkdir(parents = True, exist_ok = True)
		dbus_interfaces = ["org.freedesktop.login1.Manager", "org.freedesktop.login1.Session", "org.freedesktop.login1.Seat", "org.freedesktop.login1.User"]
		for dbus_interface in dbus_interfaces:
			generate_gdbus_code(Path(f"/usr/share/dbus-1/interfaces/{dbus_interface}.xml"), out_dir_dbus)
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
def fix_debug(out_dir):
	"""Several debug libraries frustratingly have different filenames to their release counterparts, which just makes build scripts more complicated. We'll just fix it here. Usually a d is just tacked on to the end of the filename which we'll get rid of as well as a hifen that sometimes appears."""
	excludes = ["reactphysics3d", "zstd"]
	for f in (out_dir / "debug" / "lib").iterdir():
		try:
			if not f.stem.lower().endswith("d"): continue
			exclude = f.stem if not f.stem.startswith("lib") else f.stem[3:]
			if exclude in excludes: continue
			count = 1 if not f.stem.lower().endswith("-d") else 2
			f.replace(f.with_stem(f.stem[:-count]))
		except: continue
def windows_lib_rename(out_dir):
	"""Sometimes windows libraries get built with annoying names that complicate build scripts. We have to handle them somewhere, may as well be here. Temporarily we'll also copy angelscript as angelscript-nc."""
	renames = [
		("libcrypto", "crypto"),
		("libcurl", "curl"),
		("libexpatMT", "expat"),
		("libexpatdMT", "expat"),
		("libssl", "ssl"),
		("pocoCryptomt", "pocoCrypto"),
		("pocoEncodingsmt", "pocoEncodings"),
		("pocoFoundationmt", "pocoFoundation"),
		("pocoJSONmt", "pocoJSON"),
		("pocoJWTmt", "pocoJWT"),
		("pocoMongoDBmt", "pocoMongoDB"),
		("pocoNetmt", "pocoNet"),
		("pocoNetSSLmt", "pocoNetSSL"),
		("pocoPrometheusmt", "pocoPrometheus"),
		("pocoRedismt", "pocoRedis"),
		("pocoSevenZipmt", "pocoSevenZip"),
		("pocoUtilmt", "pocoUtil"),
		("pocoXMLmt", "pocoXML"),
		("pocoZipmt", "pocoZip"),
		("SDL3-static", "SDL3"),
		("SDL3_image-static", "SDL3_image"),
		("SDL3_ttf-static", "SDL3_ttf"),
		("utf8proc_static", "utf8proc"),
		("zlib", "z")
	] # end renames list
	for lib in ["debug/lib", "lib"]:
		for r in renames:
			if (out_dir / lib / (r[0] + ".lib")).exists(): (out_dir / lib / (r[0] + ".lib")).replace(out_dir / lib / (r[1] + ".lib"))
		shutil.copyfile(out_dir / lib / "angelscript.lib", out_dir / lib / "angelscript-nc.lib")
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
