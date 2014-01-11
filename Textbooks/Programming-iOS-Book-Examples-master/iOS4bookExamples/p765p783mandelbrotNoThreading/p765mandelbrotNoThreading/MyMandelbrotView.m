//  Mandelbrot drawing code based on https://github.com/ddeville/Mandelbrot-set-on-iPhone 

#import "MyMandelbrotView.h"

// best to run on device, because we want a slow processor in order to see the delay
// you can increase the size of MANDELBROT_STEPS to make even more of a delay
// but on my device, there's plenty of delay as is!

#define MANDELBROT_STEPS	200

@implementation MyMandelbrotView

// jumping-off point: draw the Mandelbrot set
- (void) drawThatPuppy {
    [self makeBitmapContext: self.bounds.size];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self drawAtCenter: center zoom: 1];
    [self setNeedsDisplay];
}

// create (and memory manage) instance variable
- (void) makeBitmapContext:(CGSize)size {
    if (self->bitmapContext)
        CGContextRelease(self->bitmapContext);
	int bitmapBytesPerRow = (size.width * 4);
	bitmapBytesPerRow += (16 - bitmapBytesPerRow%16)%16;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = NULL;
	context = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
    self->bitmapContext = context;
}

// draw pixels of self->bitmapContext

BOOL isInMandelbrotSet(float re, float im)
{
	float x = 0;	float nx;
	float y = 0;	float ny;
	bool fl = TRUE;
	for(int i = 0; i < MANDELBROT_STEPS; i++)
	{
		nx = x*x - y*y + re;
		ny = 2*x*y + im;
		if((nx*nx + ny*ny) > 4)
		{
			fl = FALSE;
			break;
		}
		x = nx;
		y = ny;
	}
	return fl;
}

- (void)drawAtCenter:(CGPoint)center zoom:(CGFloat)zoom
{
	CGContextSetAllowsAntialiasing(bitmapContext, FALSE);
    CGContextSetRGBFillColor(bitmapContext, 0.0f, 0.0f, 0.0f, 1.0f);
	
	CGFloat re;
	CGFloat im;
	
    int maxi = self.bounds.size.width;
    int maxj = self.bounds.size.height;
	for (int i = 0; i < maxi; i++)
	{
		for (int j = 0; j < maxj; j++)
		{
			re = (((CGFloat)i - 1.33f * center.x)/160);	
			im = (((CGFloat)j - 1.00f * center.y)/160);	
			
			re /= zoom;
			im /= zoom;
			
			if (isInMandelbrotSet(re, im))
			{
				CGContextFillRect (bitmapContext, CGRectMake(i, j, 1.0f, 1.0f));
			}
		}
	}
}

// turn pixels of self->bitmapContext into CGImage, draw into ourselves
- (void) drawRect:(CGRect)rect {
    static BOOL which = NO;
    if (self->bitmapContext) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGImageRef im = CGBitmapContextCreateImage(self->bitmapContext);
        CGContextDrawImage(context, self.bounds, im);
        CGImageRelease(im);
        // this will make it more obvious when we are redrawn
        self.backgroundColor = (which = !which) ? [UIColor greenColor] : [UIColor redColor];
    }
}

// final memory managment
- (void) dealloc {
    if (self->bitmapContext)
        CGContextRelease(bitmapContext);
    [super dealloc];
}


@end
