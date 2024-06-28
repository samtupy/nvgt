# Upgrading From BGT
Since for a while this is where most people who have heard of NVGT will likely start, we will begin by describing the relationship between NVGT and BGT, and more importantly the steps required to upgrade a BGT project to an NVGT one. If you have not heard of BGT or are completely new to game development and are wondering how NVGT can help you, you can probably skip this and move to the fresh start topic.

BGT stands for the Blastbay Gaming Toolkit, and is what initially inspired NVGT to be created after BGT was made into abandonware.

It is important to note that NVGT is not officially endorsed by BGT's developers and contributors, and NVGT is not in any way derived from BGT's source code. The only shared assets between NVGT and BGT are some of BGT's include files such as the audio_form and sound_pool used by many bgt games, which are released under a zlib license.

our goal is to make the transition as seamless as possible from BGT to NVGT, but here are some things you should know when porting an existing BGT game.

* Always `#include "bgt_compat.nvgt"` as this includes a lot of aliases to other functions. Using built-in functions may improve performance so this is more or less a stop-gap to get you up and running quickly; however if you wish for your code to just run, bgt_compat will certainly be of use.
* When referring to an array's length, pass length as a method call and not as a property. ,For example, you would use `array.length();` rather than `a.length;`.
* The `sound::stream()` method does exist in NVGT, but it's simply an alias to `sound::load()`. For this reason it is recommended that you change all your `stream()` calls to `load()` instead. The load function performs an  efficient combination of streaming and preloading by default.
* load() contains a second optional argument to pass a pack file. set_sound_storage() is no longer used for the moment. However, you can set sound_pool.pack_file to a pack handle to get a similar effect.
* Take care to check any method calls using the tts_voice object as a few methods such as set_voice have changed from their BGT counterparts.
* When splitting a string, matching against \r\n is advised as BGT handles this differently. This will result in not having spurious line breaks at the ends of split text.
* The settings object has been crafted as a ghost object. That is, it will not actually load or write any data from the registry. If you use the registry, consider using a data or ini file instead.
* The joystick object is also a ghost object and does not currently function.
* There is a type called `var` in the engine now, so you may need to be careful if your project contains any variables named var.
