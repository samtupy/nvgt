# Building NVGT on linux
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
The 2 in `make -j2` is how many CPU cores you would like to use when building. Change this to the number of CPU cores you would like to use. If you do not know how many cores your system has, you can use the `lscpu` command on many distrobutions to check.

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
```

## Note
NVGT only uses Bullet3 for its header files at the time of writing; all you must do is clone the repository.

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

## Next steps
* Build angelscript addons by running `nvgt/dep/add_on/build.sh`
* Then build misc deps by running `nvgt/dep/minideps/_build.sh`
To Compile builtin sqlite to object code: `cd nvgt/dep/sqlite3; gcc -D SQLITE_CORE *.c -c`
* Then to finally finish the build, run `nvgt/build.sh`!
