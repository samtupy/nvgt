# building nvgt on windows
## building with the build_windows.ps1 script
there is a {script for building nvgt for windows}(https://github.com/samtupy/nvgt/blob/main/build/build_windows.sh)
this script can take multiple parameters for controlling the behaviour of the script
* -it: this parameter instructs the script to download the relevant tooling that will be used, this includes a compiler, python, and git
*ci: this parameter tells the script that you have already cloned the repo and it will proseed to download dependencies and build nvgt
### notes
powershell might refuse to execute the script do to execution policys, in that case run the command:
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
this will apply this change for the current session of powershell only
for a more permanent solution run one of the following:
* Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser: this will set this property for the current user only
* Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine: this will do it for the intire system
setting this setting permanently requires running powershell as admin
## building nvgt manualy
if you do not want to use the script for building nvgt you can do it manualy,
### required software
* a c++ compiler: the one coming with microsoft visual studio22 comunity eddition is recommended
* git: for cloning the repository
* python: for installing and using scons
### instructions
* 1. open a command prompt and navigate to a directory where you want to download nvgt
* 2. run the following command: git clone https://github.com/samtupy/nvgt
* 3. type cd nvgt
* 4. open a webb browser and (download windev.zip){https://nvgt.gg/windev.zip}
*5. extract windev.zip to the github repo you cloned earlyer/windev. so if i cloned the repo to c:\cloned_repos\nvgt the windev.zip should be extracted to c:\cloned_repos\nvgt\windev
6. go back to your command prompt and run the following commands:
python -m pip install scons
scons -s
#### notes
the scons -s command and pip and or python commands might not work correctly. in that case, google on how to add python packages to environment variable or something along those lines