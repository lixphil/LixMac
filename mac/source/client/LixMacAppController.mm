//
//  LixMacAppController.mm
//  LixMac
//
//  Created by Phil on 9/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// TODO: Credits.rtf
// TODO: devising a good method to quit Allegro
// TODO: quit menu item and close window action

#import "LixMacAppController.h"
#import "LixMacMacros.h"

@implementation NSObject (LixAdditions)

-(IBAction)quitAllegro:(id)sender {
	NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to quit Lix?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"Any unsaved progress will be lost."];
	[alert beginSheetModalForWindow:allegroWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

@end