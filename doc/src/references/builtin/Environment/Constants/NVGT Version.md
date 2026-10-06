# NVGT Version
These constants describe the version of NVGT that is running your script, or that was used to compile your game. They are set when NVGT itself is built.

- NVGT_VERSION (string): the full version, in the form major.minor.patch-type, for example "0.90.0-dev".
- NVGT_VERSION_MAJOR (int): the major version number.
- NVGT_VERSION_MINOR (int): the minor version number.
- NVGT_VERSION_PATCH (int): the patch version number.
- NVGT_VERSION_TYPE (string): the release type, the part of the version after the dash, such as "dev".
- NVGT_VERSION_COMMIT_HASH (string): the full git commit hash NVGT was built from, or "release" if it was built outside of a git repository.
- NVGT_VERSION_BUILD_TIME (string): a human readable description of when NVGT was built, in the local time of the computer that built it.
- NVGT_VERSION_BUILD_TIMESTAMP (uint): when NVGT was built, as a Unix timestamp.

The individual number constants are useful for checking whether a script is running on a new enough version of NVGT, for example `if (NVGT_VERSION_MAJOR == 0 && NVGT_VERSION_MINOR < 90) alert("Error", "Please update NVGT.");`.

Not to be confused with `SCRIPT_BUILD_TIME`, which gives the time your own script was compiled.
