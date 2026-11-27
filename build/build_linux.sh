#!/bin/bash
if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi
sudo apt update -y
sudo apt install -y build-essential cmake ninja-build libtool libsystemd-dev libasound2-dev libx11-dev libgtk-4-dev libglib2.0-dev libspeechd-dev libudev-dev linux-libc-dev libxrandr-dev pkg-config zip gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
set -e
echo Building NVGT...
if [[ "$IS_CI" != 1 ]]; then
	# Assumed to not be running on CI; NVGT should be cloned outside of deps first.
	echo Not running on CI.
	git clone --depth 1 https://github.com/samtupy/nvgt||true
	cd nvgt
else
	echo Running on CI.
fi
cmake --preset linux
cmake --build --preset linux
echo NVGT built.
