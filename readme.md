# the NonVisual Gaming Toolkit (NVGT)
[website](https://nvgt.gg)

## What is NVGT?
NVGT is a cross platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like unity or unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who isn't interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at nvgt.gg.

## building
You will need a c++ build toolchain if you want to build NVGT from source. On windows we recommend the visual studio build command line tools or the very latest version of visual studio 2022. On macos you will need at least the command line development tools if not xcode, and a functioning GNU/g++ compiler collection is expected to be available on linux.

NVGT uses SCons, a python build system. If you have python, you can get it by running `pip install scons`.

Other than scons, the following libraries are needed to build NVGT:
* Angelscript scripting library
* bullet3 physics library, though at the time of writing only some headers (the Bullet3Common and LinearMath folders) are neded
* enet networking library
* Poco C++ portable components
* SDL2

You also need to locate headers and binaries for the bass audio library (bass, bassmix and bass_fx) and for phonon (steam audio) though some are provided if you want to use those.

If you want to build all plugins, you will also need the curl and libgit2 libraries.

For Linux and MacOS, scripts with build commands are in build/build_linux.sh and build/build_macos.sh.

For now only on windows, the option exists to make the process of dealing with dependencies much simpler than hunting them down manually and setting up include/library paths. For those who want them, I've decided to provide my own build artifacts. This is a bin/include/lib directory structure that contains organised header files, link libraries (static when possible), and dlls for distribution like bass and phonon which makes building nvgt as simple as pointing to this directory structure and running the build command. This download contains more than the libraries specifically required to build NVGT as A, it includes the libraries required to build plugins and B, it may include libraries that I use in other projects. If it gets giant, I'll provide a download just containing nvgt libraries. For now, you can 
[download windev.zip here](https://nvgt.gg/windev.zip) and place an extracted version of it in the root of the nvgt repository, that is a folder called windev containing bin, include, lib, misc should exist in the root of the nvgt repo.

Though unlike the windev.zip file these only contain binaries for the bass and steam audio versions we are using at present, you can also [download macosdev.tar.gz](https://nvgt.gg/macosdev.tar.gz) for MacOS or [download lindev.tar.gz](https://nvgt.gg/lindev.tar.gz) for Linux to ease at least some of the dependancy hunt.

Once dependencies are in place, you can now open a command prompt or terminal window up to the root of the nvgt repository and run `scons -s` to build nvgt.

If you don't want to build plugins, you can run, for example, `scons -s no_curl_plugin=1 no_git_plugin=1` to disable the curl and git plugins.

You can disable the creation of shared plugin dlls with the option no_shared_plugins=1.

If you do not want to build the stubs, such as for active development where generating them would be time consuming, you can pass no_stubs=1 to the scons command.

You can omit the -s from the build command if you want to get spammed with the outputting of every internal build command used, which is hundreds of them.

