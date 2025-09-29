#!/bin/bash
if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi
sudo apt update -y
sudo apt install -y build-essential libtool libsystemd-dev libasound2-dev libx11-dev libgtk-4-dev libglib2.0-dev libspeechd-dev libudev-dev linux-libc-dev libxrandr-dev pkg-config zip  gcc-aarch64-linux-gnu g++-aarch64-linux-gnu python3-venv
set -e
python3 -m venv venv --upgrade-deps
chmod +x venv/bin/activate
source ./venv/bin/activate
echo Building NVGT...
if [[ "$IS_CI" != 1 ]]; then
	# Assumed to not be running on CI; NVGT should be cloned outside of deps first.
	echo Not running on CI.
	git clone --depth 1 https://github.com/samtupy/nvgt||true
	cd nvgt
else
	echo Running on CI.
fi
if ! which scons &> /dev/null; then
	pip3 install scons
fi
scons -s no_upx=0
echo NVGT built.
deactivate
