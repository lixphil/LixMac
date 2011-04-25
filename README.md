# Lix (for Mac OS X)
Mac OS X version & Cocoa server frontend by "lixphil"

Game codebase by "SimonN"

### Introduction

This is the Mac OS X fork for SimonN's game, Lix. It essentially contains an Xcode project with the appropriate configuration as well as some other Mac-specific resources and minor enhancements. It'll be a personal project, which, over time I'll gradually update.

The project contains four targets:

* LixCore, a framework containing all of the core Lix code
* LixMac, an executable that is linked with LixCore and provides a few niceties exclusive to the Mac platform
* lixserv, the command-line utility used to run a dedicated Lix server
* LixServer, a simple GUI application to control the server. It lives in the menu bar, and provides control and statistics for the server. (it is a work-in-progress at the moment)


### Compiling The Project

#### Requirements:

To build Lix for Mac OS X, you'll need Apple's Developer Tools for Xcode and the tools needed to compile. The game will also require two additional libraries:

* enet 1.3 (1.3.1 will also work)
* Allegro 4.4.1

Note that the builds that I provide use Universal binaries of Allegro and enet. 
For Allegro, I set the CFLAGS and LDFLAGS environment variables to -arch i386 -arch ppc before running ./configure.
For enet, I had a bit more difficulty and had to individually compile separate libraries with the two different architectures, then merge the two into one using the lipo tool.


#### Building in Xcode:

Firstly, open ./mac/xcode/LixMac.xcodeproj.

##### To build the game (client):

Select the "LixMac" target, and "Build and Run".

##### To build the server (with the frontend):

Change the target to "LixServer". (or lixserv if you only want the server executable and not the controller app), and "Build and Run".

##### To build the server (with just the server binary):

1. Change the target to "lixserv", and "Build and Run".
2. Move ./mac/xcode/build/Debug/LixCore.framework to /Library/Frameworks.
3. Make sure /usr/local/lib/liballeg.4.4.1.dylib exists.

(note: this has not yet been tested, but it should work)


#### Other Notes

There are lots of things which are incomplete and/or buggy. In the Xcode project, do a project find for "TODO". My email address is aborttrap@gmail.com if you've got any questions.


Have fun!

lixphil
