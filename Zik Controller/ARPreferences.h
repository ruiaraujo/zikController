//
//  ARPreferences.h
//  Zik Controller
//
//  Created by Rui Araújo on 19/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ARPreferences : NSWindowController

@property (weak) IBOutlet NSTextField *zikName;
@property (weak) IBOutlet NSTextField *firmwareVersion;
@property (weak) IBOutlet NSButton *ANCDuringCall;
@property (weak) IBOutlet NSButton *autoConnection;
@property (weak) IBOutlet NSButton *autoPowerOff;
@property (weak) IBOutlet NSButton *autoPause;
@property (weak) IBOutlet NSButton *lauchAtLogin;


@end
