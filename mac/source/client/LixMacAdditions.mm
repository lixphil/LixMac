//
//  LixMacAppController.mm
//  LixMac
//
//  Created by Phil on 9/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// TODO: close window action

#import "LixMacAdditions.h"
#import "LixMacMacros.h"
#import "LixMacManager.h"

@implementation NSObject (LixAdditions)

-(IBAction)quitAllegro:(id)sender {
	[NSCursor unhide]; // Sometimes the cursor is still hidden
	[[LixMacManager sharedManager] setQuitAlertOpen:YES];
	NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to quit Lix?" defaultButton:@"Quit" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Any unsaved progress will be lost."];
	[alert beginSheetModalForWindow:allegroWindow modalDelegate:nil didEndSelector:@selector(quitAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) quitAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[[LixMacManager sharedManager] setQuitAlertOpen:NO];
	if (returnCode == NSOKButton)
		[[LixMacManager sharedManager] setWantToQuit:YES];
}

@end