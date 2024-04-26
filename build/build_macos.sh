#!/bin/zsh

function setup_angelscript {
	echo Installing Angelscript...
	git clone https://github.com/codecat/angelscript-mirror
	cd "angelscript-mirror/sdk/angelscript/projects/cmake"
	mkdir build
	cd build
	cmake ..
	cmake --build .
	sudo cmake --install .
	cd ../../../../../..
	echo Angelscript installed.
}

function setup_bullet {
	echo Installing bullet3...
	brew install bullet
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
	./configure --static --no-tests --no-samples
	make -s -j16
	sudo make install
	cd ..
	echo poco installed.
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
	wget https://nvgt.gg/macosdev.tar.gz
	mkdir macosdev
	cd macosdev
	tar -xvf ../macosdev.tar.gz
	cd ..
	rm macosdev.tar.gz
	scons -s
	echo NVGT built.
}

function main {
	set -e
	mkdir deps
	cd deps
	
	setup_angelscript
	setup_bullet
	setup_enet
	setup_libgit2
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
