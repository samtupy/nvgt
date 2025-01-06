@echo off
rem This script sets up an android development environment based on the default installation paths of the visual studio mobile development workload. It is more provided to illustrate what variables to set so someone can spend less time researching on the internet and otherwise as a convenience, you may need to update it a little bit as version numbers change over time.
rem we assume that the command `mklink /d C:\android "C:\Program Files (x86)\Android"` has been run as administrator.
set ANDROID_NDK_HOME=C:\android\AndroidNDK\android-ndk-r23c
set ANDROID_SDK_HOME=C:\android\android-sdk
set ANDROID_HOME=C:\android\android-sdk
set JAVA_HOME=C:\android\openjdk\jdk-17.0.8.101-hotspot
set PATH=%ANDROID_NDK_HOME%;%ANDROID_NDK_HOME%\toolchains\llvm\prebuilt\windows-x86_64\bin;%ANDROID_HOME%\build-tools\34.0.0;%ANDROID_HOME%\cmdline-tools\11.0\bin;%ANDROID_HOME%\platform-tools;%JAVA_HOME%\bin;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%
