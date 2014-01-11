

#import "Dog.h"

// example of anonymous category techniques with property declarations
// not identical to what's in the book, but it makes a nice follow-on from previous examples

// name is read-only as far as other classes are concerned, but read-write for us
// we can set name thru property, but other classes can't

// zork is a private property; we can get and set it, other classes can't

@interface Dog ()
@property (nonatomic, readwrite, copy) NSString* name;
@property (nonatomic, copy) NSString* zork;
@end

@implementation Dog

// autosynthesis, our ivars are called _name and _zork

- (id) initWithName: (NSString*) s { 
    self = [super init]; 
    if (self) {
        self->_name = [s copy];
    }
    return self;
}

- (id) init {
    NSAssert(NO, @"Making a nameless dog is forbidden.");
    return nil;
}

- (void) dummy {
    // we can get and set both name and zork
    // better logging
    self.name = @"Zampabalooie";
    NSLog(@"Dog can set its own name, name is now %@", self.name);
    self.zork = @"test";
    NSLog(@"Dog can set and get private zork property, zork is now %@", self.zork);
}


@end
