#!/bin/bash

function setup_angelscript {
	echo Installing Angelscript...
	git clone https://github.com/codecat/angelscript-mirror||true
	cd "angelscript-mirror/sdk/angelscript/projects/gnuc"
	git checkout 270b98a332faa57a747c9265086c7bce49c041d9
	make -j$(nproc)
	sudo make install
	cd ../../../../..
	echo Angelscript installed.
}

function setup_reactphysics {
	echo Installing reactphysics3d...
	git clone --depth 1 https://github.com/DanielChappuis/reactphysics3d||true
	cd reactphysics3d
	mkdir build_cmake
	cd build_cmake
	cmake -S.. -B. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
	cmake --build . --config MinSizeRel -j$(nproc)
	sudo cmake --install .
	cd ../..
}

function setup_libgit2 {
	echo Installing libgit2...
	curl -s -O -L https://github.com/libgit2/libgit2/archive/refs/tags/v1.8.1.tar.gz
	tar -xzf v1.8.1.tar.gz
	cd libgit2-1.8.1
	mkdir -p build
	cd build
	cmake .. -DBUILD_TESTS=OFF -DUSE_ICONV=OFF -DBUILD_CLI=OFF -DCMAKE_BUILD_TYPE=Release
	cmake --build . -j$(nproc)
	sudo cmake --install .
	cd ../..
	rm v1.8.1.tar.gz
	echo libgit2 installed.
}

function setup_libplist {
	echo Installing libplist...
	curl -s -O -L https://github.com/libimobiledevice/libplist/releases/download/2.6.0/libplist-2.6.0.tar.bz2
	tar -xf libplist-2.6.0.tar.bz2
	cd libplist-2.6.0
	./configure --without-cython
	make -j$(nproc)
	sudo make install
	cd ..
	rm libplist-2.6.0.tar.bz2
	echo libplist installed.
}

function setup_poco {
	echo Installing poco...
	curl -s -O https://pocoproject.org/releases/poco-1.13.3/poco-1.13.3-all.tar.gz
	tar -xzf poco-1.13.3-all.tar.gz
	cd poco-1.13.3-all
	mkdir -p cmake_build
	cd cmake_build
	export CFLAGS="-fPIC -DPOCO_UTIL_NO_XMLCONFIGURATION"
	export CXXFLAGS="-fPIC -DPOCO_UTIL_NO_XMLCONFIGURATION"
	cmake .. -DENABLE_TESTS=OFF -DENABLE_SAMPLES=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DENABLE_ACTIVERECORD=OFF -DENABLE_ACTIVERECORD_COMPILER=OFF -DENABLE_MONGODB=OFF -DBUILD_SHARED_LIBS=OFF
	cmake --build . -j$(nproc)
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
	git clone https://github.com/libsdl-org/SDL||true
	mkdir -p SDL/build
	cd SDL/build
	git checkout 4e09e58f62e95a66125dae9ddd3e302603819ffd
	cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST_LIBRARY=OFF ..
	cmake --build . --config MinSizeRel -j$(nproc)
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
		pip3 install scons
	fi
	scons -s no_upx=0
	echo NVGT built.
}

function main {
	sudo apt update -y
	set -e
	python3 -m venv venv --upgrade-deps
	chmod +x venv/bin/activate
	source ./venv/bin/activate
	mkdir -p deps
	cd deps
	
	# Insure required packages are installed for building.
	sudo apt install build-essential gcc g++ make cmake autoconf libtool python3 python3-pip libssl-dev libsystemd-dev libspeechd-dev -y
	
	setup_angelscript
	setup_reactphysics
	setup_libgit2
	setup_libplist
	setup_poco
	setup_sdl
	setup_nvgt
	echo Success!
	deactivate
	exit 0
}

if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi

main
