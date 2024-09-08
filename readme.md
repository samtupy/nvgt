# the NonVisual Gaming Toolkit (NVGT)
[website](https://nvgt.gg)

## What is NVGT?
NVGT is a cross platform audio game development engine reminiscent of and mostly compatible with scripts written in the sadly now abandoned Blastbay Gaming Toolkit. It basically wraps the functionality of many mostly open source libraries into an [Angelscript engine](https://www.angelcode.com/angelscript/) and then allows the game developer to compile their .nvgt angelscripts into a product that can be distributed online or even sold.

It aims to remove some of the headaches that anyone interested in audio game development may be likely to face when trying to get an audio game design project off the ground. Particularly in the field of audio game development, there are not very many easy and well known paths to get started like there are for a sighted person interested in video game design who can download a massive gaming engine like unity or unreal and have more than they need to get started at their fingertips. Mind you NVGT is not even remotely trying to compare with large video gaming engines written by giant AAA studios, but instead it tries to free particularly someone new to programming or someone who isn't interested in such details from having to search for sound system/input/windowing/etc libraries and frameworks, learning how to get apps running on multiple operating systems and generally from doing much of the other lower level heavy lifting that may otherwise prevent someone from developing a great game.

Find out more at nvgt.gg.

## building
You will need a c++ build toolchain if you want to build NVGT from source. On windows we recommend the visual studio build command line tools or the very latest version of visual studio 2022. On macos you will need at least the command line development tools if not xcode, and a functioning GNU/g++ compiler collection is expected to be available on Linux.

NVGT uses SCons, a python build system. If you have python, you can get it by running `pip install scons`.

Other than scons, the following libraries are needed to build NVGT:
* Angelscript scripting library
* bullet3 physics library, though at the time of writing only some headers (the Bullet3Common and LinearMath folders) are needed
* enet networking library
* Poco C++ portable components
* SDL3

You also need to locate headers and binaries for the bass audio library (bass, bassmix and bass_fx) and for phonon (steam audio) though some are provided if you want to use those.

If you want to build all plugins, you will also need the curl and libgit2 libraries.

For Linux and MacOS, scripts with build commands are in build/build_Linux.sh and build/build_macos.sh.

For now only on windows, the option exists to make the process of dealing with dependencies much simpler than hunting them down manually and setting up include/library paths. For those who want them, I've decided to provide my own build artifacts. This is a bin/include/lib directory structure that contains organized header files, link libraries (static when possible), and dlls for distribution like bass and phonon which makes building nvgt as simple as pointing to this directory structure and running the build command. This download contains more than the libraries specifically required to build NVGT as A, it includes the libraries required to build plugins and B, it may include libraries that I use in other projects. If it gets giant, I'll provide a download just containing nvgt libraries. For now, you can 
[download windev.zip here](https://nvgt.gg/windev.zip) and place an extracted version of it in the root of the nvgt repository, that is a folder called windev containing bin, include, lib, misc should exist in the root of the nvgt repo.

Though unlike the windev.zip file these only contain binaries for the bass and steam audio versions we are using at present, you can also [download macosdev.tar.gz](https://nvgt.gg/macosdev.tar.gz) for MacOS or [download lindev.tar.gz](https://nvgt.gg/lindev.tar.gz) for Linux to ease at least some of the dependency hunt.

Once dependencies are in place, you can now open a command prompt or terminal window up to the root of the nvgt repository and run `scons -s` to build nvgt.

If you don't want to build plugins, you can run, for example, `scons -s no_curl_plugin=1 no_git_plugin=1` to disable the curl and git plugins.

You can disable the creation of shared plugin dlls with the option no_shared_plugins=1.

If you do not want to build the stubs, such as for active development where generating them would be time consuming, you can pass no_stubs=1 to the scons command.

If you want to see what other custom switches are available in NVGT's SConstruct file, you can run scons -s -h or even just scons -h if you want a bit of extra useless verbosity.

You can omit the -s from the build command if you want to get spammed with the outputting of every internal build command used, which is hundreds of them.

### Android
To build NVGT for android, you will need the android SDK. The easiest way to get this at least on windows is if you have visual studio to download the mobile development workload, or else to install android studio.

As with other platforms, most of the work regarding building libraries has been done for you, you can download [droidev.zip](https://nvgt.gg/droidev.zip) here, and extract it similarly to how it is described above for other platforms. Look at jni/example-custom.mk to learn how to set a custom location to this directory.

On some systems, the Android SDK requires a bit of setup to use it extensively enough to build NVGT. If you are using Android Studio directly or if anything else has configured your Android SDK for you it is unlikely you'll need any of this, but encase you need to set up your SDK manually especially on windows, here are a few notes:
1. The android SDK on windows must not be in a directory containing spaces, or at least must not be invoked with one. For example, the mobile development workload on visual studio by default installs the tools in "C:\Program Files (x86)\Android". So to use it, you may need to symlink the folder with a command run as administrator like \`mklink /d C:\android "C:\Program Files (x86)\Android"\`.
2. It may also be a good idea to run the gradle tool (described below) as administrator if you get any weird access denied errors when trying to do it otherwise, you'll see it's trying to write to some file within the android SDK directory which may require administrative rights to access depending on where it is installed. If you keep getting errors even after doing this, run gradlew -stop to kill any old gradle daemons that were running without privileges.
3. There are a couple of environment variables you may need to set before building. These are the ANDROID_NDK_HOME, ANDROID_HOME, and JAVA_HOME variables which help locate the Android development tools for anything that needs them. An example of setting them at least for windows is in other/droidev.bat.
4. If at any point you need to run sdkmanager to accept licenses on windows, run it... yep, as admin. Otherwise you will be informed that the licenses have been successfully accepted, but when you try using the tools, you'll be told to accept them again.
5. It should be noted that both Visual Studio and Android Studio install a functioning Java runtime environment for you, so you don't have to go hunting for one. On visual studio, this may be at C:\Program Files (x86)\Android\openjdk\jdk-17.0.8.101-hotspot, and for Android Studio it may be at C:\Android\Android Studio\jre. Sadly these paths might change a bit over time (especially the JDK version in the visual studio path), so you may need to look up the latest paths if you are having trouble.

To build NVGT for Android, cd to the jni directory and run `gradlew assembleRunnerDebug assembleStubRelease`

On platforms other than windows you may need to run ./gradlew instead of gradlew.

If you want to install the runner application to any devices connected in debug mode, you can run gradlew installRunnerDebug.

Do not directly install the stub APK on your device, only do that for the runner application. In regards to the stub, after the gradle build command succeeds, there is now a file in release/stub/nvgt_android.bin which should be moved into the stub folder of your actual NVGT installation, allowing NVGT to compile .APK files from game source code.

## contributing
Contributions to NVGT are extremely welcome and are what help the project grow. If you want to contribute, please keep the following things in mind:

### issues
If you've discovered a bug, please open a github issue so we can try to fix it. However, please keep the following in mind when you do so:
1. Please check the [blog](https://nvgt.gg/blog/), the todo list and the existing list of issues and pull requests encase a record of the problem already exists, avoiding duplicate reports is appreciated.
2. Please avoid 1 or 2 sentence issues such as "The speak function isn't working" or "Compiled script won't run on my mac." At the moment there is not much strictness in how issues must be written, however it is asked that you please put some effort into your issue descriptions E. if code doesn't work how you expect, please provide preferably a sample or at least steps to reproduce, or if something won't run, please provide preferably debug output like a stack trace or at least platform details and/or an exact error message.
3. Please keep your issue comments strictly on topic, and try editing them rather than double posting if you come up with an amendment to your comment shortly after posting it. Avoid repeated queries.
4. If you have a question rather than a bug to report, please open a discussion rather than an issue.

### pull requests
Pull requests are also very welcome and are generally the quickest path to getting a fix into NVGT. If you wish to submit one, please keep the following things in mind:
1. Respect the coding style: While little mistakes are OK (we can fix them with an auto formatter), please do not completely disregard it. Unindented code or code without padded operators etc is not appreciated.
2. Find an existing way to perform a standard operation before implementing your own version: For example if you need to encode a string into UTF8, realize that other code in NVGT likely needs to do this as well, and figure out how NVGT already does it rather than writing your own UTF8 encoding function. This keeps the code cleaner and more consistent, someone won't come along in the future and wonder what method they should use to encode a string into UTF8.
3. Though it is not absolutely required, it is usually a good idea to open a discussion or issue before a pull request that introduces any kind of very significant change is created. This should absolutely be done before any sort of dependency addition or change. Pull requests that do not adhere to this may be delayed or denied.
4. Please check the blog and the todo list before opening a pull request, encase we have noted a certain way we wish to do something that your pull request might go against.
5. If you modify the c++ code, please try making sure it builds on as many platforms that we support as you have access to. For example you can build NVGT on Linux using wsl on windows. You only need to worry about this within reason, but any work you can do here is seriously appreciated.
6. If you contribute to the documentation, please try to run the docgen.py script and make sure your changes basically compile, and then open the html version of the compiled documentation and make sure it looks OK before committing. Please follow the existing documentation source structure to the best of your ability when writing topics.
7. Understand that any contributions to the project are to be put under the same license that NVGT is released under, which is zlib. It is OK to add a credit to yourself for large portions of source code you contribute, but the general copyright notice is to remain the same.

Please note that these guidelines may be updated at any time. Thanks for your interest in contributing!