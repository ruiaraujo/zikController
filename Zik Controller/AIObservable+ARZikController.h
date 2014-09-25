//
//  AIObservable+ARZikController.h
//  Zik Controller
//
//  Created by Rui Araújo on 24/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <AIObservable.h>

@interface AIObservable (ARZikController)


- (void)notifyObservers:(Protocol*)targetProtocol selector:(SEL)selector argCount:(NSUInteger)count arguments:(void*)arguments, ...;


@end
