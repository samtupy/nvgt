---
title: Continuous integration scripts
layout: default.liquid
---
# {{ page.title }}
Hello curious user, welcome to the root directory that contains a few PHP scripts that help us manage a few things with the NVGT CI workflows we have set up.

You can see how it all works and even attain the source code for these scripts by looking at the NVGT github repository in the web/ci directory and in the .github/workflows directory.

Sometimes a CI action in nvgt will upload an artifact, such as a new version of the website or an nvgt release, to a restricted ftp directory outside of the webroot. The action will then call one of these php scripts in the ci directory you are viewing which can handle the artifact from the server hosting NVGT, such as by unpacking it or displaying it on a releases page etc.

The scripts are of course password protected using github secrets, meaning that we can describe how the process works and even release the code for it without any security implecations.

We could certainly have chozen to use SSH keys for tasks like this, one was even generated in fact before the much simpler aproach of simple serverside PHP scripts was thought of. We are of course willing to change this infrastructure if we find that it presents problems or security risks, but until then we expect that this setup should work quite well!
