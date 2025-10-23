# The NonVisual Gaming Toolkit (NVGT)
[Website](https://nvgt.gg)

## What is NVGT?
NVGT is a cross platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like unity or unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who is not interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at [nvgt.gg](https://nvgt.gg).

## Building
You will need a C++ build toolchain if you want to build NVGT from source. On Windows we recommend the Visual Studio Build command line tools or the very latest version of Visual Studio 2022. On Mac-OS you will need at least the command line development tools if not Xcode, and a functioning GNU/G++ compiler collection is expected to be available on Linux.

NVGT uses SCons, a Python build system. If you have Python, you can get it by running `pip install scons`.

We provide prebuilt development libraries for NVGT, these are all of the dependencies required to make the project build. You should download the file that matches the platform you are building for.
* [windev.zip](https://nvgt.gg/windev.zip)
* [macosdev.zip](https://nvgt.gg/macosdev.zip)
* [lindev.zip](https://nvgt.gg/lindev.zip)
* [droidev.zip](https://nvgt.gg/droidev.zip)

Extract the file you downloaded in the root of the NVGT repo, so that you have a directory structure that looks like, for example, nvgt/windev/include.

If you would rather build the dependencies yourself, be sure to clone the repository with submodules and then use Python to run the vcpkg/build_dependencies.py script. A separate readme is provided in the vcpkg directory for more information.

Once dependencies are in place, you can now open a command prompt or terminal window up to the root of the NVGT repository and run `scons -s` to build NVGT.

If you do not want to build plugins, you can run, for example, `scons -s no_curl_plugin=1 no_git_plugin=1` to disable the Curl and Git plugins.

You can disable the creation of shared plugin DLLs with the option `no_shared_plugins=1`.

If you do not want to build the stubs, such as for active development where generating them would be time consuming, you can pass `no_stubs=1` to the scons command.

If you want to see what other custom switches are available in NVGT's SConstruct file, you can run `scons -s -h` or even just `scons -h` if you want a bit of extra useless verbosity.

You can omit the `-s` from the build command if you want to get spammed with the outputting of every internal build command used, which is hundreds of them.

### Android
Separate documentation is provided [in the Building NVGT for Android Document](https://github.com/samtupy/nvgt/blob/main/doc/src/advanced/Building%20NVGT%20for%20Android.md) which gives instructions and details for building on this platform.

## Contributing
Contributions to NVGT are extremely welcome and are what help the project grow. Please view the [contribution guidelines](.github/CONTRIBUTING.md) before you contribute.
