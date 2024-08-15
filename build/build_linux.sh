#!/bin/bash

function setup_angelscript {
	echo Installing Angelscript...
	git clone --depth 1 https://github.com/codecat/angelscript-mirror||true
	cd "angelscript-mirror/sdk/angelscript/projects/gnuc"
	make -j$(nproc)
	sudo make install
	cd ../../../../..
	echo Angelscript installed.
}

function setup_bullet {
	echo Installing bullet3...
	sudo apt install python3-dev -y
	git clone --depth 1 https://github.com/bulletphysics/bullet3||true
	cd bullet3
	./build_cmake_pybullet_double.sh
	cd build_cmake
	sudo cmake --install .
	cd ../..
}

function setup_enet {
	echo Installing enet...
	git clone --depth 1 https://github.com/lsalzman/enet||true
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
	curl -s -O -L https://github.com/libgit2/libgit2/archive/refs/tags/v1.8.1.tar.gz
	tar -xzf v1.8.1.tar.gz
	cd libgit2-1.8.1
	mkdir -p build
	cd build
	cmake .. -DBUILD_TESTS=OFF -DUSE_ICONV=OFF -DBUILD_CLI=OFF -DCMAKE_BUILD_TYPE=Release
	cmake --build .
	sudo cmake --install .
	cd ../..
	rm v1.8.1.tar.gz
	echo libgit2 installed.
}

function setup_poco {
	echo Installing poco...
	curl -s -O https://pocoproject.org/releases/poco-1.13.3/poco-1.13.3-all.tar.gz
	tar -xzf poco-1.13.3-all.tar.gz
	cd poco-1.13.3-all
	mkdir -p cmake_build
	cd cmake_build
	export CFLAGS=-fPIC
	export CXXFLAGS=-fPIC
	cmake .. -DENABLE_TESTS=OFF -DENABLE_SAMPLES=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DENABLE_ACTIVERECORD=OFF -DENABLE_ACTIVERECORD_COMPILER=OFF -DENABLE_XML=OFF -DENABLE_MONGODB=OFF -DBUILD_SHARED_LIBS=OFF
	cmake --build .
	sudo cmake --install .
	cd ../..
	rm poco-1.13.3-all.tar.gz
	echo poco installed.
}

function setup_sdl {
	echo Installing SDL...
	# Install SDL this way to get many SDL deps. It is too old so we remove SDL itself and build from source, however.
	sudo apt install libssl-dev libcurl4-openssl-dev libopus-dev libsdl2-dev -y
	sudo apt remove libsdl2-dev -y
	git clone --depth 1 https://github.com/libsdl-org/SDL||true
	mkdir -p SDL/build
	cd SDL/build
	cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST_LIBRARY=OFF ..
	cmake --build . --config MinSizeRel
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
		
		git clone --depth 1 https://github.com/samtupy/nvgt||true
		cd nvgt
	
	else
		echo Running on CI.
		cd ..
	fi
	
	echo Downloading lindev...
	wget https://nvgt.gg/lindev.tar.gz
	mkdir -p lindev
	cd lindev
	tar -xvf ../lindev.tar.gz
	cd ..
	rm lindev.tar.gz
	if ! which scons &> /dev/null; then
		pip3 install --user --break-system-packages scons
	fi
	scons -s no_upx=0
	echo NVGT built.
}

function main {
	set -e
	mkdir -p deps
	cd deps
	
	# Insure required packages are installed for building.
	sudo apt install build-essential gcc g++ make cmake autoconf libtool python3 python3-pip libsystemd-dev libspeechd-dev -y
	
	#setup_angelscript
	#setup_bullet
	#setup_enet
	#setup_libgit2
	#setup_poco
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
