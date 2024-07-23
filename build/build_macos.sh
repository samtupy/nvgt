#!/bin/zsh

function setup_homebrew {
	brew install autoconf automake libtool openssl sdl2 libgit2 bullet upx
}

function setup_angelscript {
	echo Installing Angelscript...
	git clone --depth 1 https://github.com/codecat/angelscript-mirror||true
	cd "angelscript-mirror/sdk/angelscript/projects/cmake"
	mkdir -p build
	cd build
	cmake ..
	cmake --build .
	sudo cmake --install .
	cd ../../../../../..
	echo Angelscript installed.
}

function setup_enet {
	echo Installing enet...
	git clone --depth 1 https://github.com/lsalzman/enet||true
	cd enet
	autoreconf -vfi
	./configure
	make -j$(nsysctl -n hw.ncpu)
	sudo make install
	cd ..
	echo Enet installed.
}

function setup_libgit2 {
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
}

function setup_poco {
	curl -s -O https://pocoproject.org/releases/poco-1.13.3/poco-1.13.3-all.tar.gz
	tar -xzf poco-1.13.3-all.tar.gz
	cd poco-1.13.3-all
	mkdir -p cmake_build
	cd cmake_build
	cmake .. -DENABLE_TESTS=OFF -DENABLE_SAMPLES=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DENABLE_ACTIVERECORD=OFF -DENABLE_ACTIVERECORD_COMPILER=OFF -DENABLE_XML=OFF -DENABLE_MONGODB=OFF -DBUILD_SHARED_LIBS=OFF
	cmake --build .
	sudo cmake --install .
	cd ../..
	rm poco-1.13.3-all.tar.gz
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
	
	echo Downloading macosdev...
	curl -s -O https://nvgt.gg/macosdev.tar.gz
	mkdir -p macosdev
	cd macosdev
	tar -xvf ../macosdev.tar.gz
	cd ..
	rm macosdev.tar.gz
	scons -s
	echo NVGT built.
}

function main {
	set -e
	mkdir -p deps
	cd deps
	setup_homebrew
	setup_angelscript
	setup_enet
	#setup_libgit2
	setup_poco
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
