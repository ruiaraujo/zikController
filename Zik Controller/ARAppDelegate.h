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



@end

