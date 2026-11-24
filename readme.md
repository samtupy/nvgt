# The NonVisual Gaming Toolkit (NVGT)
[Website](https://nvgt.dev)

## What is NVGT?
NVGT is a cross-platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like Unity or Unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who isn't interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at [nvgt.dev](https://nvgt.dev).

## Building
You will need a C++ build toolchain if you want to build NVGT from source. On Windows we recommend the Visual Studio Build command line tools or the very latest version of Visual Studio 2026. On Mac-OS you will need at least the command line development tools if not Xcode, and a functioning GNU/G++ compiler collection is expected to be available on Linux.

NVGT is built with [CMake](https://cmake.org) 3.22 or later and [Ninja](https://ninja-build.org). Visual Studio includes both in its C++ CMake tools component. On macOS you can get them with `brew install cmake ninja`, and on Ubuntu with `sudo apt install cmake ninja-build`.

NVGT's dependencies come prebuilt, one archive per platform: [windev.zip](https://nvgt.dev/windev.zip), [macosdev.zip](https://nvgt.dev/macosdev.zip), [lindev.zip](https://nvgt.dev/lindev.zip) and [droidev.zip](https://nvgt.dev/droidev.zip). The build downloads the one for your platform into the root of the repository, such as nvgt/windev, and updates it when a newer one is published. If you'd rather build the dependencies yourself, clone the repository with submodules and configure with `-DNVGT_DEPS=build`, which runs vcpkg/build_dependencies.py. A separate readme is provided in the vcpkg directory for more information. `-DNVGT_DEPS=unmanaged` leaves whatever is in place alone, and `-DNVGT_DEPS_PATH=<path>` uses dependencies from somewhere else.

To build, open a terminal in the root of the NVGT repository and run:

```
cmake --preset windows
cmake --build --preset windows
```

Use the `linux` or `macos` preset on those platforms, `ios` for the iOS stubs, or a `-debug` preset such as `windows-debug` for a debug build. On Windows run these from a Visual Studio x64 developer command prompt. Everything is built in build/<preset>, which also gets a compile_commands.json for editors, and NVGT, its stubs and its plugins are then copied to the release folder, so release always holds whatever was built last.

Options are passed when configuring and remembered for that build folder, for example:

* `-DNVGT_STUBS=OFF` skips the stubs, which saves time during active development.
* `-DNVGT_PLUGIN_CURL=OFF -DNVGT_PLUGIN_GIT=OFF` disables the Curl and Git plugins. Every plugin has an `NVGT_PLUGIN_<name>` option.
* `-DNVGT_SHARED_PLUGINS=OFF` builds plugins only for linking statically, and `"-DNVGT_STATIC_PLUGINS=sqlite;unicode"` links the given plugins into NVGT, as does listing them in user/static_plugins.
* `-DNVGT_UPX=ON` also makes UPX packed Windows stubs.

All of the options are listed at the top of CMakeLists.txt, and `cmake -LH build/windows` prints them with their current values. `cmake --install build/windows` installs a Windows build to C:/nvgt.

### Android
Separate documentation is provided [in the building NVGT for android document](https://github.com/samtupy/nvgt/blob/main/doc/src/advanced/Building%20NVGT%20for%20Android.md) which gives instructions and details for building on this platform.

## Contributing
Contributions to NVGT are extremely welcome and are what help the project grow. Please view the [contribution guidelines](.github/CONTRIBUTING.md) before you contribute.
