//
//  AppDelegate.m
//  HelperApp
//
//  Created by Rui Araújo on 15/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //NSLog(@"I am running\n");
    // Check if main app is already running; if yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:@"com.doublecheck.zikcontroller"]) {
            alreadyRunning = YES;
            break;
        }
    }
    
    if (!alreadyRunning) {
        NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        // get to the waaay top. Goes through LoginItems, Library, Contents, Applications
        //NSLog(@"%@\n", appPath);
        [[NSWorkspace sharedWorkspace] launchApplication:appPath];
    }
    //[NSApp terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
