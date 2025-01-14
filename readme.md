# The NonVisual Gaming Toolkit (NVGT)
[Website](https://nvgt.gg)

## What is NVGT?
NVGT is a cross platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like unity or unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who isn't interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at [nvgt.gg](https://nvgt.gg).

## Building
You will need a C++ build toolchain if you want to build NVGT from source. On Windows we recommend the Visual Studio Build command line tools or the very latest version of Visual Studio 2022. On Mac-OS you will need at least the command line development tools if not Xcode, and a functioning GNU/G++ compiler collection is expected to be available on Linux.

NVGT uses SCons, a Python build system. If you have Python, you can get it by running `pip install scons`.

Other than SCons, the following libraries are needed to build NVGT:
* AngelScript scripting library
* bullet3 physics library, though at the time of writing only some headers (the Bullet3Common and LinearMath folders) are needed
* Enet networking library
* Poco C++ portable components
* SDL3

You also need to locate headers and binaries for the Bass Audio library (bass, bassmix and bass_fx) and for Phonon (Steam Audio) though some are provided if you want to use those.

If you want to build all plugins, you will also need the Curl and Libgit2 libraries.

For Linux and Mac-OS, scripts with build commands are in build/build_Linux.sh and build/build_macos.sh.

For now only on Windows, the option exists to make the process of dealing with dependencies much simpler than hunting them down manually and setting up include/library paths. For those who want them, I've decided to provide my own build artifacts. This is a bin/include/lib directory structure that contains organized header files, link libraries (static when possible), and DLLs for distribution like Bass and Phonon which makes building NVGT as simple as pointing to this directory structure and running the build command. This download contains more than the libraries specifically required to build NVGT as A, it includes the libraries required to build plugins and B, it may include libraries that I use in other projects. If it gets giant, I'll provide a download just containing NVGT libraries. For now, you can 
[download windev.zip here](https://nvgt.gg/windev.zip) and place an extracted version of it in the root of the NVGT repository, that is a folder called windev containing bin, include, lib, misc should exist in the root of the NVGT repository, as in nvgt/windev/bin, nvgt/windev/include etc.

Though unlike the windev.zip file these only contain binaries for the bass and steam audio versions we are using at present, you can also [download macosdev.tar.gz](https://nvgt.gg/macosdev.tar.gz) for Mac-OS or [download lindev.tar.gz](https://nvgt.gg/lindev.tar.gz) for Linux to ease at least some of the dependency hunt.

Once dependencies are in place, you can now open a command prompt or terminal window up to the root of the NVGT repository and run `scons -s` to build NVGT.

If you don't want to build plugins, you can run, for example, `scons -s no_curl_plugin=1 no_git_plugin=1` to disable the Curl and Git plugins.

You can disable the creation of shared plugin DLLs with the option `no_shared_plugins=1`.

If you do not want to build the stubs, such as for active development where generating them would be time consuming, you can pass `no_stubs=1` to the scons command.

If you want to see what other custom switches are available in NVGT's SConstruct file, you can run `scons -s -h` or even just `scons -h` if you want a bit of extra useless verbosity.

You can omit the `-s` from the build command if you want to get spammed with the outputting of every internal build command used, which is hundreds of them.

### Android
To build NVGT for Android, you will need the Android SDK. The easiest way to get this at least on Windows is if you have Visual Studio to download the Mobile Development workload, or else to install Android Studio.

As with other platforms, most of the work regarding building libraries has been done for you, you can download [droidev.zip](https://nvgt.gg/droidev.zip) here, and extract it similarly to how it is described above for other platforms. Look at jni/example-custom.mk to learn how to set a custom location to this directory.

On some systems, the Android SDK requires a bit of setup to use it extensively enough to build NVGT. If you are using Android Studio directly or if anything else has configured your Android SDK for you it is unlikely you'll need any of this, but in case you need to set up your SDK manually especially on Windows, here are a few notes:
1. The Android SDK on Windows must not be in a directory containing spaces, or at least must not be invoked with one. For example, the Mobile Development workload on Visual Studio by default installs the tools in "C:\Program Files (x86)\Android". So to use it, you may need to symlink the folder with a command run as administrator like `mklink /d C:\android "C:\Program Files (x86)\Android"`.
2. It may also be a good idea to run the Gradle tool (described below) as administrator if you get any weird access denied errors when trying to do it otherwise, you'll see it's trying to write to some file within the Android SDK directory which may require administrative rights to access depending on where it is installed. If you keep getting errors even after doing this, run `gradlew -stop` to kill any old Gradle daemons that were running without privileges.
3. There are a couple of environment variables you may need to set before building. These are the `ANDROID_NDK_HOME`, `ANDROID_HOME`, and `JAVA_HOME` variables which help locate the Android development tools for anything that needs them. An example of setting them at least for Windows is in other/droidev.bat.
4. If at any point you need to run sdkmanager to accept licenses on Windows, run it... yep, as admin. Otherwise you will be informed that the licenses have been successfully accepted, but when you try using the tools, you'll be told to accept them again.
5. It should be noted that both Visual Studio and Android Studio install a functioning Java runtime environment for you, so you don't have to go hunting for one. On Visual Studio, this may be at "C:\Program Files (x86)\Android\openjdk\jdk-17.0.8.101-hotspot", and for Android Studio it may be at "C:\Android\Android Studio\jre". Sadly these paths might change a bit over time (especially the JDK version in the Visual Studio path), so you may need to look up the latest paths if you are having trouble.

To build NVGT for Android, cd to the jni directory and run `gradlew assembleRunnerDebug assembleStubRelease`

On platforms other than Windows you may need to run `./gradlew` instead of `gradlew`.

If you want to install the runner application to any devices connected in debug mode, you can run `gradlew installRunnerDebug`.

Do not directly install the stub APK on your device, only do that for the runner application. In regards to the stub, after the Gradle build command succeeds, there is now a file in release/stub/nvgt_android.bin which should be moved into the stub folder of your actual NVGT installation, allowing NVGT to compile .APK files from game source code.

## Contributing
Contributions to NVGT are extremely welcome and are what help the project grow. Please view the [contribution guidelines](.github/CONTRIBUTING.md) before you contribute.