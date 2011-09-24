//
//  LixWindowDelegate.h
//  LixMac
//
//  This class allows us to regain control over who receives the window events.
//  It is useful for fixing input bugs.
//
//  Created by Phil on 24/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LixWindowDelegate : NSObject <NSWindowDelegate> 
@end
