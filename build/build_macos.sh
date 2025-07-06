#!/bin/zsh
if [[ "$1" == "ci" ]]; then
	export IS_CI=1
else
	export IS_CI=0
fi
set -e
brew install autoconf automake libtool upx
python3 -m venv venv --upgrade-deps
chmod +x venv/bin/activate
source ./venv/bin/activate
pip3 install scons
echo Building NVGT...
if [[ "$IS_CI" != 1 ]]; then
	# Assumed to not be running on CI; NVGT should be cloned outside of deps first.
	echo Not running on CI.
	git clone --depth 1 https://github.com/samtupy/nvgt||true
	cd nvgt
else
	echo Running on CI.
fi
echo Downloading macosdev...
curl -s -O https://nvgt.gg/macosdev.zip
mkdir -p macosdev
cd macosdev
unzip -q ../macosdev.zip
cd ..
rm macosdev.zip
scons -s
echo NVGT built.
deactivate
