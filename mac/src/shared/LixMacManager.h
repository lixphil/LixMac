//
//  LixMacManager.h
//  LixMac
//
//  The main class which provides the Mac compatibility
//
//  Created by Phil on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LixWindowDelegate.h"

@interface LixMacManager : NSObject {
	BOOL wantToQuit;
	BOOL alertOpen;
    BOOL isFullscreen;
    BOOL mouseHidden;
    BOOL isWindowMoving;
    BOOL shouldSwitchScreenMode;
    LixWindowDelegate* windowDelegate;
}

// Accessed from other Obj-C classes, and game source files with extension mm (some headers too)
@property (assign, readwrite) BOOL wantToQuit;
@property (assign, readwrite) BOOL alertOpen;
@property (assign, readwrite) BOOL isFullscreen;
@property (assign, readwrite) BOOL mouseHidden;
@property (assign, readwrite) BOOL isWindowMoving;
@property (assign, readwrite) BOOL shouldSwitchScreenMode;

+ (LixMacManager*) sharedManager; 

// Core functions
- (void) beginQuitAlert; // called by Allegro's close window handler function in lmain.cpp
- (void) beginBadPermissionsAlert;
- (void) replaceAllegroWindowDelegate;

// Hardware input improvements
- (NSPoint) mouseLocationFromGameWindowSizeOfX:(int)scrX andY:(int)scrY;

@end

@interface LixAdditions : NSObject

-(IBAction) enterFullScreenMode:(id)sender;
-(IBAction) openGameDocsFolder:(id)sender;

@end