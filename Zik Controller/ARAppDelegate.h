//
//  AppDelegate.h
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ARZikInterface.h"

@class ARPreferences;

@interface ARAppDelegate : NSObject <NSApplicationDelegate, ARZikStatusObserver, NSUserNotificationCenterDelegate> {
    ARPreferences *preferenceWindow;
}

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *connectStatus;
@property (strong, nonatomic) NSMenuItem *connectItem;
@property (strong, nonatomic) NSMenuItem *batteryStatus;
@property (strong, nonatomic) NSMenuItem *LouReedModeItem;
@property (strong, nonatomic) NSMenuItem *ANCItem;
@property (strong, nonatomic) NSMenuItem *EquItem;
@property (strong, nonatomic) NSMenuItem *ConcertHallEffectItem;
@property (strong, nonatomic) NSMenuItem *launchAtLogin;

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

