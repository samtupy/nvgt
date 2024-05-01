#!/bin/bash

function setup_angelscript {
	echo Installing Angelscript...
	git clone https://github.com/codecat/angelscript-mirror
	cd "angelscript-mirror/sdk/angelscript/projects/gnuc"
	make -j$(nproc)
	sudo make install
	cd ../../../../..
	echo Angelscript installed.
}

function setup_bullet {
	echo Installing bullet3...
	sudo apt install python3-dev -y
	git clone https://github.com/bulletphysics/bullet3
	cd bullet3
	./build_cmake_pybullet_double.sh
	cd build_cmake
	sudo cmake --install .
	cd ../..
}

function setup_enet {
	echo Installing enet...
	git clone https://github.com/lsalzman/enet
	cd enet
	autoreconf -vfi
	./configure
	make -j$(nproc)
	sudo make install
	cd ..
	echo Enet installed.
}

function setup_libgit2 {
	echo Installing libgit2...
	git clone https://github.com/libgit2/libgit2
	cd libgit2
	mkdir build
	cd build
	cmake ..
	cmake --build .
	sudo cmake --install .
	cd ../..
	echo libgit2 installed.
}

function setup_poco {
	echo Installing poco...
	git clone https://github.com/pocoproject/poco
	cd poco
	./configure --static --no-tests --no-samples --cflags=-fPIC
	make -s -j$(nproc)
	sudo make install
	cd ..
	echo poco installed.
}

function setup_sdl {
	echo Installing SDL...
	# Install SDL this way to get many SDL deps. It is too old so we remove SDL itself and build from source, however.
	sudo apt install libssl-dev libcurl4-openssl-dev libopus-dev libsdl2-dev -y
	sudo apt remove libsdl2-dev -y
	
	wget https://github.com/libsdl-org/SDL/releases/download/release-2.30.2/SDL2-2.30.2.tar.gz
	tar -xvf SDL2-2.30.2.tar.gz
	rm SDL2-2.30.2.tar.gz
	cd SDL2-2.30.2
	
	mkdir build
	cd build
	cmake ..
	cmake --build .
	sudo make install
	cd ../..
	echo SDL installed.
}

function setup_nvgt {
	echo Building NVGT...
	
	if [[ "$IS_CI" != 1 ]]; then
		# Assumed to not be running on CI; NVGT should be cloned outside of deps first.
		echo Not running on CI.
		cd ..	
		
		# TODO - make `git clone` when public, CI most likely won't have gh.
		gh repo clone https://github.com/samtupy/nvgt
		cd nvgt
	
	else
		echo Running on CI.
		cd ..
	fi
	
	echo Downloading lindev...
	wget https://nvgt.gg/lindev.tar.gz
	mkdir lindev
	cd lindev
	tar -xvf ../lindev.tar.gz
	cd ..
	rm lindev.tar.gz
	
	pip3 install --user --break-system-packages scons
	scons -s
	echo NVGT built.
}

function main {
	set -e
	mkdir deps
	cd deps
	
	# Insure required packages are installed for building.
	sudo apt install build-essential gcc g++ make cmake autoconf libtool python3 python3-pip libsystemd-dev -y
	
	setup_angelscript
	setup_bullet
	setup_enet
	setup_libgit2
	setup_poco
	setup_sdl
	setup_nvgt
	echo Success!
	exit 0
}

if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi

main
