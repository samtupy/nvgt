# NDK detection and toolchain/environment setup for building nvgt targeting Android. Included from SConstruct when NVGT_TARGET is android.

import os, platform

Import("env")

if "ANDROID_NDK_HOME" not in os.environ:
	print("ANDROID_NDK_HOME not set, cannot build for android")
	Exit(1)
env["NDK_HOME"] = os.environ["ANDROID_NDK_HOME"]
host_os = platform.system().lower()
if host_os == "windows":
	env["NDK_HOST_TAG"] = "windows-x86_64"
	cmd_ext = ".cmd"
	exe_ext = ".exe"
	env["GRADLE_CMD"] = ["cmd.exe", "/c", "gradlew.bat"]
elif host_os == "darwin":
	env["NDK_HOST_TAG"] = "darwin-x86_64"
	cmd_ext = ""
	exe_ext = ""
	env["GRADLE_CMD"] = ["./gradlew"]
else:
	env["NDK_HOST_TAG"] = "linux-x86_64"
	cmd_ext = ""
	exe_ext = ""
	env["GRADLE_CMD"] = ["./gradlew"]
toolchain_bin = os.path.join(env["NDK_HOME"], "toolchains", "llvm", "prebuilt", env["NDK_HOST_TAG"], "bin")
env["CC"] = os.path.join(toolchain_bin, f"aarch64-linux-android28-clang{cmd_ext}")
env["CXX"] = os.path.join(toolchain_bin, f"aarch64-linux-android28-clang++{cmd_ext}")
env["LINK"] = os.path.join(toolchain_bin, f"aarch64-linux-android28-clang++{cmd_ext}")
env["AR"] = os.path.join(toolchain_bin, f"llvm-ar{exe_ext}")
env["RANLIB"] = os.path.join(toolchain_bin, f"llvm-ranlib{exe_ext}")
env["SHLINKCOM"] = "$LINK -o $TARGET $LINKFLAGS -shared $__RPATH $SOURCES $_LIBDIRFLAGS $_LIBFLAGS"
env.Append(CCFLAGS = ["-fPIC"])
env.Append(CXXFLAGS = ["-DAS_USE_STLNAMES=1", "-ffunction-sections", "-O2", "-Wno-deprecated-array-compare", "-Wno-implicit-const-int-float-conversion", "-Wno-deprecated-enum-enum-conversion", "-Wno-absolute-value"])
env.Append(LINKFLAGS = ["-Wl,--no-fatal-warnings", "-Wl,--no-undefined", "-Wl,--gc-sections"])
env["PROGSUFFIX"] = ".so"
env["SHLIBSUFFIX"] = ".so"
