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
@synthesize quitAlertOpen;
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
	[self setQuitAlertOpen:YES];
    
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
    
    [alert beginSheetModalForWindow:allegroWindow modalDelegate:self didEndSelector:@selector(quitAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    [NSCursor unhide]; // Sometimes the cursor is still hidden
}

- (void) quitAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self setQuitAlertOpen:NO];
	if (returnCode == NSOKButton)
		[self setWantToQuit:YES];
}


#pragma mark -
#pragma mark Hardware input improvements

- (NSPoint) mouseLocationFromGameWindowSizeOfX:(int)scrX andY:(int)scrY {
    NSPoint mouseLocation = [NSEvent mouseLocation];
    if (([self isWindowMoving] || [self quitAlertOpen] || ![allegroWindow isKeyWindow]) && ![self isFullscreen]) { // window is inactive/moving
        mouseLocation.x = scrX / 2;
        mouseLocation.y = scrY / 2;
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
        mouseLocation.y = scrY - mouseLocation.y; // invert Y coord
    }

    return mouseLocation;
}
    
@end


# pragma mark -
# pragma mark Menu item functions

@implementation LixAdditions

-(id) init {
    //[NSMenu 
    return [super init];
}


-(IBAction) enterFullScreenMode:(id)sender {
    [[LixMacManager sharedManager] setShouldSwitchScreenMode:YES];
}

@end