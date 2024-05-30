#!/bin/zsh

function setup_homebrew {
	brew install autoconf automake libtool openssl sdl2 bullet
}

function setup_angelscript {
	echo Installing Angelscript...
	git clone https://github.com/codecat/angelscript-mirror
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
	git clone https://github.com/lsalzman/enet
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
	cd ../..
	rm v1.8.1.tar.gz
}

function setup_poco {
	curl -s -O https://pocoproject.org/releases/poco-1.13.3/poco-1.13.3-all.tar.gz
	tar -xzf poco-1.13.3-all.tar.gz
	cd poco-1.13.3-all
	./configure --static --no-tests --no-samples
	make -s -j16
	cd ..
	rm poco-1.13.3-all.tar.gz
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
