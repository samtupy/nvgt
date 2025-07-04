# The NonVisual Gaming Toolkit (NVGT)
[Website](https://nvgt.gg)

## What is NVGT?
NVGT is a cross platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like unity or unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who isn't interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at [nvgt.gg](https://nvgt.gg).

## Building
You will need a C++ build toolchain if you want to build NVGT from source. On Windows we recommend the Visual Studio Build command line tools or the very latest version of Visual Studio 2022. On Mac-OS you will need at least the command line development tools if not Xcode, and a functioning GNU/G++ compiler collection is expected to be available on Linux.

NVGT uses SCons, a Python build system. If you have Python, you can get it by running `pip install scons`.

Other than SCons, the following libraries are needed to build NVGT's core:
* AngelScript scripting library
* bass, bassmix and bass-fx from un4seen if you wish to build the legacy sound system
* Enet networking library - we use a custom fork called enet6 with IPV6 support
* libplist to create MacOS bundles
* ogg and opus codecs
* Phonon / steam audio
* Poco C++ portable components
* Reactphysics3d
* SDL3
* Universal speech

By default, NVGT will try to build all plugins contained within the plugin folder. Furthermore, if you check out the repository with submodules, the [nvgt_extra repository](https://github.com/samtupy/nvgt_extra) will be cloned into a subfolder called extra, in which case all plugins contained within extra/plugin/integrated will be automatically built by default as well. This means that unless you use the no_plugins=1 SCons switch or else the switches that disable individual plugins, you might also need the following dependencies.
* Bass, bassmix and bass_fx from un4seen to build plugin/legacy_sound
* libcurl to build extra/plugin/integrated/curl
* libgit2 to build extra/plugin/integrated/git

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
Separate documentation is provided [in the building NVGT for android document](https://github.com/samtupy/nvgt/blob/main/doc/src/advanced/Building%20NVGT%20for%20Android.md) which gives instructions and details for building on this platform.

## Contributing
Contributions to NVGT are extremely welcome and are what help the project grow. Please view the [contribution guidelines](.github/CONTRIBUTING.md) before you contribute.
