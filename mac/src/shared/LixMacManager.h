//
//  LixMacManager.h
//  LixMac
//
//  Created by Phil on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LixMacManager : NSObject {
	BOOL wantToQuit;
	BOOL quitAlertOpen;
    BOOL isFullscreen;
}

@property (assign, readwrite) BOOL wantToQuit;
@property (assign, readwrite) BOOL quitAlertOpen;
@property (assign, readwrite) BOOL isFullscreen;

+ (LixMacManager*) sharedManager; 

@end
