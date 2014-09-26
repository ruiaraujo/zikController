//
//  ARPreferences.h
//  Zik Controller
//
//  Created by Rui Araújo on 19/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ARZikInterface.h"

@class ARZikInterface;

@interface ARPreferences : NSWindowController<ARZikStatusObserver>

@property (weak) IBOutlet NSTextField *zikName;
@property (weak) IBOutlet NSTextField *firmwareVersion;
@property (weak) IBOutlet NSButton *ANCDuringCall;
@property (weak) IBOutlet NSButton *autoConnection;
@property (weak) IBOutlet NSButton *autoPause;
@property (weak) IBOutlet NSPopUpButton *autoPowerOff;
@property (weak) IBOutlet NSButton *launchAtLogin;


@property (strong, nonatomic) ARZikInterface *zikInterface;


- (IBAction)actionOnNameTextField:(id)sender;
- (IBAction)autoPowerCheckboxHandler:(id)sender;

@end
