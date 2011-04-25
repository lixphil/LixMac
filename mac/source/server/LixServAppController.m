//
//  LixServAppController.m
//  This is work-in-progress!
//
//  Created by Phil on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "LixServAppController.h"
#import <Cocoa/Cocoa.h>

@implementation LixServAppController

// TODO: Lots of unimplemented GUI stuff

-(void) awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:appMenu];
	[statusItem setImage:[NSImage imageNamed:@"lixServerMenuIcon.png"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"lixServerMenuIconDown.png"]];
	[statusItem setHighlightMode:YES];
	
	// Alert here
	// Make the application frontmost
	[[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
	NSAlert* alert = [NSAlert alertWithMessageText:@"The Lix Server has been started." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Use the application's menu to view statistics, control the state of the server, set preferences and view the server log."];
	[alert setIcon:[NSImage imageNamed:@"lixServerIcon.icns"]];
	[alert runModal];
	
	[self toggleServerState:self];
}

-(void) applicationDidFinishLaunching:(NSNotification *)notification {
	// We are running by default, TODO: work on preferences
}

-(void) applicationWillTerminate:(NSNotification *)notification {
	// Terminate the process
}

-(void) setServerRunning:(BOOL)val {
	serverRunning = val;
	[self setMenuState:serverRunning];
}

-(void) setMenuState:(BOOL)val{
	if (val) {
		[serverStateItem setTitle:@"Started"];
		[serverStateActionItem setTitle:@"Stop Server"];
		val = NO;
	} else {
		[serverStateItem setTitle:@"Stopped"];
		[serverStateActionItem setTitle:@"Start Server"];
		val = YES;
	}

	[serverDetailsHeader setHidden:val];
	[serverDetailsSeparator setHidden:val];
	[serverVersionItem setHidden:val];
	[serverRoomsItem setHidden:val];
	[serverPlayersItem setHidden:val];
}

-(IBAction) toggleServerState:(id)sender {
	if (!serverRunning) {
		[self setServerRunning:YES];
		[self startServer];
	} else {
		[self setServerRunning:NO];
		[self endServer];
	}
}

-(IBAction) preferences:(id)sender {
	NSSize screenSize = [[NSScreen mainScreen] frame].size;
	NSSize windowSize = [preferencesWindow frame].size;
	
	NSPoint point = NSMakePoint((screenSize.width/2)-(windowSize.width/2), screenSize.height-(screenSize.height/3));
	[preferencesWindow setFrameOrigin:point];
	[preferencesWindow makeKeyAndOrderFront:self];
}

-(IBAction) networkLog:(id)sender {
	NSSize screenSize = [[NSScreen mainScreen] frame].size;
	NSSize windowSize = [networkLogWindow frame].size;
	
	NSPoint point = NSMakePoint((screenSize.width/2)-(windowSize.width/2), (screenSize.height/2)-(windowSize.height/2));
	[networkLogWindow setFrameOrigin:point];
	[networkLogWindow makeKeyAndOrderFront:self];
}

-(IBAction) quit:(id)sender {
	NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to stop and quit Lix Server?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"All players connected to your server will be disconnected.\n\nIf you notice that the Lix Server menu is frozen, open Activity Monitor and force quit both of the 'LixServer' processes that are running.", serverPid]];
	[alert setIcon:[NSImage imageNamed:@"lixServerIcon.icns"]];
	
	// If we agree to the alert
	if ([alert runModal] == NSAlertDefaultReturn && serverRunning == YES) {
		[self endServer];
		[server waitUntilExit];
		[NSApp terminate:self];
	}
}




// ********************************
// *** Server control functions ***
// ********************************

-(void) startServer {
	// Start the process here
	NSString* path = [NSString stringWithFormat:@"%@/lixserv", 
					  [[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent]];
	server = [[[NSTask alloc] init] retain];
	serverStdout = [[NSPipe alloc] init];
	[server setLaunchPath:path];
	[server setStandardOutput:serverStdout];
	[server launch];
	
	serverPid = [server processIdentifier];
}

-(BOOL) endServer {
	[server terminate];
	[serverStdout release];
}

@end
