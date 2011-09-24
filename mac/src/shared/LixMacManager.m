//
//  LixMacManager.m
//  LixMac
//
//  Created by Phil on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LixMacManager.h"

@implementation LixMacManager

@synthesize wantToQuit;
@synthesize quitAlertOpen;
@synthesize isFullscreen;

// Below declares a singleton
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

@end
