# Plugin Creation
Does NVGT not provide the function you need, and do you know a bit of c++? If so, perhaps NVGT plugins are exactly what you're looking for!

This document will describe all there is to know about creating nvgt plugins, both dynamically and statically.

## What is a plugin in the context of NVGT?
An NVGT plugin, in it's most basic form, is simply a module of code that is executed during the script loading part of the engine initialization process, one which can extend the functionality of NVGT by directly gaining access to and registering functions with it's internal Angelscript engine.

Plugins are not just limited to functions, but classes, enums, funcdefs and anything else one could register normally using the Angelscript scripting library.

## Types of plugin builds
A plugin can either be a shared library (.dll / .dylib / .so) that gets loaded when needed, or a static library (.lib / .a) that is linked directly into a custom build of NVGT. Both methods have different advantages and disadvantages.

Dynamically loaded plugins, those built into a shared library, are easier to get working with NVGT because it's far easier to create such a plugin without at all altering NVGT's build process or adding things to it. You could use your own build system and your own environment, so long as the proper ABI is exposed to NVGT in the end and an up-to-date version of Angelscript is used within your plugin. However, a smart player may figure out how to replace your plugin dll with some sort of malicious copy, your dll plugin could be duplicated and reused in other projects, you'll have an extra dll file to release with your game distribution etc.

Static plugins on the other hand, while a bit tougher to build, are certainly more rewarding in the end. From plugin code being packaged directly into your binary to a smaller distribution size because of no duplicated crt/other code in a dll to direct integration with NVGT's build system, there are several advantages that can be observed when choosing to create a static plugin.

If one chooses to follow every step of the existing NVGT plugin creation process that is used internally by engine developers, you can set up your plugin such that it can easily be built either dynamically or statically depending on the end-user's preference.

## The basic idea
In short, the idea here stems from a pretty simple base. The user creates a .cpp file that includes the nvgt_plugin.h header that can do any magic heavy lifting needed, then the user just defines an entry point using a macro declared in nvgt_plugin.h. This entry point receives a pointer to the asIScriptEngine instance used by NVGT, which the plugin developer can do anything they please with from registering custom functions to installing some sort of custom profiler. The entry point can return true or false to indicate to NVGT whether the plugin was able to successfully initialize.

This plugin entry point always takes one argument, which is a structure of data passed to it by NVGT. The structure contains the Angelscript engine pointer as well as pointers to several other Angelscript functions that may be useful, and may be expanded with pointers to other useful interfaces from NVGT as well. One just simply needs to call a function provided by nvgt_plugin.h called prepare_plugin passing to it a pointer to the aforementioned structure before their own plugin initialization code begins to execute.

To link a static plugin with the engine assuming the nvgt's build script knows about the static library file, one need only add a line such as static_plugin(\<plugname\>) to the nvgt_config.h file where \<plugname\> should be replaced with the name of your plugin.

## small example plugin
```
#include <windows.h>
#include "../../src/nvgt_plugin.h"

void do_test() {
	MessageBoxA(0, "It works, this function is being called from within the context of an NVGT plugin!", "success", 0);
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
	shared->script_engine->RegisterGlobalFunction("void do_test()", asFUNCTION(do_test), asCALL_CDECL);
	return true;
}
```

### picking it apart
We shall forgo any general comments or teaching about the c++ language itself here, but instead will just focus on the bits of code that specifically involve the plugin interface.

The first thing that you probably noticed was this include directive which includes "../../src/nvgt_plugin.h". Why there? While this will be described later, the gist is that NVGT's build setup already has some infrastructure set up to build plugins. NVGT's github repository has a plugin folder, and in there are folders for each plugin. This example is using such a structure. We will talk more in detail about this later, but for now it is enough to know that nvgt_plugin.h does not include anything else in nvgt's source tree, and can be safely copy pasted where ever you feel is best for your particular project (though we do recommend building plugins with NVGT's workspace).

The next oddity here, why doesn't the plugin_main function declaration include a return type? This is because it is a macro defined in nvgt_plugin.h. It is required because the name of the entry point will internally change based on whether you are compiling your plugin statically or dynamically. If you are building your plugin as a shared library, the function that ends up exporting is called nvgt_plugin. However since one of course cannot link 2 static libraries with the same symbol names in each to a final executable, the entry point for a static plugin ends up being called nvgt_plugin_\<plugname\> where \<plugname\> is replaced with the value of the NVGT_PLUGIN_STATIC preprocessor define (set at plugin build time). In the future even dynamic libraries may possibly contain the plugin name in their entry point function signatures such that more than one plugin could be loaded from one dll file, but for now we instead recommend simply registering functions from multiple plugins in one common entry point if you really want to do that.

Finally, remember to call prepare_plugin(shared) as the first thing in your plugin, and note that if your entry point does not return true, this indicates an error condition and your plugin is not loaded.

## NVGT's plugin building infrastructure
As mentioned a couple of times above, NVGT's official repository already contains the infrastructure required to build plugins and integrate them with NVGT's existing build system, complete with the ability to exclude some of your more private plugins from being picked up by the repository. While it is not required that one use this setup and in fact one may not want to if they have a better workspace set up for themselves, we certainly recommend it especially if you are making a plugin that you may want to share with the NVGT community.

### The plugin directory
In nvgt's main repository, the plugin directory contains all publicly available plugins. Either if you have downloaded NVGT's repository outside of version control (such as a public release artifact) or if you intend to contribute your plugin to the community by submitting a pull request, you can feel free to use this directory as well.

Here, each directory is typically one plugin. It is not required that this be the case, other directories that are not plugins can also exist here, however any directory within the plugin folder that contains a file called _SConscript will automatically be considered as a plugin by the SConstruct script that builds NVGT.

The source code in these plugins can be arranged any way you like, as it is the _SConscript file you provide that instructs the system how to build your plugin.

An example _SConscript file for such a plugin might look like this:
```
# Import the SCons environment we are using
Import("env")

# Create the shared version of our plugin if the user has not disabled this feature.
if ARGUMENTS.get("no_shared_plugins", "0") == "0":
	env.SharedLibrary("#release/lib/test_plugin", ["test.cpp"], libs = ["user32"])

# If we want to make a static version along side our shared one, we need to specifically rebuild the object file containing the plugin's entry point with a different name so that SCons can maintain a proper dependency graph. Note the NVGT_PLUGIN_STATIC define.
static = env.Object("test_plugin_static", "test.cpp", CPPDEFINES = [("NVGT_PLUGIN_STATIC", "test_plugin")])
# now actually build the static library, reusing the same variable from above for fewer declarations.
static = env.StaticLibrary("#build/lib/test_plugin", [static])

# Tell NVGT's SConstruct script that the static version of this plugin needs symbols from the user32 library.
static = [static, "user32"]

# What is being returned to NVGT's SConstruct in the end is a list of additional static library objects that should be linked.
Return("static")
```

Note that while the above example returns the user32 library back to NVGT's build script, it should be noted that most system libraries are already linked into nvgt's builds. The example exists to show how an extra static library would be passed to NVGT from a plugin if required, but this should only be done either as a reaction to a linker error or if you know for sure that your plugin requires a dependency that is not automatically linked to NVGT, examples in the git2, curl or sqlite3 plugins.

### the user directory
NVGT's github repository also contains another root folder called user. This is a private scratchpad directory that exists so that a user can add plugins or any other code to NVGT that they do not want included in the repository.

First, the repository's .gitignore file ignores everything in here accept for readme.md, meaning that you can do anything you like here with the peace of mind that you won't accidentally commit your private encryption plugin to the public repository when you try contributing a bugfix to the engine.

Second, if a _SConscript file is present in this directory, NVGT's main build script will execute it, providing 2 environments to it via SCons exports. The nvgt_env environment is what is used to directly build NVGT, for example if you need any extra static libraries linked to nvgt.exe or the stubs, you'd add one by importing the nvgt_env variable and appending the library you want to link with to the environment's LIBS construction variable.

Last but not least, if a file called nvgt_config.h is present in the user folder, this will also be loaded in place of the nvgt_config.h in the repo's src directory.

You can do whatever you want within this user directory, choosing to either follow or ignore any conventions you wish. Below is an example of a working setup that employs the user directory, but keep in mind that you can set up your user directory any way you wish and don't necessarily have to follow the example exactly.

#### user directory example
The following setup is used for Survive the Wild development. That game requires a couple of proprietary plugins to work, such as a private encryption layer.

In this case, what was set up was a second github repository that exists within the user directory. It's not a good idea to make a github repository out of the root user folder itself because git will not appreciate this, but instead a folder should be created within the user directory that could contain a subrepository. We'll call it nvgt_user.

The first step is to create some jumper scripts that allow the user folder to know about the nvgt_user repository contained inside it.

user/nvgt_config.h:
```
#include "nvgt_user/nvgt_config.h"
```
and

user/_SConscript:
```
Import(["plugin_env", "nvgt_env"])
SConscript("nvgt_user/_SConscript", exports=["plugin_env", "nvgt_env"])
```

Now, user/nvgt_user/nvgt_config.h and user/nvgt_user/_SConscript will be loaded as they should be, respectively.

In the nvgt_user folder itself we have _SConscript, nvgt_plugin.h, and some folders containing private plugins as well as an unimportant folder called setup we'll describe near the end of the example.

nvgt_config.h contains the custom encryption routines / static plugin configuration that is used to build the version of NVGT used for Survive the Wild.

The user/nvgt_user/_SConscript file looks something like this:
```
Import("plugin_env", "nvgt_env")

SConscript("plugname1/_SConscript", variant_dir = "#build/obj_plugin/plugname1", duplicate = 0, exports = ["plugin_env", "nvgt_env"])
SConscript("plugname2/_SConscript", variant_dir = "#build/obj_plugin/plugname2", duplicate = 0, exports = ["plugin_env", "nvgt_env"])
# nvgt_user/nvgt_config.h statically links with the git2 plugin, lets delay load that dll on windows so that users won't get errors if it's not found.
if nvgt_env["PLATFORM"] == "win32":
	nvgt_env.Append(LINKFLAGS = ["/delayload:git2.dll"])
```
And finally an _SConscript file for nvgt_user/plugname\* might look something like this:
```
Import(["plugin_env", "nvgt_env"])

static = plugin_env.StaticLibrary("#build/lib/plugname2", ["code.cpp"], CPPDEFINES = [("NVGT_PLUGIN_STATIC", "plugname2")], LIBS = ["somelib"])
nvgt_env.Append(LIBS = [static, "somelib"])
```
As you can see, the decision regarding the custom plugins used for Survive the Wild is to simply not support building them as shared libraries, as that will never be needed from the context of that game.

The only other item in the private nvgt_user repository used for Survive the Wild is a folder called setup, and it's nothing but a tiny all be it useful convenience mechanism. The setup folder simply contains copies of the user/_SConscript and user/nvgt_config.h files that were described at the beginning of this example, meaning that if nvgt's repository ever needs to be cloned from scratch to continue STW development (such as on a new workstation), the following commands can be executed without worrying about creating the extra files that are outside of the nvgt_user repository in the root of the user folder:

```bash
git clone https://github.com/samtupy/nvgt
cd nvgt/user
git clone https://github.com/samtupy/nvgt_user
cp nvgt_user/setup/* .
```

And with that, nvgt is ready for the private development of STW all with the custom plugins still being safely in version control! So long as the cwd is outside of the nvgt_user directory the root nvgt repository is effected, and once inside the nvgt_user directory, that much smaller repository is the only thing that will be touched by git commands.

Remember, you should use this example as a possible idea as to how you could potentially make use of NVGT's user directory, not as a guide you must follow exactly. Feel free to create your own entirely different workspace in here or if you want, forgo use of the user directory entirely.

## cross platform considerations
If you are only building plugins for projects that are intended to run on one platform, this section may be safely skipped. However if your game runs on multiple platforms and if you intend to introduce custom plugins, you probably don't want to miss this.

There are a couple of things that should be considered when creating plugins intended to run on all platforms, but only one really big one. In short, it is important that a cross platform plugin's registered Angelscript interface looks exactly the same on all platforms, even if your plugin doesn't support some functionality on one platform. For example if your plugin has functions foo and bar but the bar function only works on windows, it is important to register an empty bar function for any non-windows builds of your plugin rather than excluding the bar function from the angelscript registration of such a plugin build entirely. This is especially true if you intend to, for example, cross compile your application with the windows version of NVGT to run on a linux platform.

The reasoning is that Angelscript may sometimes store indexes or offsets to internal functions or engine registrations in compiled bytecode rather than the names of them. This makes sense and allows for much smaller/faster compiled programs, but what it does mean is that NVGT's registered interface must appear exactly the same both when compiling and when running a script. Maybe your plugin with foo and bar functions get registered into the engine as functions 500 and 501, then maybe the user loads a plugin after that with boo and bas functions that get registered as functions 502 and 503. Say the user makes a call to the bas function at index 503. Well, if the foo bar plugin doesn't include a bar function on linux builds of it, now we can compile the script on windows and observe that the function call to bas at index 503 is successful. But if I run that compiled code on linux, since the bar function is not registered (as it only works on windows), the bas function is now at index 502 instead of 503 where the bytecode is instructing the program to call a function. Oh no, program panic, invalid bytecode! The solution is to instead register an empty version of the bar function on non-windows builds of such a plugin that does nothing.

## Angelscript registration
Hopefully this document has helped you gather the knowledge required to start making some great plugins! The last pressing question we'll end with is "how does one register things with NVGT's Angelscript engine?" The angelscript engine is a variable in the nvgt_plugin_shared structure passed to your plugins entry point, it's called script_engine.

The best reference for how to register things with Angelscript is the Angelscript documentation itself, and as such, the following are just a couple of useful links from there which should help get you on the right track:
* [registering the application interface](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_api_topic.html)
* [registering a function](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_func.html)
* [registering global properties](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_prop.html)
* [registering an object type](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_type.html)

Good luck creating NVGT plugins, and feel free to share some of them to the community if you deem them worthy!
