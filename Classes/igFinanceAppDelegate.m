//
//  igFinanceAppDelegate.m
//  igFinance
//
//  Created by Ash Lux on 5/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "igFinanceAppDelegate.h"
#import "RootViewController.h"


@implementation igFinanceAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
