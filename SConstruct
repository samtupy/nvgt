# Build script for NVGT using the scons build system.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.gg)
# Copyright (c) 2022-2024 Sam Tupy
# license: zlib

import multiprocessing

VariantDir("build/obj_src", "src", duplicate = 0)
env = Environment()
env.SetOption("num_jobs", multiprocessing.cpu_count())
from build import windev
windev.set_windev_paths(env)
env.Append(CPPPATH = ["ASAddon/include", "dep"], LIBPATH = ["ASAddon", "dep"])
env["LIBS"] = ["ASAddon", "deps", "PocoFoundationMT", "PocoJSONMT", "PocoNetMT", "enet", "opus", "phonon", "bass", "bass_fx", "bassmix", "git2", "SDL2", "SDL2main"]
if env["PLATFORM"] == "win32": env.Append(LIBS = ["tolk", "angelscript64"])
else: env.Append(LIBS = ["angelscript"])
env["CPPDEFINES"] = ["NVGT_BUILDING", "POCO_STATIC", "NO_OBFUSCATE"]
if env["PLATFORM"] == "win32":
	env.Append(CCFLAGS = ["/EHsc", "/std:c++20", "/GF", "/Zc:inline"])
	env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB", "/SUBSYSTEM:WINDOWS", "/LTCG", "/OPT:REF", "/OPT:ICF", "/delayload:bass.dll", "/delayload:bass_fx.dll", "/delayload:bassmix.dll", "/delayload:phonon.dll", "/delayload:Tolk.dll"])
	env.Append(LIBS = ["Kernel32", "User32", "imm32", "OneCoreUAP", "dinput8", "dxguid", "gdi32", "winspool", "shell32", "iphlpapi", "ole32", "oleaut32", "delayimp", "uuid", "comdlg32", "advapi32", "netapi32", "winmm", "version", "crypt32", "normaliz", "wldap32", "ws2_32"])
else:
	env.Append(CCFLAGS = ["-std=c++20"])
SConscript("ASAddon/_SConscript", variant_dir = "build/obj_ASAddon", duplicate = 0, exports = "env")
SConscript("dep/_SConscript", variant_dir = "build/obj_dep", duplicate = 0, exports = "env")
env.Program("release/nvgt", Glob("build/obj_src/*.cpp"))

# stubs
stub_platform = "" # This detection will likely need to be improved as we get more platforms working.
if env["PLATFORM"] == "win32": stub_platform = "windows"
elif env["PLATFORM"] == "darwin": stub_platform = "mac"
else: stub_platform = env["PLATFORM"]
VariantDir("build/obj_stub", "src", duplicate = 0)
stub_env = env.Clone(CPPDEFINES = env["CPPDEFINES"] + ["NVGT_STUB"], PROGSUFFIX = ".bin")
stub_objects = stub_env.Object(Glob("build/obj_stub/*.cpp"))
stub_env.Program(f"release/nvgt_{stub_platform}", stub_objects)
# on windows, we should have a version of the Angelscript library without the compiler, allowing for slightly smaller executables.
if env["PLATFORM"] == "win32":
	stublibs = list(stub_env["LIBS"])
	if "angelscript64" in stublibs:
		stublibs.remove("angelscript64")
		stublibs.append("angelscript64nc")
		stub_env.Program(f"release/nvgt_{stub_platform}_nc", stub_objects, LIBS = stublibs)
