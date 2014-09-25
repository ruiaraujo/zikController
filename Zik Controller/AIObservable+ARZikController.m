//
//  AIObservable+ARZikController.m
//  Zik Controller
//
//  Created by Rui Araújo on 24/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "AIObservable+ARZikController.h"
#import <NSInvocation+AIConstructors.h>

@implementation AIObservable (ARZikController)

- (void)notifyObservers:(Protocol*)targetProtocol selector:(SEL)selector argCount:(NSUInteger)count arguments:(void*)arguments, ...
{
    if ( targetProtocol == nil || selector == nil ) {
        return;
    }
    NSInvocation* invocation = [NSInvocation invocationWithProtocol:targetProtocol
                                                           selector:selector];
    if ( count > 0) {
        va_list args;
        va_start(args, arguments);
        [invocation setArgument:arguments atIndex:2];
        for (int i = 1; i < count; ++i){
            void * ptr = va_arg(args, void*);
            [invocation setArgument:ptr atIndex:i+2];
        }
        va_end(args);
    }
    [self notifyObservers:invocation];
}

@end
