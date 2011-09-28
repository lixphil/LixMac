//
//  LixMacManager.m
//  LixMac
//
//  Created by Phil on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LixMacManager.h"
#import "LixMacMacros.h"

@implementation LixMacManager

@synthesize wantToQuit;
@synthesize alertOpen;
@synthesize isFullscreen;
@synthesize isWindowMoving;
@synthesize mouseHidden;
@synthesize shouldSwitchScreenMode;

// *** Start singleton definition

static LixMacManager *sharedManager = nil;

+ (LixMacManager*)sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone { return [[self sharedManager] retain]; }

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (NSUInteger)retainCount { return NSUIntegerMax; }

- (void)release {}

- (id)autorelease { return self; }

// *** End singleton definition


#pragma mark -
#pragma mark Core functions

- (void)replaceAllegroWindowDelegate {
    windowDelegate = [[LixWindowDelegate alloc] init];
    [allegroWindow setDelegate:windowDelegate];
}

- (void)beginQuitAlert {
    // Pause the game
	[self setAlertOpen:YES];
    
    // Get out of fullscreen so we can see the alert
    if ([self isFullscreen]) {
        [self setShouldSwitchScreenMode:YES];
    }
    
    // TODO: localize this based on the user's language choice? Get the system language?
	NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to quit Lix?" 
                                     defaultButton:@"Quit" 
                                   alternateButton:@"Cancel" 
                                       otherButton:nil 
                         informativeTextWithFormat:@"Any unsaved progress or changes made to levels will be lost."];
    
    [alert beginSheetModalForWindow:allegroWindow 
                      modalDelegate:self 
                     didEndSelector:@selector(quitAlertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];
    
    [self setMouseHidden:NO];
    [NSCursor unhide]; // Sometimes the cursor is still hidden
}

- (void) quitAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self setAlertOpen:NO];
	if (returnCode == NSOKButton)
		[self setWantToQuit:YES];
}

- (void)beginBadPermissionsAlert {
    NSAlert* alert = [NSAlert alertWithMessageText:@"Lix cannot be run inside this folder, because it is write-protected." 
                                     defaultButton:@"Copy" 
                                   alternateButton:@"Quit" 
                                       otherButton:nil 
                         informativeTextWithFormat:@"%@%@%@", 
                                                      @"Choose Copy to copy the application into the current account's Applications ",
                                                      @"folder (it will be created if it doesn't exist).\n\n",
                                                      @"Alternatively if you have the privileges, try running the game inside an Adminstrator account."];
    [alert beginSheetModalForWindow:nil 
                      modalDelegate:self 
                     didEndSelector:@selector(badPermissionsAlertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];
}

- (void) badPermissionsAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [self setAlertOpen:NO];
    [[alert window] orderOut:nil];
	if (returnCode == NSOKButton) {
        // Copy the bundle via the Finder
        // We need to do this via AppleScript, since NSWorkspace has a method only available in 10.6
        NSAppleScript* script = [[NSAppleScript alloc] initWithSource:
                                   [NSString stringWithFormat:
                                    @"tell application \"Finder\"\n \
                                         if not (exists folder \"Applications\" of (path to home folder)) then\n \
                                              make new folder at (path to home folder) with properties {name:\"Applications\"}\n \
                                         end if\n \
                                         duplicate POSIX file \"%@\" to (path to home folder) & \"Applications\" as string\n \
                                      end tell", 
                                        [[NSBundle mainBundle] bundlePath]]];
        NSMutableDictionary* error;
        if ([script executeAndReturnError:&error] == nil) {
            NSAlert* errorAlert = [NSAlert alertWithMessageText:@"There was an error trying to copy the Lix application." 
                                                  defaultButton:@"Quit" 
                                                alternateButton:nil 
                                                    otherButton:nil 
                                      informativeTextWithFormat:@"The error was: \"%@\"\n\nTry copying the application manually to any location inside your user account's folder.", 
                                   [error valueForKey:@"NSAppleScriptErrorBriefMessage"]];
            [errorAlert runModal];
            [self setWantToQuit:YES];
        } else {
            NSAlert* successAlert = [NSAlert alertWithMessageText:@"Lix copied successfully to the new location." 
                                                    defaultButton:@"Relaunch" 
                                                  alternateButton:nil 
                                                      otherButton:nil 
                                        informativeTextWithFormat:@"Click Relaunch to quit this instance of Lix, and run the game in the new location."];
            [successAlert runModal];
            // openURL: didn't work
            [[NSWorkspace sharedWorkspace] openFile:[@"~/Applications/Lix.app" stringByExpandingTildeInPath]];
            [self setWantToQuit:YES];
        }
    } else {
        [self setWantToQuit:YES];
    }
}

#pragma mark -
#pragma mark Hardware input improvements

- (NSPoint) mouseLocationFromGameWindowSizeOfX:(int)scrX andY:(int)scrY {
    NSPoint mouseLocation = [NSEvent mouseLocation];
    // TODO: rewrite this logic?
    if (([self isWindowMoving] || [self alertOpen] || ![allegroWindow isKeyWindow]) && ![self isFullscreen]) { // window is inactive/moving
        mouseLocation.x = scrX / 2;
        mouseLocation.y = scrY / 2;
        [self setMouseHidden:NO];
        [NSCursor unhide];
    } else if ([allegroWindow isKeyWindow]) {
        NSRect windowFrame = [allegroWindow frame]; // Get the position of the window
        // These coordinates seem to be dead accurate
        // TODO: scaled windows (see options)?
        mouseLocation.x -= windowFrame.origin.x + 1;
        mouseLocation.y = (windowFrame.origin.y - mouseLocation.y) + windowFrame.size.height - 24;
        
        if (mouseLocation.x < 0 || mouseLocation.x > scrX || mouseLocation.y < 0 || mouseLocation.y > scrY) {
            if ([self mouseHidden])  { [NSCursor unhide]; [self setMouseHidden:NO]; }
        } else {
            if (![self mouseHidden]) { [NSCursor hide]; [self setMouseHidden:YES]; }
        }
    } else if ([self isFullscreen]) { // must be fullscreen
        [allegroWindow makeMainWindow];
        // always hide the mouse in fullscreen
        [self setMouseHidden:YES];
        [NSCursor hide];
        
        mouseLocation.y = scrY - mouseLocation.y; // invert Y coord
    }
    return mouseLocation;
}
    
@end


# pragma mark -
# pragma mark Menu item functions

@implementation LixAdditions

-(IBAction) enterFullScreenMode:(id)sender {
    [[LixMacManager sharedManager] setShouldSwitchScreenMode:YES];
}

-(IBAction) openGameDocsFolder:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"%@/Contents/Resources/doc", [[NSBundle mainBundle] bundleURL]]]];
}
@end