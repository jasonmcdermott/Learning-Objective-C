

#import "MyTextField.h"
#import "AppDelegate.h"

@implementation MyTextField

-(void)awakeFromNib {
    [super awakeFromNib];
    self.allowsEditingTextAttributes = YES;
}

// p 575

- (BOOL) canPerformAction:(SEL)action withSender: (id) sender {
//    NSLog(@"%@", NSStringFromSelector(action));
//    return [super canPerformAction:action withSender:sender];
    if (action == @selector(expand:))
        return ([self.text length] == 2); // could be more intelligent here
    if (action == @selector(copy:))
        return [super canPerformAction:action withSender:sender];
    return NO;
}

- (void) expand: (id) sender {
    NSString* s = self.text;
    
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary* states = del.states;
    NSString* state = states[[s uppercaseString]];
    if (state)
        s = state;
    
    self.text = s;
}

// ????

- (void) copy: (id) sender {
    [super copy: sender];
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    NSString* s = pb.string;

    
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary* states = del.states;
    NSString* state = states[[s uppercaseString]];
    if (state)
        s = state;

    NSLog(@"putting %@ on the pasteboard", s);
    pb.string = s;
}



@end
