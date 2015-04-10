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



@property (strong, nonatomic) ARZikInterface *zikInterface;


- (IBAction)actionOnNameTextField:(id)sender;
- (IBAction)autoPowerCheckboxHandler:(id)sender;

@end
