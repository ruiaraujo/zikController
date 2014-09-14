//
//  AppDelegate.h
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ARZikInterface.h"

@interface ARAppDelegate : NSObject <NSApplicationDelegate, ARBluetoothDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *connectStatus;
@property (strong, nonatomic) NSMenuItem *connectItem;
@property (strong, nonatomic) NSMenuItem *batteryStatus;
@property (strong, nonatomic) NSMenuItem *LouReedModeItem;
@property (strong, nonatomic) NSMenuItem *ANCItem;
@property (strong, nonatomic) NSMenuItem *EquItem;
@property (strong, nonatomic) NSMenuItem *ConcertHallEffectItem;
@property (strong, nonatomic) ARZikInterface *zikInterface;

@end

