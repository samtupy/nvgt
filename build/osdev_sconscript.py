# Generally, the easiest way to build nvgt is using the provided package of build artifacts used when constructing the public nvgt releases, consisting of many static libraries, headers, and even some redistributable dlls. We will try to find that here and add include/libpaths, or else you can add paths to your own libraries manually if desired. This is included from any sconstruct scripts that need these paths set.
# There are many more libraries and headers for the windows version of this package than for other platforms where getting the packages takes considerably less time and effort, but never the less there are still bass builds and steam audio for linux and macos.
# This also contains code to copy these libraries to the release/lib directory in the repo to make packaging easier, this way the release directory contains a fully working copy of nvgt upon build.

import os

Import("env")

prefix = ""
if env["PLATFORM"] == "win32": prefix = "win"
elif env["PLATFORM"] == "darwin": prefix = "macos"
elif env["PLATFORM"] == "posix": prefix = "lin"
else: Exit(1)

def set_osdev_paths(env, osdev_path = prefix + "dev"):
	found = False
	if not os.path.isdir("../" + osdev_path):
		try: osdev_path = open(prefix + "dev_path").read()
		except: return
	else:
		osdev_path = "#" + osdev_path
		found = True
	if not found and not os.path.isdir(osdev_path): return
	else: found = True
	env.Append(CPPPATH = [os.path.join(osdev_path, "include")])
	env.Append(LIBPATH = [os.path.join(osdev_path, "lib")])
	if env["PLATFORM"] == "win32":
		env.Append(LIBPATH = [os.path.join(osdev_path, "bin")])
		env["NVGT_OSDEV_PATH"] = osdev_path
		if "debug" in osdev_path: env["windev_debug"] = 1

set_osdev_paths(env)

# Copy dynamic libraries to the release/lib directory. Usually these are contained in osdev/bin or osdev/lib, but the entire libpath is searched. Later we may consider doing this only on a successful NVGT build, but this could cause it to happen too infrequently.
def copy_osdev_libraries(env):
	libs = ["bass", "bass_fx", "bassmix", "git2", "plist-2.0.so.4" if env["PLATFORM"] == "posix" else "plist-2.0.4" if env["PLATFORM"] == "darwin" else "plist", "phonon"]
	if env["PLATFORM"] == "win32": libs += ["GPUUtilities", "nvdaControllerClient64", "SAAPI64", "TrueAudioNext"]
	for l in libs:
		env.Install("#release/lib", FindFile(env.subst("${SHLIBPREFIX}" + l + ("$SHLIBSUFFIX" if not env["SHLIBSUFFIX"] in l else "")), env["LIBPATH"] + ["/usr/local/lib"]))

env["NVGT_OSDEV_COPY_LIBS"] = copy_osdev_libraries
