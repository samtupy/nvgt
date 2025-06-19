import subprocess
import sys
import json
import shutil
import hashlib
import platform
import os
import copy
import argparse
import requests
from pathlib import Path
from github import Github
import io
import zipfile
import pygit2
if platform.system() == "Linux" and ("ubuntu" in platform.freedesktop_os_release()["id"] or "debian" in platform.freedesktop_os_release()["id"]):
    try:
        import apt
    except ImportError:
        sys.exit("python3-apt is not installed. Please install it first")

build_android = False
build_arm64_linux = False
build_x64_linux = False
build_ios = False
build_ios_simulator = False
build_macos = False
build_arm64_windows = False
build_x64_windows = False
build_angelscript_nc = False
use_official_steam_audio = False    
vcpkg_path = Path(os.getcwd()) / "vcpkg" / "bin" / "vcpkg" if sys.platform != "win32" else "vcpkg.exe"
oldenv = {}
orig_cwd = os.getcwd()
    os.environ["VCPKG_OVERLAY_PORTS"] = str((Path() / "vcpkg" / "ports").resolve())
    os.environ["VCPKG_OVERLAY_TRIPLETS"] = str((Path() / "vcpkg" / "triplets").resolve())

        def bootstrap_vcpkg():
            if vcpkg_path.exists() and vcpkg_path.is_file(): return
    print("Bootstrapping vcpkg...")
    os.chdir(vcpkg_path.parent)
    if platform.System() == "Windows":
        subprocess.check_output("bootstrap-vcpkg.bat")
    else:
        subprocess.check_output("./bootstrap-vcpkg.sh")

    os.chdir(orig_cwd)
    print ("Done")

def find_ndk():
    env_vars = ['ANDROID_NDK_ROOT', 'ANDROID_NDK_HOME', 'ANDROID_NDK', 'NDK_ROOT']
    for var in env_vars:
        path = os.environ.get(var)
        if path and Path(path).exists():
            return path
    
    home = Path.home()
    common_paths = []
    
    if platform.system() == 'Windows':
        common_paths = [Path(os.environ.get('LOCALAPPDATA', '')) / 'Android/Sdk/ndk', home / 'AppData/Local/Android/Sdk/ndk', Path('C:/Android/sdk/ndk')]
    elif platform.system() == 'Darwin':
        common_paths = [home / 'Library/Android/sdk/ndk']
    else:
        common_paths = [home / 'Android/Sdk/ndk', Path('/opt/android-sdk/ndk')]
    
    for base_path in common_paths:
        if base_path.exists():
            for ndk_dir in base_path.iterdir():
                if ndk_dir.is_dir() and (ndk_dir / 'source.properties').exists():
                    return str(ndk_dir)
    
    return None

def build_packages_for_android():
    android_ndk_home = find_ndk()
    if android_ndk_home is None:
        # Todo: maybe download the NDK?
        sys.exit("Android NDK not found. Please install it on this system to build for android.")
    if os.environ.get("ANDROID_NDK_HOME") is None:
        os.environ["ANDROID_NDK_HOME"] = android_ndk_home
    print ("Building android packages, this will take a while...")
    try:
        subprocess.check_output([vcpkg_path, "install", "--triplet", "arm64-android", "enet6[*]", "libflac", "curl[http2,openssl]", "libffi", "miniupnpc[*]", "libogg", "opus[*]", "libvorbis[*]", "poco[crypto,net,netssl,json,util,xml,zip,encodings,mongodb,redis,jwt,prometheus,sevenzip]", "angelscript-nc" if build_angelscript_nc else "angelscript"])
    except CalledProcessError as cpe:
        sys.exit(f"Android packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
    try:
        subprocess.check_output([vcpkg_path, "install", "--triplet", "arm64-android-dynamic", "sdl3[vulkan]", "sdl3-ttf[core,svg]", "sdl3-image[*]", "" if not use_official_steam_audio else "steam-audio", "freetype[core,bzip2,error-strings,png,subpixel-rendering,zlib]"])
    except CalledProcessError as cpe:
        sys.exit(f"Android packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
    print ("Done")
    print ("Generating droiddev package...")
    out_dir = Path(orig_cwd / "build" / "packages" / "droiddev").
        out_dir.mkdir(parents=True, exist_ok=True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android" / "include", out_dir / "include", dirs_exist_ok = True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android" / "lib", out_dir / "lib", dirs_exist_ok = True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android" / "debug", out_dir / "debug", dirs_exist_ok = True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android-dynamic" / "include", out_dir / "include", dirs_exist_ok = True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android-dynamic" / "lib", out_dir / "lib", dirs_exist_ok = True)
    shutil.copytree(vcpkg_path.parent / "installed" / "arm64-android-dynamic" / "debug", out_dir / "debug", dirs_exist_ok = True)
    if use_official_steam_audio:
        gh = Github()
        repo = gh.get_repo("ValveSoftware/steam-audio")
        release = repo.get_latest_release()
        zip_asset = None
        #Todo: refine this
        for asset in release.get_assets():
            if asset.name.startswith("steamaudio_") and asset.name.endswith(".zip"):
                zip_asset = asset
                break
        if zip_asset is None:
            sys.exit("Official steam audio zip asset could not be found")
        response = requests.get(zip_asset.browser_download_url)
        response.raise_for_status()
        zip_data = io.BytesIO(response.content)
        with zipfile.ZipFile(zip_data) as zf:
            zf.extract("steamaudio/lib/android-armv8/libphonon.so", path=str((out_dir / "lib").resolve()))
            zf.extract("steamaudio/include/phonon.h", path=str((out_dir / "include").resolve()))
            zf.extract("steamaudio/include/phonon_interfaces.h", path=str((out_dir / "include").resolve()))
            zf.extract("steamaudio/include/phonon_version.h", path=str((out_dir / "include").resolve()))
    shutil.make_archive("droiddev", format="zip", root_dir=out_dir, base_dir="droiddev")
    with open("droiddev.zip", "rb") as f, open("droiddev.zip.blake2b", "w") as hf:
        h = hashlib.blake2b()
        data = f.read()
        h.update(data)
        hf.write(h.hexdigest())
    print("Done")

def build_packages_for_linux():
    if platform.system() != "Linux":
        sys.exit("Linux packages may only be built on Linux. Please re-run this script on Linux")

    print ("Building Linux packages, this will take a while...")
    system_packages = ['build-essential', 'libtool', 'mesa-common-dev', 'libnccl-dev', 'libxext-dev', 'libxcursor-dev', 'ladspa-sdk', 'libxcomposite-dev', 'libsystemd-dev', 'libnccl2', 'autoconf', 'libxxf86vm-dev', 'libgl1-mesa-dev', 'libxinerama-dev', 'libx11-dev', 'libltdl-dev', 'libgtk-4-dev', 'libglib2.0-dev', 'libspeechd-dev', 'libudev-dev', 'linux-libc-dev', 'libxrandr-dev', 'libxrender-dev', 'libwayland-dev', 'pkg-config', 'xorg-dev', 'libglu1-mesa-dev', 'libxft-dev', 'libgsasl-dev', 'clang', 'python3-jinja2', 'zip', 'gcc-aarch64-linux-gnu', 'g++-aarch64-linux-gnu']
    if os.getuid() == 0:
        if platform.freedesktop_os_release()["ID_LIKE"].lower() == "debian":
            cache = apt.Cache()
            cache.update()
            cache.open()
            cache.upgrade(dist_upgrade=True)
            cache.open()
            for package in system_packages:
                if package in cache:
                    pkg = cache[package]
                    if not pkg.is_installed:
                        pkg.mark_install()
            cache.commit(None, None)
    else:
        if platform.freedesktop_os_release()["ID_LIKE"].lower() == "debian":
            subprocess.check_output(['sudo', 'apt-get', 'update', '-yqq'])
            subprocess.check_output(['sudo', 'apt-get', 'full-upgrade', '-yqq'])
            command = ['sudo', 'apt-get', 'install', '-yqq']
            command.extend(system_packages)
            subprocess.check_output(command)
    static_packages = ['enet6[*]', 'libflac', 'curl[http2,openssl]', 'libffi', 'miniupnpc[*]', 'libogg', 'opus[*]', 'sdl3[ibus,x11,wayland,vulkan]', 'sdl3-ttf[core,svg]', 'sdl3-image[*]', 'libvorbis[*]', 'libarchive[*]', 'poco[net,netssl,json,util,xml,zip,encodings,mongodb,redis,jwt,prometheus,sevenzip]', 'freetype[core,bzip2,error-strings,png,subpixel-rendering,zlib]']
    if not use_official_steam_audio:
        static_packages.append('steam-audio')
    if build_angelscript_nc:
        static_packages.append('angelscript-nc')
    else:
        static_packages.append('angelscript')
    dynamic_packages = ['libgit2[core]', 'libplist']
    if not use_official_steam_audio:
        dynamic_packages.append('steam-audio')
    if build_arm64_linux:
        if not "steam-audio" in static_packages or not "steam-audio" in dynamic_packages:
            sys.exit("Error: steam audio does not have official libraries for arm64 for Linux")
        try:
            command = [vcpkg_path, "install", "--triplet", "arm64-linux"]
            command.extend(static_packages)
            subprocess.check_output(command)
        except CalledProcessError as cpe:
            sys.exit(f"Linux packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
        try:
            command = [vcpkg_path, "install", "--triplet", "arm64-linux-dynamic"]
            command.extend(dynamic_packages)
            subprocess.check_output(command)
        except CalledProcessError as cpe:
            sys.exit(f"Linux packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
    if build_x64_linux:
        try:
            command = [vcpkg_path, "install", "--triplet", "x64-linux"]
            command.extend(static_packages)
            subprocess.check_output(command)
        except CalledProcessError as cpe:
            sys.exit(f"Linux packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
        try:
            command = [vcpkg_path, "install", "--triplet", "x64-linux-dynamic"]
            command.extend(dynamic_packages)
            subprocess.check_output(command)
        except CalledProcessError as cpe:
            sys.exit(f"Linux packages installation failed, code {cpe.returncode}\nLogs follow:\n{cpe.output}")
    print ("Done")
    print ("Generating lindev package...")
    if build_arm64_linux:
        out_dir = Path(orig_cwd / "build" / "packages" / "lindev-arm64").
            out_dir.mkdir(parents=True, exist_ok=True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux" / "include", out_dir / "include", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux" / "lib", out_dir / "lib", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux" / "debug", out_dir / "debug", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux-dynamic" / "include", out_dir / "include", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux-dynamic" / "lib", out_dir / "lib", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "arm64-linux-dynamic" / "debug", out_dir / "debug", dirs_exist_ok = True)
    if build_x64_linux:
        out_dir = Path(orig_cwd / "build" / "packages" / "lindev-x64").
            out_dir.mkdir(parents=True, exist_ok=True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux" / "include", out_dir / "include", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux" / "lib", out_dir / "lib", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux" / "debug", out_dir / "debug", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux-dynamic" / "include", out_dir / "include", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux-dynamic" / "lib", out_dir / "lib", dirs_exist_ok = True)
        shutil.copytree(vcpkg_path.parent / "installed" / "x64-linux-dynamic" / "debug", out_dir / "debug", dirs_exist_ok = True)
        if use_official_steam_audio:
            gh = Github()
            repo = gh.get_repo("ValveSoftware/steam-audio")
            release = repo.get_latest_release()
            zip_asset = None
            #Todo: refine this
            for asset in release.get_assets():
                if asset.name.startswith("steamaudio_") and asset.name.endswith(".zip"):
                    zip_asset = asset
                    break
            if zip_asset is None:
                sys.exit("Official steam audio zip asset could not be found")
            response = requests.get(zip_asset.browser_download_url)
            response.raise_for_status()
            zip_data = io.BytesIO(response.content)
            with zipfile.ZipFile(zip_data) as zf:
                if build_x64_linux:
                    out_dir = Path(orig_cwd / "build" / "packages" / "lindev-x64").
                    zf.extract("steamaudio/lib/linux-x64/libphonon.so", path=str((out_dir / "lib").resolve()))
                    zf.extract("steamaudio/include/phonon.h", path=str((out_dir / "include").resolve()))
                    zf.extract("steamaudio/include/phonon_interfaces.h", path=str((out_dir / "include").resolve()))
                    zf.extract("steamaudio/include/phonon_version.h", path=str((out_dir / "include").resolve()))
    if build_arm64_linux:
        out_dir = Path(orig_cwd / "build" / "packages" / "lindev-arm64")
        shutil.make_archive("lindev-arm64", format="zip", root_dir=out_dir, base_dir="lindev")
        with open("lindev-arm64.zip", "rb") as f, open("lindev-arm64.zip.blake2b", "w") as hf:
            h = hashlib.blake2b()
            data = f.read()
            h.update(data)
            hf.write(h.hexdigest())
    if build_x64_linux:
        out_dir = Path(orig_cwd / "build" / "packages" / "lindev-x64")
        shutil.make_archive("lindev-arm64", format="zip", root_dir=out_dir, base_dir="lindev")
        with open("lindev-x64.zip", "rb") as f, open("lindev-x64.zip.blake2b", "w") as hf:
            h = hashlib.blake2b()
            data = f.read()
            h.update(data)
            hf.write(h.hexdigest())
    print("Done")
