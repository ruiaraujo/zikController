//
//  ARPreferences.m
//  Zik Controller
//
//  Created by Rui Araújo on 19/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARPreferences.h"

@interface ARPreferences ()
@property (retain, nonatomic) NSArray* autoPowerValues;
@property (retain, nonatomic) NSString* lastSavedName;

@property (weak) IBOutlet NSTextField *zikName;
@property (weak) IBOutlet NSTextField *firmwareVersion;
@property (weak) IBOutlet NSButton *ANCDuringCall;
@property (weak) IBOutlet NSButton *autoConnection;
@property (weak) IBOutlet NSButton *autoPause;
@property (weak) IBOutlet NSPopUpButton *autoPowerOff;
@end

@implementation ARPreferences

- (void)windowDidLoad {
    [super windowDidLoad];
    _zikInterface = [ARZikInterface instance];
    [[self window] center];
    [[self window] setReleasedWhenClosed:NO];
    [_ANCDuringCall setTarget:self];
    [_ANCDuringCall setAction:@selector(handleCheckBoxs:)];
    [_autoConnection setTarget:self];
    [_autoConnection setAction:@selector(handleCheckBoxs:)];
    [_autoPause setTarget:self];
    [_autoPause setAction:@selector(handleCheckBoxs:)];
    [_zikInterface addObserver:self];
    if ([_zikInterface connectionStatus] == CONNECTED){
        [_zikInterface refreshZikSystemPreferences];
    } else {
        [self enableZikUI:FALSE];
    }
}


-(void)enableZikUI:(BOOL)enable
{
    if ( !enable ){
        [_firmwareVersion setStringValue:NSLocalizedString(@"Firmware Version: NA", nil)];
    }
    [_ANCDuringCall setEnabled:enable];
    [_autoPowerOff setEnabled:enable];
    [_autoConnection setEnabled:enable];
    [_autoPause setEnabled:enable];
    [_zikName setEnabled:enable];
}

- (void)newZikConnectionStatus:(IOReturn)status
{
    if ( status == kIOReturnSuccess){
        [self enableZikUI:TRUE];
        [_zikInterface refreshZikSystemPreferences];
    } else {
        [self enableZikUI:FALSE];
    }
}

-(void)handleCheckBoxs:(id)sender
{
    if (![sender isKindOfClass:[NSButton class]])
        return;
    NSButton *checkbox = sender;
    bool status = [checkbox state], comandReturn;
    if ( checkbox == _ANCDuringCall ){
        comandReturn = [_zikInterface setANCPhoneInCall:status];
    } else if ( checkbox == _autoConnection ){
        comandReturn = [_zikInterface setAutoConnection:status];
    } else if ( checkbox == _autoPause ){
        comandReturn = [_zikInterface setHeadDetection:status];
    } else {
        //Should not get here
        NSLog(@"How did you get here! BUG!!");
        return;
    }
}

-(void)ANCPhoneCallState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_ANCDuringCall setState:YES];
    } else {
        [_ANCDuringCall setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_ANCDuringCall setEnabled:NO];
    } else {
        [_ANCDuringCall setEnabled:YES];
    }
}

-(void)AutoConnectionState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_autoConnection setState:YES];
    } else {
        [_autoConnection setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_autoConnection setEnabled:NO];
    } else {
        [_autoConnection setEnabled:YES];
    }
}

-(void)HeadDetectionState:(OptionStatus)status
{
    if (status == ON || status == INVALID_ON) {
        [_autoPause setState:YES];
    } else {
        [_autoPause setState:NO];
    }
    if (status == INVALID_OFF || status == INVALID_ON) {
        [_autoPause setEnabled:NO];
    } else {
        [_autoPause setEnabled:YES];
    }
}

-(void)AutoPowerOffValue:(NSUInteger)value
{
    if ( [_autoPowerOff numberOfItems] == 0 )
        return; //Ignore for now
    if (value > 0) {
        [_autoPowerOff selectItemWithTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"%ld minutes", nil), value]];
    } else {
        [_autoPowerOff selectItemAtIndex:0];
    }
}
-(void)AutoPowerOffValuesList:(NSArray*)list
{
    NSInteger selectedIndex = [_autoPowerOff indexOfSelectedItem];
    _autoPowerValues = list;
    [_autoPowerOff removeAllItems];
    for (id object in list) {
        NSNumber* value = object;
        if ( [value integerValue] == 0 ){
            [_autoPowerOff addItemWithTitle:NSLocalizedString(@"Disabled", nil)];
        } else {
            [_autoPowerOff addItemWithTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"%ld minutes", nil), [value integerValue]] ];
        }
    }
    if ( selectedIndex < [list count] && selectedIndex != -1 ){
        [_autoPowerOff selectItemAtIndex:selectedIndex];
    }
}

- (IBAction)autoPowerCheckboxHandler:(id)sender
{
    NSLog(@"%@\n", [_autoPowerOff titleOfSelectedItem]);
    if ( [_autoPowerOff indexOfSelectedItem] == 0 ) {
        [_zikInterface setAutoPowerOff:[_autoPowerOff indexOfSelectedItem]];
    } else {
        [_zikInterface setAutoPowerOff:[[_autoPowerOff titleOfSelectedItem] integerValue]];
    }
}

- (IBAction)actionOnNameTextField:(id)sender
{
    NSLog(@"%@\n", [_zikName stringValue]);
    NSString* newName = [_zikName stringValue];
    if ( [newName length] == 0 ) {
        [_zikName setStringValue:_lastSavedName];
        return;
    }
    [_zikInterface setFriendlyName:newName];
    [_zikInterface getFriendlyName];
}

-(void)FriendlyName:(NSString*)name
{
    _lastSavedName = name;
    [_zikName setStringValue:name];
}

-(void)FirmwareVersion:(NSString*)version
{
    [_firmwareVersion setStringValue:[NSString localizedStringWithFormat:NSLocalizedString(@"Firmware Version: %@", nil), version]];
}
@end
