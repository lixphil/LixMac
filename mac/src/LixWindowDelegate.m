//
//  LixWindowDelegate.m
//  LixMac
//
//  This class allows us to regain control over who receives the window events.
//  It is useful for fixing input bugs.
//
//  Created by Phil on 24/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LixWindowDelegate.h"
#import "LixManager.h"

@implementation LixWindowDelegate

-(BOOL) windowShouldClose:(id)sender {
    // We have to implement a handler here as well, since a runtime error can occur 
    // if the user quits the game (by any means, menu/window), dismissing the alert
    // and again tries to quit the game by closing the window
    [[LixManager sharedManager] beginQuitAlert]; 
    return NO;
}

-(void) windowWillMove:(NSNotification *)notification {
    //NSLog(@"window moving");
    [[LixManager sharedManager] setIsWindowMoving:YES];
}

-(void) windowDidMove:(NSNotification *)notification {
    //NSLog(@"window stopped moving");
    [[LixManager sharedManager] setIsWindowMoving:NO];
}

@end
