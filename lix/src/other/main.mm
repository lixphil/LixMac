/*
 * other/main.cpp
 *
 * Introduction
 *
 *   This is the main file for Lix. The game is written in C++ and uses
 *   two libraries:
 *
 *   - Allegro (www.allegro.cc)  for graphics, sound and input,
 *   - enet    (enet.bespin.org) for networking.
 *
 * License
 *
 *   Lix is free software.
 *
 *   You may do anything you'd like with this game. Download, play, use, alter
 *   and spread Lix as you wish. There are no restrictions. I am just not
 *   responsible for any bugs, loss of data, or the like.
 *
 *   I believe that programming should be an entertaining hobby, not fiddling
 *   around with license restrictions. I've had and still have a lot of fun
 *   with the development and playtesting of this game. You should have as
 *   as possible, too.
 *
 * About the source code itself
 *
 *   The source code consists of about 850 KB. It consists of roughly 30,000
 *   lines. 20,000 of those are code lines, the rest are comments and empty
 *   lines.
 *
 *   The core of the program is an object of class LMain. Usually I have
 *   commented each class in its header file. For LMain, this is other/lmain.h.
 *
 * Have fun going through the souce code!
 *
 * Simon
 *
 */

#include "lmain.h" // Main object, as commented upon above
#include "user.h"

#include "../lix/lix_enum.h" // initialize the strings in there

#ifdef ALLEGRO_MACOSX
#include <Cocoa/Cocoa.h>
#include "LixMacMacros.h"
#include "LixMacAppController.h"
#endif

int main(int argc, char* argv[])
{
    allegro_init();
    Help::timer_start();

    Globals::initialize();
    User::initialize();
    Log::initialize();
    LixEn::initialize();

    gloB->load();
    useR->load();
    Help::MainArgs margs = Help::parse_main_arguments(argc, argv);

    // Allegro preparations, no graphics function are called yet
    install_keyboard();
    install_mouse();
    if (margs.sound_load_driver) Sound::initialize();

    // Allegro graphics
    set_color_depth(32);
    set_screen_mode(0, margs.scr_x, margs.scr_y); // in glob_gfx.h
    set_window_title(Language::main_name_of_the_game.c_str());
	
	#ifdef ALLEGRO_MACOSX
		// The instance of AllegroWindow is setup from this point. We can access it via [NSApp mainWindow] (see LixMacMacros.h)
		// But I'm going to put the window's view into my own window, so I have more control over it.
		// Then I'll release the AllegroWindow.
		//LixMacAppController* app = [[LixMacAppController alloc] init];
	
		
	#endif
	
    load_all_bitmaps();
    Network::initialize();

    // Main loop. See other/lmain.cpp for this.
    LMain* l_main = new LMain;
	
	// We need to expose LMain so the Cocoa interface can access it - phil
	
	
    l_main->main_loop();
    delete l_main;

    // Clean up
    useR->save();
    gloB->save();

    Network::deinitialize();
    Sound::deinitialize();
    destroy_all_bitmaps();
    Log::deinitialize();
    Globals::deinitialize();
	
    // don't call allegro_exit(), doing that causes the program
    // to not terminate in rare cases
    return 0;
}
END_OF_MAIN()
