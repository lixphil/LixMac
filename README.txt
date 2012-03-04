INTRODUCTION

Welcome! This is the repo of the Mac OS X fork for SimonN's game, Lix. It contains an Xcode project and some other Mac-specific resources and little enhancements to make the game feel more at home for the Mac user. Over time I'll gradually make updates on the project and hopefully provide regular builds.

The project contains two targets:
- LixMac, the main game
- lixd, a daemon used to run a dedicated Lix server (currently unfinished)


DEVELOPMENT BUILDS

Check out http://asdfasdf.ethz.ch/~phil for more info. 

10.6 and greater is supported (if there are any PPC users out there, I can support 10.5. But at the moment I've got 10.6-only code which makes stuff like the hacked-in mouse input a lot easier to do)


COMPILING THE XCODE PROJECT YOURSELF

The project is found in ./mac/xcode/LixMac.xcodeproj. It will build out of the box using Xcode 3 or 4.

You'll need two libraries that should be installed in /usr/local/lib (headers in /usr/local/include):
- enet 1.3 (1.3.1 will also work)
- Allegro 4.4.1 (the project uses the framework version of Allegro, make sure to set the variable when using CMake)

If you want Universal binaries of these libraries, read the notes below.

For Allegro, set the CFLAGS and LDFLAGS environment variables to:

-arch i386 -arch ppc

before running ./configure.

For enet, I had a bit more difficulty and had to individually compile one i386 and ppc version of the lib, then merge the two using the lipo tool.


CONTACT

Email: aborttrap@gmail.com
IRC: philM, #lix, quakenet.org (usually just idling)


Have fun!
- phil