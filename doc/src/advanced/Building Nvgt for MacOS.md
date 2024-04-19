# Rough notes for building on macOS
I have no idea what I'm doing here!

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
