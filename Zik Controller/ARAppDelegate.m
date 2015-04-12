//
//  AppDelegate.m
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import "ARPreferences.h"

#define LOW_BATTERY_LEVEL_WARNING   5

@interface ARAppDelegate ()
@property (strong, nonatomic) ARZikInterface *zikInterface;
@property BOOL lowWarningBattery;


@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *connectStatus;
@property (strong, nonatomic) NSMenuItem *connectItem;
@property (strong, nonatomic) NSMenuItem *batteryStatus;
@property (strong, nonatomic) NSMenuItem *LouReedModeItem;
@property (strong, nonatomic) NSMenuItem *ANCItem;
@property (strong, nonatomic) NSMenuItem *EquItem;
@property (strong, nonatomic) NSMenuItem *ConcertHallEffectItem;
@property (strong, nonatomic) NSMenuItem *preferences;

//Concert hall room types
@property (strong, nonatomic) NSMenuItem *SilentRoom;
@property (strong, nonatomic) NSMenuItem *LivingRoom;
@property (strong, nonatomic) NSMenuItem *JazzClub;
@property (strong, nonatomic) NSMenuItem *ConcertHall;

//Concert hall room angle
@property (strong, nonatomic) NSMenu *concertHallMenu;
@property (strong, nonatomic) NSMenuItem *Degree_180;
@property (strong, nonatomic) NSMenuItem *Degree_150;
@property (strong, nonatomic) NSMenuItem *Degree_120;
@property (strong, nonatomic) NSMenuItem *Degree_90;
@property (strong, nonatomic) NSMenuItem *Degree_60;
@property (strong, nonatomic) NSMenuItem *Degree_30;


//Equalizer preset
@property (strong, nonatomic) NSMenu *equalizerMenu;
@property (strong, nonatomic) NSMenuItem *vocalPreset;
@property (strong, nonatomic) NSMenuItem *popPreset;
@property (strong, nonatomic) NSMenuItem *clubPreset;
@property (strong, nonatomic) NSMenuItem *punchyPreset;
@property (strong, nonatomic) NSMenuItem *deepPreset;
@property (strong, nonatomic) NSMenuItem *crystalPreset;
@property (strong, nonatomic) NSMenuItem *userPreset;
@end

@implementation ARAppDelegate
@synthesize lowWarningBattery;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _zikInterface = [ARZikInterface instance];
    [_zikInterface addObserver:self];
    lowWarningBattery = false;
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
    _statusItem.toolTip = NSLocalizedString(@"Zik Controller: Disconnected", nil);
    [self setupMenu];
}

- (void)setupMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    [menu setAutoenablesItems:NO];
    _connectStatus = [menu addItemWithTitle:NSLocalizedString(@"Connection: Disconnected", nil) action:nil keyEquivalent:@""];
    _connectItem = [menu addItemWithTitle:NSLocalizedString(@"Connect", nil) action:@selector(connect:) keyEquivalent:@""];
    [_connectStatus setEnabled:NO];
    [menu addItem:[NSMenuItem separatorItem]];
    _batteryStatus = [menu addItemWithTitle:NSLocalizedString(@"Zik Status", nil) action:nil keyEquivalent:@""];
    [_batteryStatus setEnabled:NO];
    _LouReedModeItem = [menu addItemWithTitle:NSLocalizedString(@"Tuned by Lou Reed", nil) action:@selector(toggleLouReedMode:) keyEquivalent:@""];
    _ANCItem = [menu addItemWithTitle:NSLocalizedString(@"Noise Cancellation", nil) action:@selector(toggleANCMode:) keyEquivalent:@""];
    _ConcertHallEffectItem =[menu addItemWithTitle:NSLocalizedString(@"Concert Hall Effect", nil) action:@selector(toggleConcertHallEffect:) keyEquivalent:@""];
    _concertHallMenu = [[NSMenu alloc] init];
    [[_concertHallMenu addItemWithTitle:NSLocalizedString(@"Room size", nil) action:nil keyEquivalent:@""] setEnabled:NO];
    _SilentRoom = [_concertHallMenu addItemWithTitle:NSLocalizedString(@"Silent Room", nil) action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _LivingRoom = [_concertHallMenu addItemWithTitle:NSLocalizedString(@"Living Room", nil) action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _JazzClub = [_concertHallMenu addItemWithTitle:NSLocalizedString(@"Jazz Club", nil) action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    _ConcertHall = [_concertHallMenu addItemWithTitle:NSLocalizedString(@"Concert Hall", nil) action:@selector(configConcertHallRoomSize:) keyEquivalent:@""];
    [_concertHallMenu addItem:[NSMenuItem separatorItem]];
    [[_concertHallMenu addItemWithTitle:NSLocalizedString(@"Angle", nil) action:nil keyEquivalent:@""] setEnabled:NO];
    _Degree_30 = [_concertHallMenu addItemWithTitle:@"30" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_60 = [_concertHallMenu addItemWithTitle:@"60" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_90 = [_concertHallMenu addItemWithTitle:@"90" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_120 = [_concertHallMenu addItemWithTitle:@"120" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_150 = [_concertHallMenu addItemWithTitle:@"150" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _Degree_180 = [_concertHallMenu addItemWithTitle:@"180" action:@selector(configConcertHallAngle:) keyEquivalent:@""];
    _EquItem =[menu addItemWithTitle:NSLocalizedString(@"Equalizer", nil) action:@selector(toggleEqualizer:) keyEquivalent:@""];
    _equalizerMenu = [[NSMenu alloc] init];
    [[_equalizerMenu addItemWithTitle:NSLocalizedString(@"Presets", nil) action:nil keyEquivalent:@""] setEnabled:NO];
    _vocalPreset = [_equalizerMenu addItemWithTitle:@"Vocal" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _popPreset = [_equalizerMenu addItemWithTitle:@"Pop" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _clubPreset = [_equalizerMenu addItemWithTitle:@"Club" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _punchyPreset = [_equalizerMenu addItemWithTitle:@"Punchy" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _deepPreset = [_equalizerMenu addItemWithTitle:@"Deep" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _crystalPreset = [_equalizerMenu addItemWithTitle:@"Crystal" action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    _userPreset = [_equalizerMenu addItemWithTitle:NSLocalizedString(@"User", nil) action:@selector(configEqualizerPreset:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    _preferences = [menu addItemWithTitle:NSLocalizedString(@"Preferences..", nil) action:@selector(openPreferences:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Quit Zik Controller", nil) action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
    if ([_zikInterface searchForZikInConnectedDevices]) {
        [_connectStatus setTitle:NSLocalizedString(@"Connection: Connecting...", nil)];
    } else {
        [self enableZikUI:FALSE];
    }
    [_zikInterface registerForNewDevices];

}

-(void)openPreferences:(id)sender{
    if ( preferenceWindow == nil){
        preferenceWindow  = [[ARPreferences alloc] initWithWindowNibName:@"ARPreferences"];
        [preferenceWindow setShouldCascadeWindows: NO];
    }
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [preferenceWindow showWindow:self];
    [[preferenceWindow window] makeKeyAndOrderFront:self];
    
}

-(void)enableZikUI:(BOOL)enable
{
    [_LouReedModeItem setEnabled:enable];
    [_ANCItem setEnabled:enable];
    [_EquItem setEnabled:enable];
    [_ConcertHallEffectItem setEnabled:enable];
    [_ConcertHallEffectItem setEnabled:enable];
    [_preferences setEnabled:enable];
}


- (void)connect:(id)sender
{
    [_connectItem setTitle:NSLocalizedString(@"Connecting...", nil)];
    [_connectItem setEnabled:NO];
    if (![self.zikInterface connectToZik]) {
        [_connectItem setTitle:NSLocalizedString(@"Connect", nil)];
        [_connectItem setEnabled:YES];
    } else {
        [_connectStatus setTitle:NSLocalizedString(@"Connection: Connecting...", nil)];
    }
}

- (void)disconnect:(id)sender
{
    [_connectStatus setTitle:NSLocalizedString(@"Connection: Disconnected", nil)];
    _statusItem.toolTip = NSLocalizedString(@"Zik Controller: Disconnected", nil);
    [_batteryStatus setTitle:NSLocalizedString(@"Zik Status", nil)];
    [self.zikInterface disconnectFromZik];
    [_connectItem setTitle:NSLocalizedString(@"Connect", nil)];
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
        [self enableZikUI:TRUE];
        [_connectStatus setTitle:NSLocalizedString(@"Connection: Connected", nil)];
        _statusItem.toolTip = NSLocalizedString(@"Zik Controller: Connected", nil);
        [_connectItem setTitle:NSLocalizedString(@"Disconnect", nil)];
        [_connectItem setAction:@selector(disconnect:)];
        [_zikInterface refreshZikStatus];
        notification.informativeText = NSLocalizedString(@"Parrot Zik connected.", nil);
    } else {
        [self enableZikUI:false];
        lowWarningBattery = false;
        [_connectStatus setTitle:NSLocalizedString(@"Connection: Disconnected", nil)];
        _statusItem.toolTip = NSLocalizedString(@"Zik Controller: Disconnected", nil);
        [_connectItem setTitle:NSLocalizedString(@"Connect", nil)];
        [_connectItem setAction:@selector(connect:)];
        [_batteryStatus setTitle:NSLocalizedString(@"Zik Status", nil)];
        notification.informativeText = NSLocalizedString(@"Parrot Zik disconnected.", nil);
    }
    notification.title = NSLocalizedString(@"Zik Controller", nil);
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

-(void)ConcertHallEffectState:(OptionStatus)status room:(RoomSize)room angle:(AngleEffect)angle
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


-(void)EqualizerState:(OptionStatus)status preset:(NSUInteger)preset;
{
    [self EqualizerState:status];
    [self EqualizerPreset:preset];
}

- (void)newBatteryStatus:(BOOL)charging level:(NSNumber*)level
{
    if (charging){
        [_batteryStatus setTitle:NSLocalizedString(@"Zik Status: Charging", nil)];
    } else {
        if ( level == nil ){
            [_batteryStatus setTitle:NSLocalizedString(@"Zik Status: In use", nil)];
        } else{
            [_batteryStatus setTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"Zik status: %ld%%", nil), [level integerValue]]];
            if ( [level integerValue] <= LOW_BATTERY_LEVEL_WARNING && !lowWarningBattery) {
                lowWarningBattery = true;
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = NSLocalizedString(@"Zik Controller", nil);
                notification.informativeText = NSLocalizedString(@"Low battery!!! Charge your Zik!", nil);
                notification.soundName = NSUserNotificationDefaultSoundName;
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
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
