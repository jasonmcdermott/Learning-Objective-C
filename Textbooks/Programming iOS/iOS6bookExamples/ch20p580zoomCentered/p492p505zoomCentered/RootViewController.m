

#import "RootViewController.h"
#import "MyScrollView.h"

@interface RootViewController () <UIScrollViewDelegate>
@end

@implementation RootViewController {
    BOOL _oldBounces;
}



-(void)loadView {
    UIScrollView* sv = [[MyScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = sv;
    sv.backgroundColor = [UIColor blackColor];
    
    UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bird.jpg"]];
    iv.tag = 999;
    [sv addSubview:iv];
    sv.contentSize = iv.bounds.size;
    
    UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                        action:@selector(tapped:)];
    t.numberOfTapsRequired = 2;
    [iv addGestureRecognizer:t];
    iv.userInteractionEnabled = YES;
    
    // feel free to play with these numbers
    sv.maximumZoomScale = 1.5;
    sv.minimumZoomScale = 0.5;
    
    sv.delegate = self;
    
    CGPoint pt = CGPointMake((iv.bounds.size.width - sv.bounds.size.width)/2.0,0);
    [sv setContentOffset:pt animated:NO];
    
    sv.bouncesZoom = NO; // try it with YES, but I like this better
    
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView
                           withView:(UIView *)view {
    self->_oldBounces = scrollView.bounces;
    scrollView.bounces = NO; // again, you can comment this out, but I like the result better
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView
                        withView:(UIView *)view atScale:(float)scale {
    scrollView.bounces = self->_oldBounces;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:999];
}

// the picture is also zoomable by double-tapping

- (void) tapped: (UIGestureRecognizer*) tap {
    UIView* v = tap.view;
    UIScrollView* sv = (UIScrollView*)v.superview;
    if (sv.zoomScale < 1) {
        [sv setZoomScale:1 animated:YES];
        CGPoint pt = CGPointMake((v.bounds.size.width - sv.bounds.size.width)/2.0,0);
        [sv setContentOffset:pt animated:NO];
    }
    else if (sv.zoomScale < sv.maximumZoomScale)
        [sv setZoomScale:sv.maximumZoomScale animated:YES];
    else
        [sv setZoomScale:sv.minimumZoomScale animated:YES];
}

@end
