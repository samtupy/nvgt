---
layout: default.liquid
title: Home
permalink: /
---

# Welcome to the homepage of the Nonvisual Gaming Toolkit!
Create audiogames with ease.

## Development status
On May 31 2024, NVGT officially became open source! However, in reality this just means that we are to a point where we can generate official installers on major platforms, and that the repository no longer contains any sensitive information that we don't want people seeing. Whether it's finishing docs, cleaning up the code, establishing contributor guidelines or other miscellaneous work, we still have much to do before we are ready to begin seriously advertising the engine.

This all means that you can feel free to download, build, and use NVGT as much as you want right now, but please understand that support may be rather limited at this time and/or elements of your experience may not be as ideal as what we eventually intend. In particular you should not assume that the documentation contains a full reference of engine features.

Nevertheless, we hope you enjoy what we have so far as well as watching the continued development of the engine, thanks for stopping by!

## What is NVGT?
Inspired by the Blastbay Gaming Toolkit (bgt) known to much of the audiogaming community and originally created because of that engine's discontinuation, the NVGT engine aims to not only preserve old BGT games and make them better but to also provide a new platform for anybody who wishes to get into game development without learning some of the lower level programming concepts or languages usually required for such a thing, continuing where the concept of the BGT engine left off but with a completely new codebase and a cross platform design.

If you are not familiar with BGT, it was an inspirational audiogame creation engine that allowed a user to, with very little programming knowledge, begin coding games ranging from the very simple to the extremely complex. A scripting engine called Angelscript ensured that a user could create a game without needing to learn a more complex programming language, its functionality from a sound system to keyboard input to internet access ensured that users wouldn't need to spend time hunting for components and libraries but instead could instantly begin developing their game, and its built-in high speed compilation features ensured that a user could release executable binaries of their games without endangering their sourcecode and without needing to learn a compiler toolchain for another language and/or wait for such a toolchain to actually build their project.

There are many such engines like this for video game development, allowing someone who is more interested in the game designing than the lower level programming to get off the ground relatively easily. However up until now, BGT was the closest thing audio game developers had to a simple grab and go gaming engine that contained all components necessary for the development of even quite complex games out of the box.

In 2014, BGT sadly became free/abandonware and stopped receiving updates. Though it took a few years for them to truly manifest, this started to create issues for anyone who had developed games using that engine. Libraries began getting out of date, you couldn't sign games with ssl certificates causing false positives with antivirus software, and the number of wanted features and discovered bugs continued to pile  higher and higher. Finally as 2021 roled over into 2022, I made the decision that BGT was no longer viable to continue developing games in but I didn't want to abandon my projects (some of which had been running for years), and thus NVGT was born.

NVGT was made from the ground up to be able to run old BGT games as a start, as that was the original development goal of the project. With little modification to your codebase, you can quite easily make any BGT title written years ago run natively on a macbook with HRTF 3d audio in a new engine that gets updates!

As more and more work was put into the engine, however, it became clear that using it as a means to simply restore a few old games was quite simply a waste of this engine's potential. There is a quite large group of really very smart people who would frankly rather use their brain and it's learning capacity to develop a good game for multiple platforms rather than learning how cl.exe/visual studio works or how to invoke gcc on wsl/terminal with scons/cmake first let alone learning a low enough level language to want to invoke such commands. I think that the group of people who would rather spend their finite time deciding what skills their npcs should have rather than whether to use bass, sound_lib (oh wait that wraps bass), synthiser, miniaudio, sdl's audio system or something else is larger than some would imagine, and nothing complete has come along since BGT to satisfy this sort of developer who would rather focus on mechanics and use some pre-selected libraries instead of focusing on low level internals and dealing with long drawn out compile times.

Of course, having run into bgt's limitations myself and having been trapped by it's sandbox, another goal with NVGT quickly became making sure that a programmer who does want to include new components written in a lower level language could easily do so without the hassle and limitations of BGT's library object. As such, an expanding plugin system allows the creation of custom components or code that receive direct access to the underlying Angelscript engine used by nvgt scripts, where they can then add any class, namespace, method or property they desire with no intermediate dll calling layer except for the initial plugin loading. If one wishes to rebuild NVGT from source, they can even compile such plugins as static libraries that get linked right into the build with little hassle. Though this is not done yet at the time of writing, there is a hope of providing some of nvgt's functionality as a c library for anyone wishing to avoid its scripting layer entirely.

In the beginning I just created NVGT because I wanted to continue my Survive the Wild project without rewriting it from scratch, but in the end what was created is a customizable game engine that, with a bit more work, may hopefully have the potential of being pleaseing and useful to everyone from those who want to restore an old bgt project to those who want to make a new game without worrying about the internals to maybe even some of those who want to be able to wrest their knowledge of and take a break from low level programming and dependency hunting to just simply create a game, like me.

## Features
The NVGT engine advertises the following qualities and features:
* full UTF-8 support; develop games without internationalization issues.
* Steam Audio support; immerse your players with hrtf audio and realistic reverb generated from the geometry of your game maps.
* sound mixers and effects; Change attributes or even the HRTF position on large groups of sounds at once by adding them to a chain of mixers, and add effects like reverb, distortion, flanging, amp etc to them while you're at it.
* text reencoding; Handle text created in a player's native encoding using the engine's ability to convert text from one encoding to another with the option of enabling over 35 locale specific encodings.
* datastreams; Move, analyze/encrypt, and in other ways manipulate data with a low memory footprint and with few lines of code using connectable streaming classes (inspired by and wrapping c++/poco iostreams).
* multithreading primitives; Make your game run faster using multiple threads, including related mutual exclusion/locking primitives like mutexes and events.
* builtin cheat engine speed hack protection; Stop cheaters by causing cheat engine's speedhack feature to be completely nonfunctional in your games, while also being able to disable such protection should you want to allow your users to speedhack for fun.
* Timers with adjustable accuracy; Create a timer with an elapsed method that returns values in anything from days to microseconds, and use different accuracies per timer object.
* script debugger; Find issues in your code like never before with standard debugging techniques like breakpoints, single instruction stepping, realtime expression evaluation and more.
* ever expanding plugin system; Be free of the Angelscript sandbox and code whatever extensions to your game you want in c++ or another language.
* subscripting; Add downloadable levels to your games or make them more dynamic with NVGT's ability to execute Angelscript code from within Angelscript code like the javascript or python eval function.
* cross platform; Distribute your games to a wide audience by easily compiling it for Windows, Mac OS, Linux and more.
* games on the go; Let your players take your games with them on their Android devices, with IOS planned for the future. Mobile support still young.
* 64-bit; Your old BGT projects can now utilize all system resources.
* 3d pathfinder; Find intelligent paths in 3 dimensions with possibly more in the future.
* builtin JSON support; Connect your projects to online services using one of the most widely recognized API data exchange languages.
* https connections; Use ssl to secure your project's access to the web and successfully connect to websites that enforce it.
* libgit2 plugin; Access and modify git repositories on your game server or otherwise with NVGT's libgit2 wrapper plugin.
* sqlite3 support; Create, connect to and modify SQLite3 databases with NVGT's sqlite3 plugin.
* configurable security functions; make your game even more secure by rebuilding NVGT from source with custom bytecode encryption routines.
* fast SAPI; Allow your users to navigate your game interface faster by trimming silence from speech clips generated by SAPI5 tts.
* builtin fallback speech synthesizer; Allow wine users or players on unusual platforms to maintain accessibility during game setup if an external speech system is temporarily unavailable.
* accessible documentation; You can choose to read NVGT's documentation in markdown, html, plain text or a good old .chm file.
* opensource with a permissive license; Add to or modify the engine in any way you please if it doesn't suit all of your requirements.

# Donate
This engine is a gift given freely to the community and monetary donations are not necessary. However, it is true that it's development takes much time, energy and learning. To that end, NVGT can be considered donationware as monetary support allows me to invest more time into working on this project rather than other endeavours. If you would like to support further development of this engine or have found significant benefits as a result of using it, I'd much appreciate it if you would please consider [supporting me on PayPal](https://paypal.me/stupyprod/) or if that's not an option, sharing this engine with those you think could benefit from it. Thank you very much!
