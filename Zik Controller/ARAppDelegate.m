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
    [menu setAutoenablesItems:NO];
    _connectStatus = [menu addItemWithTitle:@"Connection: Disconnected" action:nil keyEquivalent:@""];
    [_connectStatus setEnabled:NO];
    if ([_zikInterface searchForZikInConnectedDevices]) {
        _connectItem = [menu addItemWithTitle:@"Connecting..." action:nil keyEquivalent:@""];
    } else {
        _connectItem = [menu addItemWithTitle:@"Connect" action:@selector(connect:) keyEquivalent:@""];
        [_zikInterface registerForNewDevices];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    _batteryStatus = [menu addItemWithTitle:@"Zik Status" action:nil keyEquivalent:@""];
    [_batteryStatus setEnabled:NO];
    _LouReedModeItem = [menu addItemWithTitle:@"Tuned by Lou Reed" action:@selector(toggleLouReedMode:) keyEquivalent:@""];
    _ANCItem = [menu addItemWithTitle:@"Noise Cancellation" action:@selector(toggleANCMode:) keyEquivalent:@""];
    _ConcertHallEffectItem =[menu addItemWithTitle:@"Concert Hall Effect" action:@selector(toggleConcertHallEffect:) keyEquivalent:@""];
    _EquItem =[menu addItemWithTitle:@"Equalizer" action:@selector(toggleEqualizer:) keyEquivalent:@""];
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
        [_zikInterface refreshZikStatus];
    } else {
        [_connectStatus setTitle:@"Connection: Disconnected"];
        _statusItem.toolTip = @"Zik Controller: Disconnected";
        [_connectItem setTitle:@"Connect"];
        [_connectItem setAction:@selector(connect:)];
        [_batteryStatus setTitle:@"Zik Status"];
    }
    [_connectItem setEnabled:YES];

}

-(void)LouReedModeState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_LouReedModeItem setState:YES];
    } else {
        [_LouReedModeItem setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_LouReedModeItem setEnabled:NO];
    } else {
        [_LouReedModeItem setEnabled:YES];
    }
}

-(void)ActiveNoiseCancellationState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_ANCItem setState:YES];
    } else {
        [_ANCItem setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_ANCItem setEnabled:NO];
    } else {
        [_ANCItem setEnabled:YES];
    }
}

-(void)ConcertHallEffectState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_ConcertHallEffectItem setState:YES];
    } else {
        [_ConcertHallEffectItem setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_ConcertHallEffectItem setEnabled:NO];
    } else {
        [_ConcertHallEffectItem setEnabled:YES];
    }
}

-(void)EqualizerState:(OptionStatus)status;
{
    if (status == ON || status == INVALID_ON) {
        [_EquItem setState:YES];
    } else {
        [_EquItem setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_EquItem setEnabled:NO];
    } else {
        [_EquItem setEnabled:YES];
    }
}


- (void)newBatteryStatus:(BOOL)charging :(NSInteger)level
{
    if (charging){
        [_batteryStatus setTitle:@"Zik Status: Charging"];
    } else {
        [_batteryStatus setTitle:[NSString stringWithFormat:@"Zik status: %ld%%", level]];
    }
}

-(void)toggleLouReedMode:(id)sender
{
    if ([_LouReedModeItem state] == YES) {
        [_LouReedModeItem setState:NO];
    } else {
        [_LouReedModeItem setState:YES];
    }
    [_zikInterface setLouReedModeState:[_LouReedModeItem state] == YES];
    [_zikInterface refreshZikStatus];
}


-(void)toggleANCMode:(id)sender
{
    if ([_ANCItem state] == YES) {
        [_ANCItem setState:NO];
    } else {
        [_ANCItem setState:YES];
    }
    [_zikInterface setActiveNoiseCancellationState:[_ANCItem state] == YES];
}

-(void)toggleConcertHallEffect:(id)sender
{
    if ([_ConcertHallEffectItem state] == YES) {
        [_ConcertHallEffectItem setState:NO];
    } else {
        [_ConcertHallEffectItem setState:YES];
    }
    [_zikInterface setConcertHallState:[_ConcertHallEffectItem state] == YES];
}

-(void)toggleEqualizer:(id)sender
{
    if ([_EquItem state] == YES) {
        [_EquItem setState:NO];
    } else {
        [_EquItem setState:YES];
    }
    [_zikInterface setEqualizerState:[_EquItem state] == YES];
}

@end
