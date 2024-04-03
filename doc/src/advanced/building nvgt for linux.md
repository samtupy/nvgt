# build on linux
Please keep in mind that this is a very very rough draft, I've only done this once before when I built nvgt's server components for stw. This will attempt to describe, even for a user who doesn't use linux much, how to build nvgt at least on Ubuntu 22.04 LTS.

## tools
You will need the GNU compiler collection / GNU make / a few other tools. You can see if you already have these on your installation by running gcc, g++, make. If this fails, run sudo apt install build-essential gcc g++ make autoconf libtool.

## commands
mkdir deps && cd deps
git clone https://github.com/codecat/angelscript-mirror
cd deps/angelscript-mirror/sdk/angelscript/projects/gnuc
make
sudo make install

sudo apt install libssl-dev libcurl4-openssl-dev libopus-dev libsdl2-dev
sudo apt remove libsdl2-dev # first command installs version that is too old, but still installs loads of deps, now build sdl.
cd deps
*download sdl into a folder called SDL.
mkdir SDL_Build
cd SDL_Build
cmake ../SDL
cmake --build .
sudo cmake --install .
cp sdl2-config /usr/bin
chmod +x /usr/bin/sdl2-config

cd deps
git clone https://github.com/pocoproject/poco
cd poco
./configure --static --no-tests --no-samples
make -s -j<n> where <n> is number of CPU cores to use
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
* incomplete, just leave these here encase we use enough of bullet3 to use more than its header files.

cd deps
git clone https://github.com/libgit2/libgit2
cd libgit2
mkdir build
cd build
cmake ..
cmake --build .
sudo cmake --install .

build angelscript addons by running nvgt/dep/add_on/build.sh
Then build misc deps by running nvgt/dep/minideps/_build.sh
Compile builtin sqlite to object code: cd nvgt/dep/sqlite3, then gcc -D SQLITE_CORE *.c -c
run nvgt/build.sh!
