# Build script for NVGT using the scons build system.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import os, multiprocessing

# setup
env = Environment()
VariantDir("build/obj_src", "src", duplicate = 0)
env.SetOption("num_jobs", multiprocessing.cpu_count())
if env["PLATFORM"] == "win32":
	from build import windev
	windev.set_windev_paths(env)
	env.Append(CCFLAGS = ["/EHsc", "/J", "/std:c++20", "/GF", "/Zc:inline", "/O2"])
	env.Append(LIBS = ["tolk", "angelscript64"])
	env.Append(LIBS = ["Kernel32", "User32", "imm32", "OneCoreUAP", "dinput8", "dxguid", "gdi32", "winspool", "shell32", "iphlpapi", "ole32", "oleaut32", "delayimp", "uuid", "comdlg32", "advapi32", "netapi32", "winmm", "version", "crypt32", "normaliz", "wldap32", "ws2_32"])
else:
	env.Append(CCFLAGS = ["-std=c++20"])
	env.Append(LIBS = ["angelscript"])
env.Append(CPPPATH = ["#ASAddon/include", "#dep"], LIBPATH = ["ASAddon", "dep", "lib"])
env["CPPDEFINES"] = ["POCO_STATIC"]

# plugins
plugin_env = env.Clone()
if env["PLATFORM"] == "win32":
	plugin_env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB"])
	plugin_env["no_import_lib"] = 1
static_plugins = []
for s in Glob("plugin/*/_SConscript"):
	plugname = str(s).split(os.path.sep)[1]
	if ARGUMENTS.get(f"no_{plugname}_plugin", "0") == "1": continue
	plug = SConscript(s, variant_dir = f"build/obj_plugin/{plugname}", duplicate = 0, exports = {"env": plugin_env})
	if plug: static_plugins.append(plug)
env.Append(LIBS = static_plugins)

# nvgt itself
env.Append(LIBS = ["PocoFoundationMT", "PocoJSONMT", "PocoNetMT", "enet", "opus", "phonon", "bass", "bass_fx", "bassmix", "git2", "SDL2", "SDL2main"])
env.Append(CPPDEFINES = ["NVGT_BUILDING", "NO_OBFUSCATE"], LIBS = ["ASAddon", "deps"])
if env["PLATFORM"] == "win32":
	env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB", "/SUBSYSTEM:WINDOWS", "/LTCG", "/OPT:REF", "/OPT:ICF", "/delayload:bass.dll", "/delayload:bass_fx.dll", "/delayload:bassmix.dll", "/delayload:phonon.dll", "/delayload:Tolk.dll"])
if ARGUMENTS.get("no_user", "0") == "0":
	if os.path.isfile("user/nvgt_config.h"):
		env.Append(CPPDEFINES = ["NVGT_USER_CONFIG"])
	if os.path.isfile("user/_SConscript"):
		SConscript("user/_SConscript", exports = {"plugin_env": plugin_env, "nvgt_env": env})
SConscript("ASAddon/_SConscript", variant_dir = "build/obj_ASAddon", duplicate = 0, exports = "env")
SConscript("dep/_SConscript", variant_dir = "build/obj_dep", duplicate = 0, exports = "env")
env.Program("release/nvgt", Glob("build/obj_src/*.cpp"))

# stubs
if ARGUMENTS.get("no_stubs", "0") == "0":
	stub_platform = "" # This detection will likely need to be improved as we get more platforms working.
	if env["PLATFORM"] == "win32": stub_platform = "windows"
	elif env["PLATFORM"] == "darwin": stub_platform = "mac"
	else: stub_platform = env["PLATFORM"]
	VariantDir("build/obj_stub", "src", duplicate = 0)
	stub_env = env.Clone(CPPDEFINES = list(env["CPPDEFINES"]) + ["NVGT_STUB"], PROGSUFFIX = ".bin")
	if ARGUMENTS.get("stub_obfuscation", "0") == "1": stub_env["CPPDEFINES"].remove("NO_OBFUSCATE")
	stub_objects = stub_env.Object(Glob("build/obj_stub/*.cpp"))
	stub_env.Program(f"release/nvgt_{stub_platform}", stub_objects)
	# on windows, we should have a version of the Angelscript library without the compiler, allowing for slightly smaller executables.
	if env["PLATFORM"] == "win32":
		stublibs = list(stub_env["LIBS"])
		if "angelscript64" in stublibs:
			stublibs.remove("angelscript64")
			stublibs.append("angelscript64nc")
			stub_env.Program(f"release/nvgt_{stub_platform}_nc", stub_objects, LIBS = stublibs)

