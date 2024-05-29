# Generates src/version.cpp

Import("env")
import os, subprocess
from datetime import datetime

def generate_version(env, target, source):
	git_hash = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip() if os.path.isdir(".git") and WhereIs("git") else "release"
	datetime_now = datetime.now().astimezone().strftime("%A, %B %d, %Y at %I:%M:%S %p %Z")
	timestamp = int(datetime.now().timestamp())
	version = ""
	with open("version", "r") as f: version = f.read().strip();
	version_major, version_minor, version_patch, version_type = version.replace("-", ".").split(".")
	with open("src/version.cpp", "w") as f:
		f.write("// Auto-generated code containing version information and other constants retrieved from the system at build time.\n\n")
		f.write('#include "version.h"\n');
		f.write(f'const std::string NVGT_VERSION = "{version}";\n')
		f.write(f'const std::string NVGT_VERSION_COMMIT_HASH = "{git_hash}";\n')
		f.write(f'const std::string NVGT_VERSION_BUILD_TIME = "{datetime_now}";\n')
		f.write(f'unsigned int NVGT_VERSION_BUILD_TIMESTAMP = {timestamp};\n')
		f.write(f'int NVGT_VERSION_MAJOR = {version_major};\n')
		f.write(f'int NVGT_VERSION_MINOR={version_minor};\n')
		f.write(f'int NVGT_VERSION_PATCH = {version_patch};\n')
		f.write(f'const std::string NVGT_VERSION_TYPE = "{version_type}";\n')
	with open("build/lastbuild", "w") as f:
		f.write(str(timestamp))

env["generate_version"] = generate_version
