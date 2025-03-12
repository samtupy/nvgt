#!/bin/zsh

function setup_homebrew {
	brew install autoconf automake libtool upx
}

function setup_reactphysics {
	echo Installing reactphysics3d...
	git clone --depth 1 https://github.com/DanielChappuis/reactphysics3d||true
	cd reactphysics3d
	mkdir build_cmake
	cd build_cmake
	cmake -S.. -B. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
	cmake --build . --config MinSizeRel -j$(nsysctl -n hw.ncpu)
	sudo cmake --install .
	cd ../..
}

function setup_libgit2 {
	curl -s -O -L https://github.com/libgit2/libgit2/archive/refs/tags/v1.8.1.tar.gz
	tar -xzf v1.8.1.tar.gz
	cd libgit2-1.8.1
	mkdir -p build
	cd build
	cmake .. -DBUILD_TESTS=OFF -DUSE_ICONV=OFF -DBUILD_CLI=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
	cmake --build . -j$(nsysctl -n hw.ncpu)
	sudo cmake --install .
	cd ../..
	rm v1.8.1.tar.gz
}

function setup_libplist {
	echo Installing libplist...
	curl -s -O -L https://github.com/libimobiledevice/libplist/releases/download/2.6.0/libplist-2.6.0.tar.bz2
	tar -xf libplist-2.6.0.tar.bz2
	cd libplist-2.6.0
	./configure --without-cython CC="clang -arch x86_64 -arch arm64" CXX="clang++ -arch x86_64 -arch arm64" CPP="clang -E" CXXCPP="clang++ -E"
	make -j$(nsysctl -n hw.ncpu)
	sudo make install
	cd ..
	rm libplist-2.6.0.tar.bz2
	echo libplist installed.
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
	python3 -m venv venv --upgrade-deps
	chmod +x venv/bin/activate
	source ./venv/bin/activate
	pip3 install scons
	mkdir -p deps
	cd deps
	setup_homebrew
	setup_reactphysics
	setup_libgit2
	setup_libplist
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
