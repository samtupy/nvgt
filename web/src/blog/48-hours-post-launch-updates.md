---
title: 48-hours-post-launch-updates
layout: post.liquid
is_draft: true
---
# {{ page.title }}
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

Note: Mac OS and liux compilation still needs to be tested and improved.

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

## The number_speaker.nvgt Include
Thanks to ogomez92, the number_speaker.bgt include shipped with BGT has now been ported over to NVGT!

For those who attempt to use this in their programs, it should now work properly!

If you are not familiar with it, this script allows you to easily play recorded samples of number words, based on integer values.

## The Other Directory
A growing collection miscellaneous items including some code samples (in the other directory):
* in the other directory, there is a new simple_nvgt_console.nvgt script, which servers as a subscripting example and a simple environment for testing and experimentation
* in the other directory as well, a new pack_creater.nvgt script from Masonasons makes it easier than ever to get packs ready to use in your games.
* There are also more references for some classes and functions. Although these are sometimes out of date, they are included because they can help you to understand some components of NVGT which are not yet documented
* a new fx.txt file contains documentation for the fx system in NVGT
* there are also other examples to help explain a few miscellaneous actions, like signing executables

## What's Next?
While installers and official downloads are indeed available, it should be noted that this engine is still in its beta stage; complete stability in every aspect is neither expected nor guaranteed, although contributors and early users have had great success converting a huge variety of games from bgt already!

More updates will be given as they are available, and thank you for trying NVGT!
