//
//  AppDelegate.m
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARAppDelegate.h"
@interface ARAppDelegate ()

@end

@implementation ARAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _zikInterface = [[ARZikInterface alloc] init];
    _zikInterface.delegate = self;
    [self setupStatusItem];
}


- (void)setupStatusItem
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"StatusItem-Image"];
    _statusItem.alternateImage = [NSImage imageNamed:@"StatusItem-AlternateImage"];
    _statusItem.highlightMode = YES;
    _statusItem.toolTip = @"Zik Controller: Disconnected";
    [self setupMenu];
}

- (void)setupMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    _connectStatus = [menu addItemWithTitle:@"Connection: Disconnected" action:nil keyEquivalent:@""];
    if ([_zikInterface searchForZikInConnectedDevices]) {
        _connectItem = [menu addItemWithTitle:@"Connecting..." action:nil keyEquivalent:@""];
    } else {
        _connectItem = [menu addItemWithTitle:@"Connect" action:@selector(connect:) keyEquivalent:@""];
        [_zikInterface registerForNewDevices];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    _batteryStatus = [menu addItemWithTitle:@"Zik Status" action:nil keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit Zik Controller" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
}


- (void)connect:(id)sender
{
    [_connectItem setTitle:@"Connecting..."];
    [_connectItem setEnabled:NO];
    if (![self.zikInterface connectToZik]) {
        [_connectItem setTitle:@"Connect"];
        [_connectItem setEnabled:YES];
    } else {
        [_connectStatus setTitle:@"Connection: Connecting..."];
        
    }
}
- (void)disconnect:(id)sender
{
    [_connectStatus setTitle:@"Connection: Disconnected"];
    _statusItem.toolTip = @"Zik Controller: Disconnected";
    [_batteryStatus setTitle:@"Zik Status"];
    [self.zikInterface disconnectFromZik];
    [_connectItem setTitle:@"Connect"];
    [_connectItem setAction:@selector(connect:)];
    
}

- (void)terminate:(id)sender
{
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

- (void)zikConnectionComplete:(IOReturn)status
{
    if ( status == kIOReturnSuccess){
        [_connectStatus setTitle:@"Connection: Connected"];
        _statusItem.toolTip = @"Zik Controller: Connected";
        [_connectItem setTitle:@"Disconnect"];
        [_connectItem setAction:@selector(disconnect:)];
        [_zikInterface updateBatteryStatus];
    } else {
        [_connectStatus setTitle:@"Connection: Disconnected"];
        _statusItem.toolTip = @"Zik Controller: Disconnected";
        [_connectItem setTitle:@"Connect"];
        [_connectItem setAction:@selector(connect:)];
        [_batteryStatus setTitle:@"Zik Status"];
    }
    [_connectItem setEnabled:YES];

}

- (void)updateBatteryStatus:(NSTimer *)timer
{
    [_zikInterface updateBatteryStatus];
}


- (void)newBatteryStatus:(BOOL)charging :(NSInteger)level
{
    if (charging){
        [_batteryStatus setTitle:@"Zik Status: Charging"];
    } else {
        [_batteryStatus setTitle:[NSString stringWithFormat:@"Zik status: %ld%%", level]];
    }
}


@end
