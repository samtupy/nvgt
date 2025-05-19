# building nvgt on windows

## Building with the `build_windows.ps1` script
There is a [script for building NVGT for Windows](https://github.com/samtupy/nvgt/blob/main/build/build_windows.ps1). It requires [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) to be installed.

This script allows for multiple parameters to alter it's behaviour:
* `-it`: This parameter instructs the script to download the relevant tooling that will be used; this includes a compiler, Python, and Git.
* `-ci`: This parameter tells the script that you have already cloned NVGT's repo and will download dependencies assuming it is in NVGT's top-level directory.

### Notes
PowerShell might refuse to execute the script do to execution policys. In this case, run the command:
`Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process`
This will apply this change for the current session of PowerShell only

For a more permanent solution, run one of the following:
* `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`: This will set this property for the current user only.
* `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine`: This will set the policy for the intire system.

Note: Setting this setting permanently requires running PowerShell as administrator.

## Building NVGT manually
if you do not wish to use this script for building nvgt, you can build NVGT manually. See the [main project readme](https://github.com/samtupy/nvgt/blob/main/readme.md) for more details.
