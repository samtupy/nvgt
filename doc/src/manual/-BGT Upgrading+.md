# Upgrading From BGT
Since for a while this is where most people who have heard of NVGT will likely start, we will begin by describing the relationship between NVGT and BGT, and more importantly the steps required to upgrade a BGT project to an NVGT one. If you have not heard of BGT or are completely new to game development and are wondering how NVGT can help you, you can probably skip this and move to the fresh start topic.

BGT stands for the Blastbay Gaming Toolkit, and is what initially inspired NVGT to be created after BGT was made into abandonware.

It is important to note that NVGT is not officially endorsed by BGT's developers and contributors, and NVGT is not in any way derived from BGT's source code. The only shared assets between NVGT and BGT are some of BGT's include files such as the audio_form and sound_pool used by many bgt games, which are released under a zlib license.

our goal is to make the transition as seamless as possible from BGT to NVGT, but here are some things you should know when porting an existing BGT game.

* Always `#include "bgt_compat.nvgt"` as this includes a lot of aliases to other functions. Using built-in functions may improve performance so this is more or less a stop-gap to get you up and running quickly; however if you wish for your code to just run, bgt_compat will certainly be of use.
* Although a wrapper function is included in the `bgt_compat` header, it's important to note that the `set_sound_storage()` function has been replaced with the `sound_default_pack` global property.
* When refering to an array's length, pass length as a method call and not as a property. For example, you would use `array.length();` rather than `array.length;`.
* The `sound::stream()` method does exist in NVGT, but it's simply an alias to `sound::load()`. For this reason it is recommended that you change all your `stream()` calls to `load()` instead. The load function performs an  efficient combination of streaming and preloading by default.
* Take care to check any method calls using the tts_voice object as a few methods such as set_voice have changed from their BGT counterparts.
* When splitting a string, matching against \r\n is advised as BGT handles this differently. This will result in not having spurious line breaks at the ends of split text.
* The settings object no longer writes to the registry, but instead has been replaced by the settings.nvgt include which wraps the previous settings object API, but instead writes to configuration files in various formats.
* The joystick object is a ghost object and does not currently function.
* The dynamic_menu.bgt include is now called bgt_dynamic_menu.nvgt. This is because NVGT now includes it's own menu class called menu.nvgt.
* There is a type called `var` in the engine now, so you may need to be careful if your project contains any variables named var.
* It's worth noting that unlike BGT, NVGT by default attempts to fully package your game for you including sounds, libraries, documents and any other assets into a .zip file or similar on other platforms intended for distrobution. If you don't like this behavior, you can create a file next to nvgt.exe called config.properties and add the line build.windows_bundle = 0 which will cause NVGT to just produce a standalone executable like BGT did, though you now may need to copy some libraries from the lib folder for the compiled product to run.
* In bgt, you could include pack files with the `#include` directive. In nvgt, we've decided that this should only include code. To embed packs, you can instead add the line `#pragma embed packname.dat` to your project, the extension can be any of your choosing for both code and packs this way.
