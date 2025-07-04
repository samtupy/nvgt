# Building NVGT on linux

## Building with the `build_linux.sh` script
There is a [script to build NVGT on Linux](https://raw.githubusercontent.com/samtupy/nvgt/main/build/build_linux.sh) (tested on Debian and Ubuntu). It tends to build pretty portably so you can run it basically anywhere, and it will attempt to successfully download all required dependencies and build them for you. The result will be a fully built NVGT.

Internally, this script is used within our GitHub Actions to make builds of NVGT. It is also used within our local testing environments.

### Notes
* This script will currently only run on systems where `apt` and `pip` are installed, and does not support any other package managers.
* This script will create and activate a [virtual environment](https://docs.python.org/3/library/venv.html).

This script can be ran in two modes:
* Adding `ci` as an argument causes the dependencies to be downloaded in the current working directory inside a `deps` folder (useful if you already are working from within NVGT's source directory).
* If `ci` is not present, the script will assume NVGT is not downloaded and will clone NVGT into the current directory before attempting to build it.

### Example of Running the script with the `ci` argument
It is assumed you are in a freshly-cloned NVGT, so that your working directory ends with `nvgt`.
```
chmod +x build/build_linux.sh
./build/build_linux.sh ci
```

It will then attempt to download all required packages and build NVGT. This will take some time.

### Example of Running the script without the `ci` argument
Insure you are in a working directory where you are okay with the script making a few folders; in particular `deps` and `nvgt`. This is where all of the downloading, building, etc. will occur. The below example assumes that build_linux.sh is in the same directory, but it does not assume NVGT is already downloaded.
```
chmod +x build_linux.sh
./build_linux.sh
```

## Building NVGT manually
If you wish to build manually, some rather old instructions are below. At this time, it would probably be much more beneficial to read the `build_linux.sh` script or [readme.md](https://github.com/samtupy/nvgt) for much more updated commands; the below commands are here for reference and aren't updated often.

Please keep in mind that this is a very very rough draft, I've only done this once before when I built nvgt's server components for stw. This will attempt to describe, even for a user who doesn't use linux much, how to build nvgt at least on Ubuntu 22.04 LTS.

## tools
You will need the GNU compiler collection / GNU make / a few other tools. You can see if you already have these on your installation by running `gcc`, `g++`, `make`. If this fails, run `sudo apt install build-essential gcc g++ make autoconf libtool`.

## commands
```bash
mkdir deps && cd deps
git clone https://github.com/codecat/angelscript-mirror
cd deps/angelscript-mirror/sdk/angelscript/projects/gnuc
make
sudo make install

sudo apt install libssl-dev libcurl4-openssl-dev libopus-dev libsdl2-dev
sudo apt remove libsdl2-dev
```

## Note
The first command installs a version of SDL that is too old, but still installs loads of deps. Now we will build sdl.

`cd deps`

Before continuing, download sdl into a folder called SDL.

```bash
mkdir SDL_Build
cd SDL_Build
cmake ../SDL
cmake --build .
sudo cmake --install .

cd deps
git clone https://github.com/pocoproject/poco
cd poco
./configure --static --no-tests --no-samples --cflags=-fPIC
make -s -j2
```

## Note
The 2 in `make -j2` is how many CPU cores you would like to use when building. Change this to the number of CPU cores you would like to use. If you do not know how many cores your system has, you can use the `lscpu` command on many distributions to check.

```bash
sudo make install

cd deps
git clone https://github.com/lsalzman/enet
cd enet
autoreconf -vfi
./configure
make
sudo make install

cd deps
git clone https://github.com/bulletphysics/bullet3
cd bullet3
./build_cmake_pybullet_double.sh
cd cmake_build
sudo cmake --install .
```

```bash
cd deps
git clone https://github.com/libgit2/libgit2
cd libgit2
mkdir build
cd build
cmake ..
cmake --build .
sudo cmake --install .
```

You will need scons, which you can get by running pip3 install scons.

## Finally...
cd to the root of the nvgt repository and extract https://nvgt.gg/lindev.tar.gz to a lindev folder there.

scons -s

Enjoy!
