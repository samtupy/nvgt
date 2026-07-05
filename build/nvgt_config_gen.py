# nvgt_config_gen.py - Generates user/nvgt_config.h from build/nvgt_config_template.h.
# Fills template placeholders with cryptographically random values so each CI build uses unique encryption parameters. Exits with an error if user/nvgt_config.h already exists.
# Allowed AI given careful instruction to help with initial implementation, we can remove this comment once humans other than myself have reviewed this code and/or we determine it is stable.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

import os
import re
import secrets
import shutil
import sys

_here = os.path.dirname(os.path.abspath(__file__)) # build/
_root = os.path.dirname(_here) # project root

def escape_c_string(data):
	"""Escapes arbitrary bytes into a C string literal body safe for all byte values."""
	safe = set(range(0x21, 0x7f)) - {ord('"'), ord('\\')}
	return "".join(chr(b) if b in safe else f"\\{b:03o}" for b in data)

def generate_values():
	"""Returns a dict of cryptographically random values for all template placeholders."""
	key_a_len = secrets.randbelow(25) + 24 # 24-48 bytes
	key_b_len = secrets.randbelow(25) + 24
	key_a = bytes(secrets.choice(range(1, 256)) for _ in range(key_a_len)) # no null bytes
	key_b = bytes(secrets.choice(range(1, 256)) for _ in range(key_b_len))
	return {
		"bytecode_xor": secrets.randbelow(90000) + 10000,
		"key_material_a": escape_c_string(key_a),
		"key_a_len": key_a_len,
		"key_material_b": escape_c_string(key_b),
		"key_b_len": key_b_len,
		"size_xor": secrets.randbits(32),
		"iv_rot": secrets.randbelow(7) + 1,
		"iv_offset": secrets.randbelow(15) + 1,
		"iv_xor_base": secrets.randbelow(256),
		"iv_step": secrets.randbelow(15) + 1,
		"xor_a": secrets.randbelow(256),
		"xor_b": secrets.randbelow(128) * 2 + 1, # odd: guarantees full-period cycle mod 256
		"xor_shift": secrets.randbelow(5) + 3,
		"prefix_size": (secrets.randbelow(8) + 1) * 16, # 16-128, multiple of AES block size
		"prefix_size2": secrets.randbelow(49) + 16, # 16-64, inner prefix / per-message XOR key
	}

def apply_template(template, values):
	"""Fills {{name}} placeholders; uses Jinja2 if installed, otherwise a simple regex."""
	try:
		import jinja2
		return jinja2.Environment(undefined=jinja2.StrictUndefined).from_string(template).render(values)
	except ImportError:
		return re.sub(r'\{\{(\w+)\}\}', lambda m: str(values[m.group(1)]), template)

def main():
	"""Generate user/nvgt_config.h."""
	out_dir = os.path.join(_root, "user")
	out_path = os.path.join(out_dir, "nvgt_config.h")
	if os.path.exists(out_path):
		print(f"error: {out_path} already exists; delete it to regenerate.", file=sys.stderr)
		sys.exit(1)
	template_path = os.path.join(_here, "nvgt_config_template.h")
	if not os.path.exists(template_path):
		print(f"error: {template_path} not found.", file=sys.stderr)
		sys.exit(1)
	os.makedirs(out_dir, exist_ok=True)
	with open(template_path, "r", encoding="utf-8") as f:
		template = f.read()
	result = apply_template(template, generate_values())
	with open(out_path, "w", encoding="utf-8") as f:
		f.write(result)
	print(f"generated {out_path}")

if __name__ == "__main__":
	main()
