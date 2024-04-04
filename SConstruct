# Build script for NVGT using the scons build system.
import multiprocessing

env = Environment()
env.SetOption("num_jobs", multiprocessing.cpu_count())
from build import windev
windev.set_windev_paths(env)
env.Append(CPPPATH = ["ASAddon/include", "dep"], LIBPATH = ["ASAddon", "dep"])
env["LIBS"] = ["ASAddon", "deps", "PocoFoundationMT", "PocoJSONMT", "PocoNetMT", "enet", "opus", "phonon", "bass", "bass_fx", "bassmix", "git2", "SDL2", "SDL2main"]
if env["PLATFORM"] == "win32":
	env["LIBS"].append(["tolk", "angelscript64"])
SConscript("ASAddon/_SConscript", exports = "env")
SConscript("dep/_SConscript", exports = "env")
env["CPPDEFINES"] = ["NVGT_BUILDING", "POCO_STATIC"]
# c++ 20 from this point
if env["PLATFORM"] == "win32":
	env.Append(CCFLAGS = ["/std:c++20"])
else:
	env.Append(CCFLAGS = ["-std=c++20"])
if env["PLATFORM"] == "win32":
	env.Append(CCFLAGS = ["/EHsc"])
	env.Append(LINKFLAGS = ["/NOEXP", "/NOIMPLIB", "/SUBSYSTEM:WINDOWS", "/LTCG", "/delayload:bass.dll", "/delayload:bass_fx.dll", "/delayload:bassmix.dll", "/delayload:phonon.dll", "/delayload:Tolk.dll"])
	env.Append(LIBS = ["Kernel32", "User32", "imm32", "OneCoreUAP", "dinput8", "dxguid", "gdi32", "winspool", "shell32", "iphlpapi", "ole32", "oleaut32", "delayimp", "uuid", "comdlg32", "advapi32", "netapi32", "winmm", "version", "crypt32", "normaliz", "wldap32", "ws2_32"])
env.Program("release/nvgt.exe", Glob("src/*.cpp"))
