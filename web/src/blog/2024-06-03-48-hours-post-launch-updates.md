---
title: 48-hours post launch updates
published_date: 2024-06-03 01:38:21.7829158 +0000
layout: post.liquid
is_draft: false
---

Written by Rory and modified by Sam Tupy, updated about 6 hours after publication to include troubleshooting step regarding the new version which was just released.

## Introduction
Hello everybody!

It's now the second day NVGT has been public, and we have several updates to share since the release.

Here are the highlights:
## Pre-Built Binaries Now Available
Although there is still some testing left to do for the latter, Windows and Mac OS installers are now available from the [downloads page](https://nvgt.gg/downloads/).

There is also a linux release, which is currently uploaded as a tarball and cannot yet be installed automatically.

All three releases support cross-compilation; this means you can very easily compile for any of our three supported platforms, all from one machine!

For example:

```
#pragma platform windows
//or
#pragma platform mac
//or
#pragma platform linux
```

Note: Mac OS and linux compilation still needs to be tested and improved.

## built-in url_get and url_post functions
Early users may have experienced issues with bgt_compat.nvgt in the url_get and url_post functions; the new version of NVGT removes these functions and uses new built-in versions.

The new versions also support assigning of the returned http response to an http_response object as a second parameter.

Example:

```
void main(){
    http_response r;
    url_get("https://samtupy.com", r);
    alert("hello", "I run on"+r["server"]);
}
```

## Performance enhancements
Ethin P discovered that Angelscript's string addon had such horribly slow floatingpoint parsing routines that I couldn't possibly come up with a kind word to say about them. On some CPUs, it was taking 5ms to parse a string into a float! That is unspeakibly not OK and has only been a thing for so long because before opensource, we didn't have time/availability to get to all of these details like benchmarking the floatingpoint processor. Ethin recoded that function for us to use a much faster floatingpoint parser, and now floating point numbers can parse sometimes in under 150 microseconds, thanks Ethin!

## The number_speaker.nvgt Include
Thanks to ogomez92, the number_speaker.bgt include shipped with BGT has now been ported over to NVGT!

For those who attempt to use this in their programs, it should now work properly!

If you are not familiar with it, this script allows you to easily play recorded samples of number words, based on integer values.

## The Other Directory
A growing collection miscellaneous items including some code samples (in the other directory):
* in the other directory, there is a new simple_nvgt_console.nvgt script, which serves as a subscripting example and a simple environment for testing and experimentation
* in the other directory as well, a new pack_creater.nvgt script from Masonasons makes it easier than ever to get packs ready to use in your games.
* There are also more references for some classes and functions. Although these are sometimes out of date, they are included because they can help you to understand some components of NVGT which are not yet documented
* a new fx.txt file contains documentation for the fx system in NVGT
* there are also other examples to help explain a few miscellaneous actions, like signing executables

## Known issues
The following is a list of solutions for a few commonly encountered issues that people are experiencing right now. We plan to improve on all things mentioned here, but for now, these troubleshooting steps should help get you up and running if you face any of the most common problems.
### Running on MacOS
Sometimes users are having issues getting the official mac build of NVGT to run. This is mostly because apple is quarantining the app upon download. To fix this, try the following:
* If your mac claims that the app bundle is damaged, try running the following in the terminal: `xattr -c /applications/NVGT.app`
* If you get an error in a problem report about libgit2.2.17.dylib or something being missing, run `brew install libgit2`
* Currently we are having issues detecting the builtin includes directory. It will only be a few lines of code to fix, but we haven't gotten to it yet. To run your nvgt code, the recommendation currently is the following (to be improved) command:
```
/applications/nvgt.app/MacOS/nvgt `pwd`/scriptname.nvgt  -I/applications/nvgt.app/Contents/Resources/include
```
### Windows executable won't run
Remember, NVGT apps may require dependencies. As soon as you initialize the sound system or speak through a screen reader, NVGT tries to call into an external library that you must distribute with your application. Thus, you need to copy c:\nvgt\lib to the directory containing your compiled executable for it to run properly.
### Visual studio link error when building
If you are building NVGT and you get a linker error talking about an undefined symbol thread_sleep_for or similar, the solution is to update visual studio 2022 to the latest version, or if you don't want to do that, you'll need to avoid the use of my windev package and build the dependencies yourself. It's probably just easier to update visual studio.
### I updated to nvgt 0.85.1-beta and now I'm getting loads of compilation errors!
Carefully read the changelog topic for 0.85.1-beta, and observe at some includes no longer require the use of bgt_compat.nvgt. Thus, if you have for example included form.nvgt but not bgt_compat.nvgt and if you use symbols like KEY_LCONTROL which are defined in bgt_compat, your code will now stop running because form.nvgt no longer implicitly includes bgt_compat for you as form no longer requires this include to run. Thus, if you receive loads of compilation errors after the update, be sure to `#include "bgt_compat.nvgt"` in your app to see if that helps.

## What's Next?
While installers and official downloads are indeed available, it should be noted that this engine is still in its beta stage; complete stability in every aspect is neither expected nor guaranteed, although contributors and early users have had great success converting a huge variety of games from bgt already!

More updates will be given as they are available, and thank you for trying NVGT!

