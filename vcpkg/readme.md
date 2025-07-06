# vcpkg

This directory contains NVGT's vcpkg integration, which is an easy way to build all of NVGT's dependencies in just one command.

To build the dependencies, run the build_dependencies.py script. The script takes a --archive argument to zip up the dependencies for distrobution, used by NVGT's CI. Then you can pass any optional triplets you wish to build, for example arm64-android, x64-windows etc. If you are building for Android you must have the NDK on your path and the NDK-HOME environment variable set.

For example to build for your host platform, you might run: `python3 build_dependencies.py` but to build for both Windows and Android, you might run `python3 build_dependencies.py arm64-android x64-windows` causing the dependencies for both platforms to be built in one command.

Be ware that this command will likely take quite a while to run, and will produce several gb of files on your harddrive.

While you can indeed run the standard bin/vcpkg install command to build the dependencies, it is recommended that you use the wrapper build_dependencies.py script because it does several things to the resulting vcpkg builds to set them up for NVGT development. For example on MacOS it builds openssl and libffi twice and then creates universal libraries out of them, on windows some libraries are renamed etc.

You should rarely need to run this yourself, as the public distributions of these dependencies we provide are a much faster way to get up and running, not to mention being smaller because no temporary build files exist.
