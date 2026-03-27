# Generally, the easiest way to build nvgt is using the provided package of build artifacts used when constructing the public nvgt releases, consisting of many static libraries, headers, and even some redistributable dlls. We will try to find that here and add include/libpaths, or else you can add paths to your own libraries manually if desired. This is included from any sconstruct scripts that need these paths set.
# There are many more libraries and headers for the windows version of this package than for other platforms where getting the packages takes considerably less time and effort, but never the less there are still bass builds and steam audio for linux and macos.
# This also contains code to copy these libraries to the release/lib directory in the repo to make packaging easier, this way the release directory contains a fully working copy of nvgt upon build.

from pathlib import Path

Import("env")

def get_platform():
	target = ARGUMENTS.get("target", "")
	valid_targets = {"windows", "macos", "linux", "android", "ios"}
	if target in valid_targets:
		return target
	platform_map = {"win32": "windows", "darwin": "macos", "posix": "linux"}
	detected = platform_map.get(env["PLATFORM"], "")
	if not detected:
		print(f"Unknown host platform '{env['PLATFORM']}' and no valid target= argument specified.")
		Exit(1)
	return detected

env["NVGT_TARGET"] = get_platform()

prefix = ""
if env["NVGT_TARGET"] == "windows": prefix = "win"
elif env["NVGT_TARGET"] == "linux": prefix = "lin"
elif env["NVGT_TARGET"] == "android": prefix = "droi"
else: prefix = env["NVGT_TARGET"]
env["NVGT_OSDEV_NAME"] = prefix + "dev"

def set_osdev_paths(env, osdev_path = ARGUMENTS.get("deps_path", prefix + "dev")):
	if not "deps_path" in ARGUMENTS and Path(osdev_path + "_path").exists(): osdev_path = Path(osdev_path).read_text()
	else: osdev_path = Path("#" + osdev_path)
	env.Append(CPPPATH = [str(osdev_path / "include")])
	if ARGUMENTS.get("debug", "0") == "1": env.Append(LIBPATH = [str(osdev_path / "debug" / "lib")])
	env.Append(LIBPATH = [str(osdev_path / "lib")])
	env["NVGT_OSDEV_PATH"] = str(Dir(osdev_path))
	if env["NVGT_TARGET"] == "windows":
		if ARGUMENTS.get("debug", "0") == "1": env.Append(LIBPATH = [str(osdev_path / "debug" / "bin")])
		env.Append(LIBPATH = [str(osdev_path / "bin")])

set_osdev_paths(env)

# Copy dynamic libraries to the release/lib directory. Usually these are contained in osdev/bin or osdev/lib, but the entire libpath is searched. Later we may consider doing this only on a successful NVGT build, but this could cause it to happen too infrequently.
def copy_osdev_libraries(env):
	libs = ["archive", "bass", "bass_fx", "bassmix", "git2", "plist-2.0", "phonon"]
	if env["NVGT_TARGET"] == "windows": libs += ["GPUUtilities", "nvdaControllerClient64", "SAAPI64", "TrueAudioNext", "zdsrapi"]
	for l in libs:
		env.Install("#release/lib", FindFile(env.subst("${SHLIBPREFIX}" + l + ("$SHLIBSUFFIX" if not env["SHLIBSUFFIX"] in l else "")), env["LIBPATH"]))

env["NVGT_OSDEV_COPY_LIBS"] = copy_osdev_libraries
