# Build script for NVGT using the scons build system.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import os, multiprocessing, tempfile, subprocess, re

def raw_triplet_from_cc(cc):
	name = os.path.basename(cc)
	flag = '-print-target-triple' if 'clang' in name else '-dumpmachine'
	try:
		out = subprocess.check_output([cc, flag], stderr=subprocess.DEVNULL, universal_newlines=True)
		return out.strip()
	except (OSError, subprocess.CalledProcessError):
		return None

def raw_triplet_from_name(cc):
	# This method differs from the above one by looking at the basename of the compiler
	# Cross-compilers, or specific targeting compilers, usually start with `target_triple-gcc`, for example
	# This function is a bit brittle, hence it's use as a fallback
	name = os.path.basename(cc)
	m = re.match(r'(.+?)-(?:g(pp?|cc))$', name)
	return m.group(1) if m else None

Help("""
	Available custom build switches for NVGT:
		copylibs=0 or 1 (default 1): Copy shared libraries to release/lib after building?
		debug=0 or 1 (default 0): Include debug symbols in the resulting binaries?
		deps=build, download, or unmanaged (default download): How to fetch dependencies required to build NVGT? build = use vcpkg to build from source, download = download prebuilt binaries from nvgt.gg if newer than existing, unmanaged = assume dependencies are in place.
		deps_path=path: Optional location where dependencies are stored? Defaults to a folder named after the platform in the repository root.
		no_upx=0 or 1 (default 1): Disable UPX stubs?
		no_plugins=0 or 1 (default 0): Disable the plugin system entirely?
		no_shared_plugins=0 or 1 (default 0): Only compile plugins statically?
		no_stubs=0 or 1 (default 0): Disable compilation of all stubs?
		no_user=0 or 1 (default 0): Pretend that the user directory doesn't exist?
		no_<plugname>_plugin=1: Disable a plugin by name.
		static_<plugname>_plugin=1: Cause the given plugin to be linked statically if possible.
		stub_obfuscation=0 or 1 (default 0): Obfuscate some Angelscript function registration strings in the resulting stubs? Could make them bigger.
		warnings (0 or 1, default 0): enable compiler warnings?
		warnings_as_errors (0 or 1, default 0): treat compiler warnings as errors?
	You can also run scons install (for now only on windows) to install the build into C:/nvgt. STILL WIP!
	Note that custom switches or targets may be added by any plugin SConscript and may not be documented here.
""")

# setup
env = Environment()
# Prevent scons from wiping out the environment for certain tools, e.g. scan-build
env["CC"] = os.getenv("CC") or env["CC"]
env["CXX"] = os.getenv("CXX") or env["CXX"]
env["ENV"].update(x for x in os.environ.items() if x[0].startswith("CCC_"))
Decider('content-timestamp')
env.Alias("install", "c:/nvgt")
SConscript("build/upx_sconscript.py", exports = ["env"])
SConscript("build/version_sconscript.py", exports = ["env"])
env.SetOption("num_jobs", multiprocessing.cpu_count())
SConscript("build/osdev_sconscript.py", exports = ["env"])
SConscript("vcpkg/_SConscript", exports = ["env"])
if ARGUMENTS.get("debug", "0") == "1":
	env.Tool('compilation_db')
	cdb = env.CompilationDatabase()
	Alias('cdb', cdb)

# Platform setup and system libraries
if env["PLATFORM"] == "win32":
	deb_rel_flags = ["/MTd", "/Od", "/Z7"] if ARGUMENTS.get("debug", "0") == "1" else ["/MT", "/O2"]
	env.Append(CCFLAGS = ["/EHsc", "/J", "/Gy", "/std:c++20", "/GF", "/Zc:inline", "/bigobj", "/permissive-", "/W3" if ARGUMENTS.get("warnings", "0") == "1" else "", "/WX" if ARGUMENTS.get("warnings_as_errors", "0") == "1" else ""] + deb_rel_flags)
	env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB"], no_import_lib = 1)
	env.Append(LIBS = ["Kernel32", "User32", "imm32", "OneCoreUAP", "dinput8", "dxguid", "gdi32", "winspool", "shell32", "iphlpapi", "ole32", "oleaut32", "delayimp", "uuid", "comdlg32", "advapi32", "netapi32", "winmm", "version", "crypt32", "normaliz", "wldap32", "ws2_32", "ntdll"])
else:
	env.Append(CXXFLAGS = ["-fms-extensions", "-std=c++20", "-fpermissive", "-O0" if ARGUMENTS.get("debug", 0) == "1" else "-O3", "-Wno-narrowing", "-Wno-int-to-pointer-cast", "-Wno-delete-incomplete", "-Wno-unused-result", "-g" if ARGUMENTS.get("debug", 0) == "1" else "", "-Wall" if ARGUMENTS.get("warnings", "0") == "1" else "", "-Wextra" if ARGUMENTS.get("warnings", "0") == "1" else "", "-Werror" if ARGUMENTS.get("warnings_as_errors", "0") == "1" else ""], LIBS = ["m"])
if env["PLATFORM"] == "darwin":
	# homebrew paths and other libraries/flags for MacOS
	env.Append(CCFLAGS = ["-mmacosx-version-min=12.0", "-arch", "arm64", "-arch", "x86_64"], LINKFLAGS = ["-arch", "arm64", "-arch", "x86_64"])
	env["FRAMEWORKPREFIX"] = "-weak_framework"
elif env["PLATFORM"] == "posix":
	# enable the gold linker, strip the resulting binaries, and add /usr/local/lib to the libpath because it seems we aren't finding libraries unless we do manually.
	env.Append(CPPPATH = ["lindev/include", "lindev/autogen", "/usr/local/include"], LIBPATH = ["lindev/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu"], LINKFLAGS = ["-fuse-ld=gold", "-g" if ARGUMENTS.get("debug", 0) == "1" else "-s"])
	env.Append(LIBS = ["asound"])
env.Append(CPPDEFINES = ["POCO_STATIC", "POCO_NO_AUTOMATIC_LIBS", "UNIVERSAL_SPEECH_STATIC", "DEBUG" if ARGUMENTS.get("debug", "0") == "1" else "NDEBUG", "UNICODE"])
env.Append(CPPPATH = ["#ASAddon/include", "#dep"], LIBPATH = ["#build/lib"])

# plugins
static_plugins = []
try:
	# First, read the list of static plugins we wish to link if available.
	with open(os.path.join("user", "static_plugins"), "r") as f:
		lines = f.readlines()
		for l in lines:
			if not l or l.startswith("#"): continue
			static_plugins.append(l.strip())
except FileNotFoundError: pass
plugin_env = env.Clone()
# Then loop through all known plugins and build them.
for s in Glob("plugin/*/_SConscript") + Glob("plugin/*/SConscript") + Glob("extra/plugin/integrated/*/_SConscript") + Glob("extra/plugin/integrated/*/SConscript"):
	plugname = str(s).split(os.path.sep)[-2]
	if ARGUMENTS.get(f"no_{plugname}_plugin", "0") == "1": continue
	if ARGUMENTS.get(f"static_{plugname}_plugin", "0") == "1" and not plugname in static_plugins: static_plugins.append(plugname)
	# Build the plugin. A list of static libraries NVGT should link with is returned if the plugin generates any.
	plug = SConscript(s, variant_dir = f"build/obj_plugin/{plugname}", duplicate = 0, exports = {"env": plugin_env, "nvgt_env": env})
	if plug and plugname in static_plugins: env.Append(LIBS = plug)
# Finally generate nvgt_plugins.cpp
static_plugins_object = None
static_plugins_path = os.path.join(tempfile.gettempdir(), "nvgt_plugins")
if len(static_plugins) > 0:
	with open(static_plugins_path + ".cpp", "w") as f:
		f.write("#define NVGT_LOAD_STATIC_PLUGINS\n#include <nvgt_plugin.h>\n")
		for plugin in static_plugins: f.write(f"static_plugin({plugin})" + "\n")
		static_plugins_object = env.Object(static_plugins_path, static_plugins_path + ".cpp", CPPPATH = env["CPPPATH"] + ["#src"])

# Project libraries
env.Append(LIBS = ["PocoJSON", "PocoNet", "PocoNetSSL", "PocoUtil", "PocoXML", "PocoCrypto", "PocoZip", "PocoFoundation", "expat", "z", "angelscript", "SDL3", "phonon", "enet", "reactphysics3d", "ssl", "crypto", "utf8proc", "pcre2-8", "ASAddon", "deps", "vorbisfile", "vorbisenc", "vorbis", "ogg", "opusfile", "opusenc", "opus", "tinyexpr", "tiny-aes-c"])
if env["PLATFORM"] == "win32": env.Append(LIBS = ["UniversalSpeechStatic"])
# nvgt itself
sources = [str(i)[4:] for i in Glob("src/*.cpp")]
if "android.cpp" in sources: sources.remove("android.cpp")
if env["PLATFORM"] != "win32" and "win.cpp" in sources: sources.remove("win.cpp")
if env["PLATFORM"] != "posix" and "linux.cpp" in sources: sources.remove("linux.cpp")
if "version.cpp" in sources: sources.remove("version.cpp")
env.Command(target = "src/version.cpp", source = ["src/" + i for i in sources], action = env["generate_version"])
version_object = env.Object("build/obj_src/version", "src/version.cpp") # Things get weird if we do this after VariantDir.
VariantDir("build/obj_src", "src", duplicate = 0)
lindev_sources = []
env.Append(CPPDEFINES = ["NVGT_BUILDING", "NO_OBFUSCATE"])
if env["PLATFORM"] == "win32":
	deb_rel_flags = ["/DEBUG", "/INCREMENTAL:NO"] if ARGUMENTS.get("debug", "0") == "1" else ["/OPT:ICF=3"]
	env.Append(CPPDEFINES = ["_SILENCE_CXX20_OLD_SHARED_PTR_ATOMIC_SUPPORT_DEPRECATION_WARNING"], LINKFLAGS = ["/ignore:4099", "/delayload:phonon.dll"] + deb_rel_flags)
elif env["PLATFORM"] == "darwin":
	sources.append("apple.mm")
	sources.append("macos.mm")
	# We must link MacOS frameworks here rather than above in the system libraries section to insure that they don't get linked with random plugins.
	env.Append(FRAMEWORKS = ["CoreAudio",  "CoreFoundation", "CoreHaptics", "CoreMedia", "CoreVideo", "AudioToolbox", "AVFoundation", "AppKit", "IOKit", "Carbon", "Cocoa", "ForceFeedback", "GameController", "QuartzCore", "Metal", "UniformTypeIdentifiers"])
	env.Append(LIBS = ["objc"])
	env.Append(LINKFLAGS = ["-Wl,-rpath,'@loader_path',-rpath,'@loader_path/lib',-rpath,'@loader_path/../Frameworks',-dead_strip_dylibs", "-mmacosx-version-min=14.0"])
elif env["PLATFORM"] == "posix":
	env.Append(LINKFLAGS = ["-Wl,-rpath,'$$ORIGIN/.',-rpath,'$$ORIGIN/lib'"])
	detected = (raw_triplet_from_cc(env['CC']) or raw_triplet_from_name(env['CC']) or env.Exit(1, f"Can't detect target triple from CC={env['CC']}"))
	mappings = [
		(r'^aarch64-.*-linux-gnu$',            'aarch64-linux-gnu'),
		(r'^x86_64-.*-linux-gnu$',             'x86_64-linux-gnu'),
	]
	for pattern, canon in mappings:
		if re.match(pattern, detected):
			env['target_triplet'] = canon
			break
	if ('target_triplet' in env and env['target_triplet'] is None) or ('target_triplet' not in env):
		env.Exit(1, f"Unsupported target triple '{detected}'; must be one of: " + ", ".join([t for _, t in mappings]))
	VariantDir("#build/obj_lindev/autogen/arch", "#lindev/autogen/arch",     duplicate = 0)
	VariantDir("#build/obj_lindev/autogen/dbus", "#lindev/autogen/dbus",     duplicate = 0)
	lindev_sources.extend(Glob(f"#build/obj_lindev/autogen/arch/{env['target_triplet']}/*.c", strings=True))
	lindev_sources.extend(Glob(f"#build/obj_lindev/autogen/arch/{env['target_triplet']}/*.S", strings=True))
	for root, dirs, files in os.walk(Dir("#lindev/autogen/dbus").abspath):
		for file in files:
			rel_path = os.path.relpath(os.path.join(root, file), Dir("#lindev/autogen/dbus").abspath)
			lindev_sources.append(os.path.join("#build/obj_lindev/autogen/dbus", rel_path))
	env.ParseConfig('pkg-config --cflags gtk4')
	env.ParseConfig('pkg-config --cflags glib-2.0')
	env.ParseConfig('pkg-config --cflags dbus-1')
	env.ParseConfig('pkg-config --cflags speech-dispatcher')
if ARGUMENTS.get("no_user", "0") == "0":
	if os.path.isfile("user/nvgt_config.h"):
		env.Append(CPPDEFINES = ["NVGT_USER_CONFIG"])
	for s in ["_SConscript", "SConscript"]:
		if os.path.isfile(f"user/{s}"):
			SConscript(f"user/{s}", exports = {"plugin_env": plugin_env, "nvgt_env": env})
			break # only execute one script from here
SConscript("ASAddon/_SConscript", variant_dir = "build/obj_ASAddon", duplicate = 0, exports = "env")
SConscript("dep/_SConscript", variant_dir = "build/obj_dep", duplicate = 0, exports = "env")
# We'll clone the environment for stubs now so that we can then add any extra libraries that are not needed for stubs to the main nvgt environment.
stub_env = env.Clone(PROGSUFFIX = ".bin")
if env["PLATFORM"] == "win32": env.Append(LINKFLAGS = ["/delayload:plist-2.0.dll"])
env.Append(LIBS = ["plist-2.0"])
extra_objects = [version_object]
if static_plugins_object: extra_objects.append(static_plugins_object)
if ARGUMENTS.get("debug", "0") == "1": env["PDB"] = "#build/debug/nvgt.pdb"
nvgt = env.Program("release/nvgt", env.Object([os.path.join("build/obj_src", s) for s in sources]) + env.Object(lindev_sources) + extra_objects)
if env["PLATFORM"] == "darwin":
	# On Mac OS, we need to run install_name_tool to modify the paths of any dynamic libraries we link.
	env.AddPostAction(nvgt, lambda target, source, env: env.Execute("install_name_tool -change lib/libplist-2.0.dylib @rpath/libplist-2.0.dylib " + str(target[0])))
if env["PLATFORM"] == "win32":
	# Only on windows we must go through the frustrating hastle of compiling a version of nvgt with no console E. the windows subsystem. It is at least set up so that we only need to recompile one object
	if "nvgt.cpp" in sources: sources.remove("nvgt.cpp")
	if ARGUMENTS.get("debug", "0") == "1": env["PDB"] = "#build/debug/nvgtw.pdb"
	nvgtw = env.Program("release/nvgtw", env.Object([os.path.join("build/obj_src", s) for s in sources]) + env.Object(lindev_sources) + [env.Object("build/obj_src/nvgtw", "build/obj_src/nvgt.cpp", CPPDEFINES = ["$CPPDEFINES", "NVGT_WIN_APP"]), extra_objects], LINKFLAGS = ["$LINKFLAGS", "/subsystem:windows"])
	sources.append("nvgt.cpp")
	# Todo: Properly implement the install target on other platforms
	env.Install("c:/nvgt", nvgt)
	env.Install("c:/nvgt", nvgtw)
	env.Install("c:/nvgt", "#release/include")
	env.Install("c:/nvgt", "#release/lib")

# stubs
def fix_stub(target, source, env):
	"""On windows, we replace the first 2 bytes of a stub with 'NV' to stop some sort of antivirus scan upon script compile that makes it take a bit longer. We do the same on MacOS because otherwise apple's notarization service detects the stub as an unsigned binary and fails. Stubs must be unsigned until the nvgt scripter signs their compiled games."""
	for t in target:
		if not str(t).endswith(".bin"): continue
		with open(str(t), "rb+") as f:
			f.seek(0)
			f.write(b"NV")
			f.close()

if ARGUMENTS.get("no_stubs", "0") == "0":
	stub_platform = "" # This detection will likely need to be improved as we get more platforms working.
	if env["PLATFORM"] == "win32": stub_platform = "windows"
	elif env["PLATFORM"] == "darwin": stub_platform = "mac"
	elif env["PLATFORM"] == "posix": stub_platform = "linux"
	else: stub_platform = env["PLATFORM"]
	VariantDir("build/obj_stub", "src", duplicate = 0)
	stub_env.Append(CPPDEFINES = ["NVGT_STUB"])
	if env["PLATFORM"] == "win32": stub_env.Append(LINKFLAGS = ["/subsystem:windows"])
	if ARGUMENTS.get("stub_obfuscation", "0") == "1": stub_env["CPPDEFINES"].remove("NO_OBFUSCATE")
	stub_objects = stub_env.Object([os.path.join("build/obj_stub", s) for s in sources]) + env.Object(lindev_sources) + extra_objects
	if ARGUMENTS.get("debug", "0") == "1": stub_env["PDB"] = "#build/debug/nvgt_windows.pdb"
	stub = stub_env.Program(f"release/stub/nvgt_{stub_platform}", stub_objects)
	if env["PLATFORM"] == "win32": env.Install("c:/nvgt/stub", stub)
	if "upx" in env:
		stub_u = stub_env.UPX(f"release/stub/nvgt_{stub_platform}_upx.bin", stub)
		if env["PLATFORM"] == "win32": env.Install("c:/nvgt/stub", stub_u)
	# on windows, we should have a version of the Angelscript library without the compiler, allowing for slightly smaller executables.
	if env["PLATFORM"] == "darwin":
		stub_env.AddPostAction(stub, fix_stub)
	elif env["PLATFORM"] == "win32":
		stub_env.AddPostAction(stub, fix_stub)
		if "upx" in env: stub_env.AddPostAction(stub_u, fix_stub)
		stublibs = list(stub_env["LIBS"])
		if "angelscript" in stublibs:
			stublibs.remove("angelscript")
			stublibs.append("angelscript-nc")
			if ARGUMENTS.get("debug", "0") == "1": stub_env["PDB"] = "#build/debug/nvgt_windows_nc.pdb"
			stub_nc = stub_env.Program(f"release/stub/nvgt_{stub_platform}_nc", stub_objects, LIBS = stublibs)
			stub_env.AddPostAction(stub_nc, fix_stub)
			env.Install("c:/nvgt/stub", stub_nc)
			if "upx" in env:
				stub_nc_u = stub_env.UPX(f"release/stub/nvgt_{stub_platform}_nc_upx.bin", stub_nc)
				stub_env.AddPostAction(stub_nc_u, fix_stub)
				env.Install("c:/nvgt/stub", stub_nc_u)

if ARGUMENTS.get("copylibs", "1") == "1":
	env["NVGT_OSDEV_COPY_LIBS"](env)
