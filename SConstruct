# Build script for NVGT using the scons build system.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import os, multiprocessing

# setup
env = Environment()
env.SetOption("num_jobs", multiprocessing.cpu_count())
if env["PLATFORM"] == "win32":
	SConscript("build/windev_sconscript", exports = ["env"])
	env.Append(CCFLAGS = ["/EHsc", "/J", "/std:c++17", "/GF", "/Zc:inline", "/O2"])
	env.Append(LIBS = ["tolk", "angelscript64"])
	env.Append(LIBS = ["Kernel32", "User32", "imm32", "OneCoreUAP", "dinput8", "dxguid", "gdi32", "winspool", "shell32", "iphlpapi", "ole32", "oleaut32", "delayimp", "uuid", "comdlg32", "advapi32", "netapi32", "winmm", "version", "crypt32", "normaliz", "wldap32", "ws2_32"])
else:
	env.Append(CXXFLAGS = ["-fms-extensions", "-std=c++17", "-fpermissive", "-O2", "-Wno-narrowing", "-Wno-int-to-pointer-cast",  "-Wno-unused-result"])
	env.Append(LIBS = ["angelscript", "m"])
if env["PLATFORM"] == "darwin":
	# homebrew paths, as well as paths for a folder called macosdev containing headers and pre-built libraries like bass and steam audio.
	env.Append(CPPPATH = ["/opt/homebrew/include", "#macosdev/include"], CCFLAGS = ["-mmacosx-version-min=14.0"], LIBPATH = ["/opt/homebrew/lib", "#macosdev/lib"])
elif env["PLATFORM"] == "posix":
	# Same custom directory here accept called lindev for now, we enable the gold linker to silence seemingly pointless warnings about symbols in the bass libraries, and we add /usr/local/lib to the libpath because it seems we aren't finding libraries unless we do manually.
	env.Append(CPPPATH = ["/usr/local/include", "#lindev/include"], LIBPATH = ["/usr/local/lib", "#lindev/lib"], LINKFLAGS = ["-fuse-ld=gold"])
	# Fix as soon as possible, but currently compiling shared plugins doesn't work on linux apparently because things like Poco didn't get compiled with the -fPIC option. Joy.
	ARGUMENTS["no_shared_plugins"] = 1
env.Append(CPPDEFINES = ["POCO_STATIC"])
env.Append(CPPPATH = ["#ASAddon/include", "#dep"], LIBPATH = ["#lib"])
VariantDir("build/obj_src", "src", duplicate = 0)

# plugins
plugin_env = env.Clone()
if env["PLATFORM"] == "win32":
	plugin_env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB"])
	plugin_env["no_import_lib"] = 1
elif env["PLATFORM"] == "posix":
	plugin_env.Append(LINKFLAGS = ["-fPIC"])
static_plugins = []
for s in Glob("plugin/*/_SConscript"):
	plugname = str(s).split(os.path.sep)[1]
	if ARGUMENTS.get(f"no_{plugname}_plugin", "0") == "1": continue
	plug = SConscript(s, variant_dir = f"build/obj_plugin/{plugname}", duplicate = 0, exports = {"env": plugin_env})
	if plug: static_plugins.append(plug)
env.Append(LIBS = static_plugins)

# nvgt itself
sources = Glob("build/obj_src/*.cpp")
env.Append(LIBS = [["PocoFoundationMT", "PocoJSONMT", "PocoNetMT", "PocoZipMT"] if env["PLATFORM"] == "win32" else ["PocoFoundation", "PocoJSON", "PocoNet", "PocoZip"], "enet", "phonon", "bass", "bass_fx", "bassmix", "SDL2", "SDL2main"])
env.Append(CPPDEFINES = ["NVGT_BUILDING", "NO_OBFUSCATE"], LIBS = ["ASAddon", "deps"])
if env["PLATFORM"] == "win32":
	env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB", "/SUBSYSTEM:WINDOWS", "/LTCG", "/OPT:REF", "/OPT:ICF", "/delayload:bass.dll", "/delayload:bass_fx.dll", "/delayload:bassmix.dll", "/delayload:phonon.dll", "/delayload:Tolk.dll"])
elif env["PLATFORM"] == "darwin":
	sources.append("build/obj_src/macos.mm")
	env["FRAMEWORKPREFIX"] = "-weak_framework"
	env.Append(FRAMEWORKS = ["CoreAudio",  "CoreFoundation", "CoreHaptics", "CoreVideo", "AudioToolbox", "AppKit", "IOKit", "Carbon", "Cocoa", "ForceFeedback", "GameController", "QuartzCore"])
	env.Append(LIBS = ["objc"])
	env.Append(LINKFLAGS = ["-Wl,-rpath,'.'", "-mmacosx-version-min=14.0"])
elif env["PLATFORM"] == "posix":
	env.Append(LINKFLAGS = ["-Wl,-rpath,'lib'"])
if ARGUMENTS.get("no_user", "0") == "0":
	if os.path.isfile("user/nvgt_config.h"):
		env.Append(CPPDEFINES = ["NVGT_USER_CONFIG"])
	if os.path.isfile("user/_SConscript"):
		SConscript("user/_SConscript", exports = {"plugin_env": plugin_env, "nvgt_env": env})
SConscript("ASAddon/_SConscript", variant_dir = "build/obj_ASAddon", duplicate = 0, exports = "env")
SConscript("dep/_SConscript", variant_dir = "build/obj_dep", duplicate = 0, exports = "env")
env.Program("release/nvgt", sources)

# stubs
if ARGUMENTS.get("no_stubs", "0") == "0":
	stub_platform = "" # This detection will likely need to be improved as we get more platforms working.
	if env["PLATFORM"] == "win32": stub_platform = "windows"
	elif env["PLATFORM"] == "darwin": stub_platform = "mac"
	elif env["PLATFORM"] == "posix": stub_platform = "linux"
	else: stub_platform = env["PLATFORM"]
	VariantDir("build/obj_stub", "src", duplicate = 0)
	stub_env = env.Clone(CPPDEFINES = list(env["CPPDEFINES"]) + ["NVGT_STUB"], PROGSUFFIX = ".bin")
	if ARGUMENTS.get("stub_obfuscation", "0") == "1": stub_env["CPPDEFINES"].remove("NO_OBFUSCATE")
	# Todo: Can we make this use one list of sources E. the sources variable above? This scons issue where one must provide the variant_dir when specifying sources is why we are not right now.
	stub_objects = stub_env.Object(Glob("build/obj_stub/*.cpp"))
	if env["PLATFORM"] == "darwin":
		stub_objects.append(stub_env.Object("build/obj_stub/macos.mm"))
	stub_env.Program(f"release/nvgt_{stub_platform}", stub_objects)
	# on windows, we should have a version of the Angelscript library without the compiler, allowing for slightly smaller executables.
	if env["PLATFORM"] == "win32":
		stublibs = list(stub_env["LIBS"])
		if "angelscript64" in stublibs:
			stublibs.remove("angelscript64")
			stublibs.append("angelscript64nc")
			stub_env.Program(f"release/nvgt_{stub_platform}_nc", stub_objects, LIBS = stublibs)

