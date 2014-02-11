//
//  SampleListener.m
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import "SampleListener.h"


@implementation SampleListener

//- (id)initWithLabel:(UILabel *)s {
//    self = [super init];
//    if (self) {
////        label = s;
////        [label retain];
//    }
//    return self;
//}

- (void)receiveBangFromSource:(NSString *)source {
    NSLog(@"Listener %@: bang\n", source);
    NSLog(@"something");
}

- (void)receiveFloat:(float)val fromSource:(NSString *)source {
    NSLog(@"Listener %@: float %f\n", source, val);
//    NSString *s = [NSString stringWithFormat:@"%f", val];
//    [label setText:s];
}

- (void)receiveSymbol:(NSString *)s fromSource:(NSString *)source {
    NSLog(@"Listener %@: symbol %@\n", source, s);
}

- (void)receiveList:(NSArray *)v fromSource:(NSString *)source {
    NSLog(@"Listener %@: list %@\n", source, v);
}

- (void)receiveMessage:(NSString *)message withArguments:(NSArray *)arguments fromSource:(NSString *)source {
    NSLog(@"Listener %@: message %@,  %@\n", source, message, arguments);
}

@end
