# Notes for building on macOS

## Building with the `build_macos.sh` script
There is a [script to build NVGT on macOS](https://raw.githubusercontent.com/samtupy/nvgt/main/build/build_macos.sh). It will build pretty portably so you can run it basically anywhere (assuming you have Homebrew and the Xcode command line tools). It will attempt to successfully download all required dependencies and build them for you. The result will be a fully built NVGT.

Internally, this script is used within our GitHub Actions to make builds of NVGT. It is also used within our local testing environments.

This script can be ran in two modes:
* Adding `ci` as an argument causes the dependencies to be downloaded in the current working directory inside a `deps` folder (useful if you already are working from within NVGT).
* If `ci` is not present, the script will assume NVGT is not downloaded and will clone NVGT before attempting to build it.

### Example of Running the script with the `ci` argument
It is assumed you are in a freshly-cloned NVGT, so that your working directory ends with `nvgt`.
```
chmod +x build/build_macos.sh
./build/build_macos.sh ci
```

It will then attempt to download all required packages and build NVGT. This will take some time.

### Example of Running the script without the `ci` argument
Insure you are in a working directory where you are okay with the script making a few folders; in particular `deps` and `nvgt`. This is where all of the downloading, building, etc. will occur. The below example assumes that build_macos.sh is in the same directory, but it does not assume NVGT is already downloaded.

```
chmod +x build_macos.sh
./build_macos.sh
```


## Building NVGT manually
Below are some older notes for building NVGT for macOS.

Assuming xcode and homebrew are installed:

```bash
pip3 install scons
brew install autoconf automake libgit2 libtool openssl sdl2 bullet

mkdir deps
git clone https://github.com/codecat/angelscript-mirror
cd "angelscript-mirror/sdk/angelscript/projects/cmake"
mkdir build; cd build
cmake ..
cmake --build .
sudo cmake --install .

cd deps
git clone https://github.com/lsalzman/enet
cd enet
autoreconf -vfi
./configure
make
sudo make install

cd deps
git clone https://github.com/pocoproject/poco
cd poco
./configure --static --no-tests --no-samples
make -s -j<n> where <n> is number of CPU cores to use
sudo make install

cd deps
git clone https://github.com/libgit2/libgit2
cd libgit2
mkdir build
cd build
cmake ..
cmake --build .
sudo cmake --install .

cd nvgt
scons -s
```
