# This just sets the nvgt_version github variable for use within CI actions to the format used for binary releases. Any of this structure subject to change.

import os
from pathlib import Path

def get_version_info():
	return Path("version").read_text().strip().replace("-", "_")

with open(os.getenv("GITHUB_ENV"), "a") as f: f.write(f"nvgt_version={get_version_info()}\n")
