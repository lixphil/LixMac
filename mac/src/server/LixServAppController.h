//
//  LixServAppController.h
//  LixMac
//
//  Created by Phil on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LixServAppController : NSObject <NSApplicationDelegate> {
	BOOL serverRunning;
	NSTask* server;
	int serverPid;
	NSPipe* serverStdout;
	NSFileHandle* serverStdoutFileHandle;
	
	// Main menu items
	IBOutlet NSMenu* appMenu;
	IBOutlet NSMenuItem* serverStateItem;
	IBOutlet NSMenuItem* serverStateActionItem;
	
	// Details of menu
	IBOutlet NSMenuItem* serverDetailsHeader;
	IBOutlet NSMenuItem* serverDetailsSeparator;
	IBOutlet NSMenuItem* serverVersionItem;
	IBOutlet NSMenuItem* serverRoomsItem;
	IBOutlet NSMenuItem* serverPlayersItem;
	
	IBOutlet NSWindow* preferencesWindow;
	IBOutlet NSWindow* networkLogWindow;
	IBOutlet NSWindow* closingServerWindow;
	NSStatusItem* statusItem; // The menu bar item
	
	// Thread
	NSThread* thread;
} 

-(IBAction) toggleServerState:(id)sender;
-(IBAction) preferences:(id)sender;
-(IBAction) networkLog:(id)sender;
-(IBAction) quit:(id)sender;

-(void) setMenuState:(BOOL)val;
-(void) setServerRunning:(BOOL)val;

-(void) startServer;
-(BOOL) endServer;

@end
