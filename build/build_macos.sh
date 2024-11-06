#!/bin/zsh

function setup_homebrew {
	brew install autoconf automake libtool upx
}

function setup_openssl {
	echo Installing OpenSSL...
	curl -s -O -L https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz
	tar -xzf openssl-3.3.2.tar.gz
	mv openssl-3.3.2 openssl-3.3.2-arm||true
	tar -xzf openssl-3.3.2.tar.gz
	mv openssl-3.3.2 openssl-3.3.2-x64||true
	cd openssl-3.3.2-arm
	./Configure enable-rc5 zlib darwin64-arm64-cc no-asm no-apps no-docs no-filenames no-shared --release
	make -j$(nsysctl -n hw.ncpu)
	sudo make install
	cd ../openssl-3.3.2-x64
	./Configure darwin64-x86_64-cc no-apps no-docs no-filenames --release
	make -j$(nsysctl -n hw.ncpu)
	cd ..
	mkdir -p openssl-fat
	lipo -create openssl-3.3.2-arm/libcrypto.a openssl-3.3.2-x64/libcrypto.a -output openssl-fat/libcrypto.a
	lipo -create openssl-3.3.2-arm/libssl.a openssl-3.3.2-x64/libssl.a -output openssl-fat/libssl.a
	sudo cp openssl-fat/*.a /usr/local/lib
	rm openssl-3.3.2.tar.gz
	echo OpenSSL installed.
}

function setup_angelscript {
	echo Installing Angelscript...
	git clone https://github.com/codecat/angelscript-mirror||true
	cd "angelscript-mirror/sdk/angelscript/projects/cmake"
	git checkout 270b98a332faa57a747c9265086c7bce49c041d9
	mkdir -p build
	cd build
	cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
	cmake --build . -j$(nsysctl -n hw.ncpu)
	sudo cmake --install .
	cd ../../../../../..
	echo Angelscript installed.
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

function setup_enet {
	echo Installing enet...
	git clone --depth 1 https://github.com/lsalzman/enet||true
	cd enet
	autoreconf -vfi
	./configure CC="clang -arch x86_64 -arch arm64" CXX="clang++ -arch x86_64 -arch arm64" CPP="clang -E" CXXCPP="clang++ -E"
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

function setup_poco {
	curl -s -O https://pocoproject.org/releases/poco-1.13.3/poco-1.13.3-all.tar.gz
	tar -xzf poco-1.13.3-all.tar.gz
	cd poco-1.13.3-all
	mkdir -p cmake_build
	cd cmake_build
	cmake .. -DENABLE_TESTS=OFF -DENABLE_SAMPLES=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DENABLE_ACTIVERECORD=OFF -DENABLE_ACTIVERECORD_COMPILER=OFF -DENABLE_MONGODB=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS=-DPOCO_UTIL_NO_XMLCONFIGURATION
	cmake --build . -j$(nsysctl -n hw.ncpu)
	sudo cmake --install .
	cd ../..
	rm poco-1.13.3-all.tar.gz
}

function setup_sdl {
	echo Installing SDL...
	git clone https://github.com/libsdl-org/SDL||true
	mkdir -p SDL/build
	cd SDL/build
	git checkout 4e09e58f62e95a66125dae9ddd3e302603819ffd
	cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST_LIBRARY=OFF -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" ..
	cmake --build . --config MinSizeRel -j$(nsysctl -n hw.ncpu)
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
	setup_openssl
	setup_angelscript
	setup_reactphysics
	setup_enet
	setup_libgit2
	setup_poco
	setup_sdl
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
