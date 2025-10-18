# Building NVGT for Android
To build NVGT for Android, you will need the Android SDK. The easiest way to get this at least on Windows is if you have Visual Studio to download the Mobile Development workload, or else to install Android Studio.

As with other platforms, most of the work regarding building libraries has been done for you, you can download [droidev.zip](https://nvgt.dev/droidev.zip) here, and extract it similarly to how it is described above for other platforms. Look at jni/example-custom.mk to learn how to set a custom location to this directory.

On some systems, the Android SDK requires a bit of setup to use it extensively enough to build NVGT. If you are using Android Studio directly or if anything else has configured your Android SDK for you it is unlikely you'll need any of this, but in case you need to set up your SDK manually especially on Windows, here are a few notes:
1. The Android SDK on Windows must not be in a directory containing spaces, or at least must not be invoked with one. For example, the Mobile Development workload on Visual Studio by default installs the tools in "C:\Program Files (x86)\Android". So to use it, you may need to symlink the folder with a command run as administrator like `mklink /d C:\android "C:\Program Files (x86)\Android"`.
2. It may also be a good idea to run the Gradle tool (described below) as administrator if you get any weird access denied errors when trying to do it otherwise, you'll see it's trying to write to some file within the Android SDK directory which may require administrative rights to access depending on where it is installed. If you keep getting errors even after doing this, run `gradlew -stop` to kill any old Gradle daemons that were running without privileges.
3. There are a couple of environment variables you may need to set before building. These are the `ANDROID_NDK_HOME`, `ANDROID_HOME`, and `JAVA_HOME` variables which help locate the Android development tools for anything that needs them. An example of setting them at least for Windows is in other/droidev.bat.
4. If at any point you need to run sdkmanager to accept licenses on Windows, run it... yep, as admin. Otherwise you will be informed that the licenses have been successfully accepted, but when you try using the tools, you'll be told to accept them again.
5. It should be noted that both Visual Studio and Android Studio install a functioning Java runtime environment for you, so you don't have to go hunting for one. On Visual Studio, this may be at "C:\Program Files (x86)\Android\openjdk\jdk-17.0.8.101-hotspot", and for Android Studio it may be at "C:\Android\Android Studio\jre". Sadly these paths might change a bit over time (especially the JDK version in the Visual Studio path), so you may need to look up the latest paths if you are having trouble.

Once the Android SDK is set up, cd to the jni directory and run `gradlew assembleRunnerDebug assembleStubRelease`

On platforms other than Windows you may need to run `./gradlew` instead of `gradlew`.

If you want to install the runner application to any devices connected in debug mode, you can run `gradlew installRunnerDebug`.

Do not directly install the stub APK on your device, only do that for the runner application. In regards to the stub, after the Gradle build command succeeds, there is now a file in release/stub/nvgt_android.bin which should be moved into the stub folder of your actual NVGT installation, allowing NVGT to compile .APK files from game source code.

