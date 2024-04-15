# on windows, the easiest way to build nvgt is using the provided package of build artifacts used when constructing the public nvgt releases, consisting of many static libraries, headers, and even some redistributable dlls. We will try to find that here and add include/libpaths, or else you can add paths to your own libraries manually if desired. This is included from any sconstruct scripts that need these paths set.
import os

def set_windev_paths(env, windev_path = "windev"):
	found = False
	if not os.path.isdir("../" + windev_path):
		try: windev_path = open("windev_path").read()
		except: return
	else:
		windev_path = "#" + windev_path
		found = True
	if not found and not os.path.isdir(windev_path): return
	else: found = True
	env.Append(CPPPATH = [os.path.join(windev_path, "include")])
	env.Append(LIBPATH = [os.path.join(windev_path, "lib")])

Import("env")
set_windev_paths(env)
