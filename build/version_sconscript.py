# Generates src/version.cpp

is_scons = True
try: Import("env")
except: is_scons = False
import os, subprocess
from datetime import datetime

def generate_version(env = None, target = None, source = None):
	basedir = os.path.dirname(os.path.dirname(__file__)) if not is_scons else ""
	git_hash = "release"
	try: git_hash = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip() if os.path.isdir(os.path.join(basedir, ".git")) else "release"
	except: pass # git must not be on path
	datetime_now = datetime.now().astimezone().strftime("%A, %B %d, %Y at %I:%M:%S %p %Z")
	timestamp = int(datetime.now().timestamp())
	version = ""
	with open(os.path.join(basedir, "version"), "r") as f: version = f.read().strip();
	version_major, version_minor, version_patch, version_type = version.replace("-", ".").split(".")
	with open(os.path.join(basedir, "src", "version.cpp"), "w") as f:
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
	with open(os.path.join(basedir, "build", "lastbuild"), "w") as f:
		f.write(str(timestamp))

if is_scons: env["generate_version"] = generate_version
else: generate_version()
