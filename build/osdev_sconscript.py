# Generally, the easiest way to build nvgt is using the provided package of build artifacts used when constructing the public nvgt releases, consisting of many static libraries, headers, and even some redistributable dlls. We will try to find that here and add include/libpaths, or else you can add paths to your own libraries manually if desired. This is included from any sconstruct scripts that need these paths set.
# There are many more libraries and headers for the windows version of this package than for other platforms where getting the packages takes considerably less time and effort, but never the less there are still bass builds and steam audio for linux and macos.
# This also contains code to copy these libraries to the release/lib directory in the repo to make packaging easier, this way the release directory contains a fully working copy of nvgt upon build.

from pathlib import Path

Import("env")

prefix = ""
if env["PLATFORM"] == "win32": prefix = "win"
elif env["PLATFORM"] == "darwin": prefix = "macos"
elif env["PLATFORM"] == "posix": prefix = "lin"
else: Exit(1)
env["NVGT_OSDEV_NAME"] = prefix + "dev"

def set_osdev_paths(env, osdev_path = ARGUMENTS.get("deps_path", prefix + "dev")):
	if not "deps_path" in ARGUMENTS and Path(osdev_path + "_path").exists(): osdev_path = Path(osdev_path).read_text()
	else: osdev_path = Path("#" + osdev_path)
	env.Append(CPPPATH = [str(osdev_path / "include")])
	if ARGUMENTS.get("debug", "0") == "1": env.Append(LIBPATH = [str(osdev_path / "debug" / "lib")])
	env.Append(LIBPATH = [str(osdev_path / "lib")])
	env["NVGT_OSDEV_PATH"] = str(Dir(osdev_path))
	if env["PLATFORM"] == "win32":
		if ARGUMENTS.get("debug", "0") == "1": env.Append(LIBPATH = [str(osdev_path / "debug" / "bin")])
		env.Append(LIBPATH = [str(osdev_path / "bin")])

set_osdev_paths(env)

# Copy dynamic libraries to the release/lib directory. Usually these are contained in osdev/bin or osdev/lib, but the entire libpath is searched. Later we may consider doing this only on a successful NVGT build, but this could cause it to happen too infrequently.
def copy_osdev_libraries(env):
	libs = ["archive", "bass", "bass_fx", "bassmix", "git2", "plist-2.0", "phonon"]
	if env["PLATFORM"] == "win32": libs += ["GPUUtilities", "nvdaControllerClient64", "SAAPI64", "TrueAudioNext"]
	for l in libs:
		env.Install("#release/lib", FindFile(env.subst("${SHLIBPREFIX}" + l + ("$SHLIBSUFFIX" if not env["SHLIBSUFFIX"] in l else "")), env["LIBPATH"]))

env["NVGT_OSDEV_COPY_LIBS"] = copy_osdev_libraries
