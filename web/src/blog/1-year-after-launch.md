---
title: 1 year after launch, Update for June 2025
published_date: 2025-06-02 20:30:00 -0500
layout: post.liquid
is_draft: false
---

Written by Sam Tupy

## So where in the world have we been?
If you have found NVGT through it's website, you have seen:
* that no engine updates have been released since last October 9th.
* That the homepage has been static for many months.
* that there has not been a blog post in almost a year!

And you might wonder,

Has this project been abandoned?

First, I'd like to apologize for the neglect of NVGT's front facing website. The truth is that contrary to the project being abandoned, we have actually been doing so much work on the project that unfortunately the nvgt.gg webpages have somewhat fallen by the wayside! This was never intended, and I'm hopeful that especially as we finish heavy development of a few time consuming features, we'll get this website and the information on it backup to par. At the current time, NVGT's [Github repository](https://github.com/samtupy/nvgt) is the best place to get instant updates on the project through the commit history.

## What are we working on then?
One of our biggest distractions right now in NVGT is implementing the miniaudio sound engine. Since NVGT's beginning, we were using a sound system called bass. Bass is a cool library, and it's developer is even cooler. However, bass's licensing model and closed source nature were not ideal for NVGT. Not only would we be forcing people to pay for bass licenses if they wanted to create shareware products, but we suffered from a distinct lack of debugging ability because Bass's source code is not available. If we ever wanted to release NVGT for a platform that Bass didn't support? Tough luck. As such, we have been working hard at converting the entirety of NVGT to the public domain open source miniaudio library instead. We've made much progress here, and have almost all features of the previous sound system implemented including some extra goodies like encrypted pack files. We have not converted the sound pool to the new system as of yet, and we are still working on implementing effects such as reverb. This has been a huge undertaking that would not be possible this quickly without much help from contributors, particularly Caturria who provided a complete pack file rewrite and a sound service implementation that links the new pack as well as other decoders up to miniaudio.

Aside from miniaudio, there are several other things being worked on both by project maintainers as well as awesome contributors that have stepped up to provide many helpful pieces of code and documentation, from unexpected help with our on going react physics implementation to tone synth and combination objects that are in the process of being reviewed and more. I plan to make it possible to sign app bundles compiled for MacOS shortly. We also have several outstanding pull requests that still need review, including an absolutely massive documentation update, network object encryption via the noise framework, tts_voice enhancements for Android, plugin signing and more. Some of these pull requests will not be ready for merge until the next version after the upcoming 0.90.0 release.

## What will be in the next update?
There have been so many changes since the last official release of the engine that it would be difficult to list them here without carefully writing an entire changelog, but lets try to note some of the major ones, in no particular order at this time. I've skipped describing changes that are in any way described above for brevity.

* We now have the long-awaited http object for high level web requests.
* we also have access to raw tcp stream sockets, at least as a connecting client, as well as a fully functional websockets client.
* Several new includes such as a basic character movement controller, an include to manage and display game statistics and more.
* Python and PHP modules for interacting with nvgt's string_aes functions.
* Major improvements to NVGT's Github continuous integration allow us to automatically generate prereleases for all platforms for every new commit. In fact, you can visit the repositories [releases page](https://github.com/samtupy/nvgt/releases) to download the absolutely latest bleeding edge binary releases right now.
* Add the missing methods from bgt's calendar object to ours, such as diff_seconds and friends (though I believe they are not perfectly functional as of this blog post).
* array.shuffle and array.random.
* New methods to enumerate keyboards and mice as well as functions to convert key names into key codes and back.
* A method to query the system power state - useful for automatically saving games before battery death, determining if a cheater is lying on an online game when they tell you that the reason they disconnected at an opportune moment is because their battery didn't actually die etc.
* Several improvements to the Android support including the ability to use builtin includes in the runner and the ability to read app assets, much more.
* Improvements to json, most particularly list repeating factories that allow construction of JSON objects and arrays using the \{\{\}\} syntax.
* Various improvements to plugins including integrating the nvgt_extra repository, version checks, and updates to the plugin interface which allow plugins to register things like datastreams and custom pack_file formats.
* Our enet now supports IPV6, but this is still a work in progress - because the detection of which protocol to use is not yet automatic.
* Adds many math functions from the c++ standard template library.
* And much more, including fixes to various includes and core functions.

## Other happenings?
For those who need it, Steven D is providing paid training using NVGT. While NVGT is the current language of choice in his classes, the concepts he teaches are useful in almost any programming language. Particularly he is very good at teaching someone how to start programming from the ground up in a friendly manner that is tailored to your pace, I've personally witnessed people go from hardly knowing what a function is to getting ready to release their first games in a shorter time than one might have ever expected through his lessons! If you are a hands on learner rather than someone who is good at learning through documentation and if you've got interest as well as a few bucks to spare, you can [learn more about his classes here](https://stevend.net/classes/) and take the free assessment he offers to see if this might be for you!

We now have a [community forum](https://forum.nvgt.gg) for those who cannot use discord. I must throw up my hands and fully admit that I have not been nearly as active on this forum as I should have been lately, and intend to fully rectify that error on my part with the publishing of this post.

As for me, I have released my first offline paid game written in NVGT. It's a collection of endless runners called [Constant Motion](https://samtupy.com/games/constant-motion) and has a free trial if you wish to check it out! I'm not the only one who is allowed to advertise games created in NVGT on this blog, anybody can contact us and have their game listed in a post here!

## Final thoughts
In the end, NVGT development is going very well! I think it will still be some time before documentation is up to par, and I apologize to anybody who is currently confused regarding 2 sound systems existing in the engine at the same time and when  they should upgrade to the new one. There will be either a blog post or documentation soon which describes the sound system and multiple methods of pack encryption / when to use what in more detail, at the very latest when 0.90.0 is officially published. While I'm not entirely sure when 0.90.0 will be released, the goal is to push out the release as soon as miniaudio is fully stable and after we've tied up a few loose ends. We look forward to continuing to make NVGT the best audio game development engine that we are capable of making it.

Thanks for reading!