#!/bin/zsh
if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi
set -e
brew install autoconf automake libtool upx cmake ninja
echo Building NVGT...
if [[ "$IS_CI" != 1 ]]; then
	# Assumed to not be running on CI; NVGT should be cloned outside of deps first.
	echo Not running on CI.
	git clone --depth 1 https://github.com/samtupy/nvgt||true
	cd nvgt
else
	echo Running on CI.
fi
cmake --preset macos
cmake --build --preset macos
echo Building NVGT IOS stubs...
cmake --preset ios
cmake --build --preset ios
echo NVGT built.
