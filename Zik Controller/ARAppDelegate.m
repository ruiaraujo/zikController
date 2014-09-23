//
//  AppDelegate.m
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import "StartAtLoginController.h"

#define LOW_BATTERY_LEVEL_WARNING   5

@interface ARAppDelegate ()

@end

@implementation ARAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _zikInterface = [[ARZikInterface alloc] init];
    //_zikInterface.delegate = self;
    [_zikInterface addObserver:self];
    //loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.doublecheck.zikcontroller.HelperApp"];
    [self setupStatusItem];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)setupStatusItem
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"StatusItem-Image"];
    [_statusItem.image setTemplate:YES];
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
    }
    [_zikInterface registerForNewDevices];
    [menu addItem:[NSMenuItem separatorItem]];
    _batteryStatus = [menu addItemWithTitle:@"Zik Status" action:nil keyEquivalent:@""];
    [_batteryStatus setEnabled:NO];
    _LouReedModeItem = [menu addItemWithTitle:@"Tuned by Lou Reed" action:@selector(toggleLouReedMode:) keyEquivalent:@""];
    _ANCItem = [menu addItemWithTitle:@"Noise Cancellation" action:@selector(toggleANCMode:) keyEquivalent:@""];
    _ConcertHallEffectItem =[menu addItemWithTitle:@"Concert Hall Effect" action:@selector(toggleConcertHallEffect:) keyEquivalent:@""];
    _concertHallMenu = [[NSMenu alloc] init];
    [[_concertHallMenu addItemWithTitle:@"Room size" action:nil keyEquivalent:@""] setEnabled:NO];
    _SilentRoom = [_concertHallMenu addItemWithTitle:@"Silent Room" action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _LivingRoom = [_concertHallMenu addItemWithTitle:@"Living Room" action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _JazzClub = [_concertHallMenu addItemWithTitle:@"Jazz Club" action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _ConcertHall = [_concertHallMenu addItemWithTitle:@"Concert Hall" action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    [_concertHallMenu addItem:[NSMenuItem separatorItem]];
    [[_concertHallMenu addItemWithTitle:@"Angle" action:nil keyEquivalent:@""] setEnabled:NO];
    _Degree_30 = [_concertHallMenu addItemWithTitle:@"30" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_60 = [_concertHallMenu addItemWithTitle:@"60" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_90 = [_concertHallMenu addItemWithTitle:@"90" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_120 = [_concertHallMenu addItemWithTitle:@"120" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_150 = [_concertHallMenu addItemWithTitle:@"150" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_180 = [_concertHallMenu addItemWithTitle:@"180" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _EquItem =[menu addItemWithTitle:@"Equalizer" action:@selector(toggleEqualizer:) keyEquivalent:@""];
    _equalizerMenu = [[NSMenu alloc] init];
    [[_equalizerMenu addItemWithTitle:@"Presets" action:nil keyEquivalent:@""] setEnabled:NO];
    _vocalPreset = [_equalizerMenu addItemWithTitle:@"Vocal" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _popPreset = [_equalizerMenu addItemWithTitle:@"Pop" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _clubPreset = [_equalizerMenu addItemWithTitle:@"Club" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _punchyPreset = [_equalizerMenu addItemWithTitle:@"Punchy" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _deepPreset = [_equalizerMenu addItemWithTitle:@"Deep" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _crystalPreset = [_equalizerMenu addItemWithTitle:@"Crystal" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _userPreset = [_equalizerMenu addItemWithTitle:@"User" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    //TODO rework this later.
    //_launchAtLogin = [menu addItemWithTitle:@"Launch at login" action:@selector(toggleLaunchAtLogin:) keyEquivalent:@""];
    //[_launchAtLogin setState:[loginController startAtLogin]];
    [menu addItemWithTitle:@"Quit Zik Controller" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
}


- (void)toggleLaunchAtLogin:(id)sender
{
    if ([_launchAtLogin state] == YES) {
        [_launchAtLogin setState:NO];
    } else {
        [_launchAtLogin setState:YES];
    }
    [loginController setStartAtLogin:[_launchAtLogin state] == YES];
    [_launchAtLogin setState: [loginController startAtLogin]];
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

- (void)newZikConnectionStatus:(IOReturn)status
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    if ( status == kIOReturnSuccess){
        [_connectStatus setTitle:@"Connection: Connected"];
        _statusItem.toolTip = @"Zik Controller: Connected";
        [_connectItem setTitle:@"Disconnect"];
        [_connectItem setAction:@selector(disconnect:)];
        [_zikInterface refreshZikStatus];
        notification.informativeText = @"Parrot Zik connected.";

    } else {
        [_connectStatus setTitle:@"Connection: Disconnected"];
        _statusItem.toolTip = @"Zik Controller: Disconnected";
        [_connectItem setTitle:@"Connect"];
        [_connectItem setAction:@selector(connect:)];
        [_batteryStatus setTitle:@"Zik Status"];
        notification.informativeText = @"Parrot Zik disconnected.";
    }
    notification.title = @"Zik Controller";
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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
        _ConcertHallEffectItem.submenu = _concertHallMenu;
    } else {
        [_ConcertHallEffectItem setState:NO];
        _ConcertHallEffectItem.submenu = nil;
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_ConcertHallEffectItem setEnabled:NO];
    } else {
        [_ConcertHallEffectItem setEnabled:YES];
    }
}


-(void)ConcertHallEffectRoomSize:(RoomSize)room
{
    
    [_SilentRoom setState:NO];
    [_LivingRoom setState:NO];
    [_JazzClub setState:NO];
    [_ConcertHall setState:NO];
    switch (room) {
        case SILENT_ROOM:
            [_SilentRoom setState:YES];
            break;
        case LIVING_ROOM:
            [_LivingRoom setState:YES];
            break;
        case JAZZ_ROOM:
            [_JazzClub setState:YES];
            break;
        case CONCERT_HALL:
            [_ConcertHall setState:YES];
            break;
    }

}
-(void)ConcertHallEffectAngle:(AngleEffect)angle
{
    [_Degree_30 setState:NO];
    [_Degree_60 setState:NO];
    [_Degree_90 setState:NO];
    [_Degree_120 setState:NO];
    [_Degree_150 setState:NO];
    [_Degree_180 setState:NO];
    switch (angle) {
        case DEGREES_30:
            [_Degree_30 setState:YES];
            break;
        case DEGREES_60:
            [_Degree_60 setState:YES];
            break;
        case DEGREES_90:
            [_Degree_90 setState:YES];
            break;
        case DEGREES_120:
            [_Degree_120 setState:YES];
            break;
        case DEGREES_150:
            [_Degree_150 setState:YES];
            break;
        case DEGREES_180:
            [_Degree_180 setState:YES];
            break;
    }
}

-(void)ConcertHallEffectState:(OptionStatus)status :(RoomSize)room :(AngleEffect)angle
{
    [self ConcertHallEffectState:status];
    [self ConcertHallEffectRoomSize:room];
    [self ConcertHallEffectAngle:angle];
}

-(void)EqualizerState:(OptionStatus)status;
{
    if (status == ON || status == INVALID_ON) {
        [_EquItem setState:YES];
        _EquItem.submenu = _equalizerMenu;
    } else {
        [_EquItem setState:NO];
        _EquItem.submenu = nil;

    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_EquItem setEnabled:NO];
    } else {
        [_EquItem setEnabled:YES];
    }
}


-(void)EqualizerPreset:(NSUInteger)preset
{
    [_vocalPreset setState:NO];
    [_popPreset setState:NO];
    [_clubPreset setState:NO];
    [_punchyPreset setState:NO];
    [_deepPreset setState:NO];
    [_crystalPreset setState:NO];
    [_userPreset setState:NO];
    switch (preset) {
        case 0:
            [_vocalPreset setState:YES];
            break;
        case 1:
            [_popPreset setState:YES];
            break;
        case 2:
            [_clubPreset setState:YES];
            break;
        case 3:
            [_punchyPreset setState:YES];
            break;
        case 4:
            [_deepPreset setState:YES];
            break;
        case 5:
            [_crystalPreset setState:YES];
            break;
        case 6:
            [_userPreset setState:YES];
            break;
        default:
            return;
    }
}


-(void)EqualizerState:(OptionStatus)status :(NSUInteger)preset;
{
    [self EqualizerState:status];
    [self EqualizerPreset:preset];
}

- (void)newBatteryStatus:(BOOL)charging :(NSInteger)level
{
    if (charging){
        [_batteryStatus setTitle:@"Zik Status: Charging"];
    } else {
        [_batteryStatus setTitle:[NSString stringWithFormat:@"Zik status: %ld%%", level]];
        if ( level <= LOW_BATTERY_LEVEL_WARNING ) {
            
        }
    }
}

-(void)toggleLouReedMode:(id)sender
{
    BOOL newState = [_LouReedModeItem state] != YES;
    if ([_zikInterface setLouReedModeState:newState]){
        [_LouReedModeItem setState:newState];
        [_zikInterface refreshZikStatus];
    }
}


-(void)toggleANCMode:(id)sender
{
    BOOL newState = [_ANCItem state] != YES;
    if ([_zikInterface setActiveNoiseCancellationState:newState]){
        [_ANCItem setState:newState];
    }
}

-(void)toggleConcertHallEffect:(id)sender
{
    BOOL newState = [_ConcertHallEffectItem state] != YES;
    if ([_zikInterface setConcertHallState:newState]){
        [_ConcertHallEffectItem setState:newState];
        if (newState) {
            _ConcertHallEffectItem.submenu = _concertHallMenu;
        } else {
            _ConcertHallEffectItem.submenu = nil;
        }
    }
}

-(void)toggleEqualizer:(id)sender
{
    BOOL newState = [_EquItem state] != YES;
    if ([_zikInterface setEqualizerState:newState]){
        [_EquItem setState:newState];
        if (newState) {
            _EquItem.submenu = _equalizerMenu;
        } else {
            _EquItem.submenu = nil;
        }
    }
}

- (void)configConcertHallRoomSize:(id)sender
{
    NSMenuItem *pressedItem = (NSMenuItem*)sender;
    if ([pressedItem state] == YES){
        return; //already selected
    }
    BOOL commandSent = false;
    if (pressedItem == _SilentRoom){
        commandSent = [_zikInterface setConcertHallRoomSize:SILENT_ROOM];
    } else if (pressedItem == _LivingRoom){
        commandSent = [_zikInterface setConcertHallRoomSize:LIVING_ROOM];
    } else if (pressedItem == _JazzClub){
        commandSent = [_zikInterface setConcertHallRoomSize:JAZZ_ROOM];
    } else if (pressedItem == _ConcertHall){
        commandSent = [_zikInterface setConcertHallRoomSize:CONCERT_HALL];
    } else {
        NSLog(@"Should not get here!\n");
        return;
    }
    if (commandSent) {
        [_SilentRoom setState:NO];
        [_LivingRoom setState:NO];
        [_JazzClub setState:NO];
        [_ConcertHall setState:NO];
        [pressedItem setState:YES];
    }
}

- (void)configConcertHallAngle:(id)sender
{
    NSMenuItem *pressedItem = (NSMenuItem*)sender;
    if ([pressedItem state] == YES){
        return; //already selected
    }
    BOOL commandSent = false;
    if (pressedItem == _Degree_30){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_30];
    } else if (pressedItem == _Degree_60){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_60];
    } else if (pressedItem == _Degree_90){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_90];
    } else if (pressedItem == _Degree_120){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_120];
    } else if (pressedItem == _Degree_150){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_150];
    } else if (pressedItem == _Degree_180){
        commandSent = [_zikInterface setConcertHallAngle:DEGREES_180];
    } else {
        NSLog(@"Should not get here!\n");
        return;
    }
    
    if (commandSent) {
        [_Degree_30 setState:NO];
        [_Degree_60 setState:NO];
        [_Degree_90 setState:NO];
        [_Degree_120 setState:NO];
        [_Degree_150 setState:NO];
        [_Degree_180 setState:NO];
        [pressedItem setState:YES];
    }
}


- (void)configEqualizerPreset:(id)sender
{
    NSMenuItem *pressedItem = (NSMenuItem*)sender;
    if ([pressedItem state] == YES){
        return; //already selected
    }
    BOOL commandSent = false;
    if (pressedItem == _vocalPreset){
        commandSent = [_zikInterface setEqualizerPreset:0];
    } else if (pressedItem == _popPreset){
        commandSent = [_zikInterface setEqualizerPreset:1];
    } else if (pressedItem == _clubPreset){
        commandSent = [_zikInterface setEqualizerPreset:2];
    } else if (pressedItem == _punchyPreset){
        commandSent = [_zikInterface setEqualizerPreset:3];
    } else if (pressedItem == _deepPreset){
        commandSent = [_zikInterface setEqualizerPreset:4];
    } else if (pressedItem == _crystalPreset){
        commandSent = [_zikInterface setEqualizerPreset:5];
    } else if (pressedItem == _userPreset){
        commandSent = [_zikInterface setEqualizerPreset:6];
    } else {
        NSLog(@"Should not get here!\n");
        return;
    }
    
    if (commandSent) {
        [_vocalPreset setState:NO];
        [_popPreset setState:NO];
        [_clubPreset setState:NO];
        [_punchyPreset setState:NO];
        [_deepPreset setState:NO];
        [_crystalPreset setState:NO];
        [_userPreset setState:NO];
        [pressedItem setState:YES];
    }

    
}

@end
