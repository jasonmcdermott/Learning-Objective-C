//
//  SENViewController.m
//  openGLExperiment
//
//  Created by Jason McDermott on 27/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENViewController.h"
#define NUM_RINGS 18
#define PI 3.141592654

@interface SENViewController ()
@property (strong, nonatomic) IBOutlet GLKView *viewGL;

@end

@implementation SENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    self.viewGL = [[GLKView alloc] initWithFrame:self.viewGL.frame context:context];
    
    self.rings = [[NSMutableArray alloc] init];
    
    for (int i=0;i<NUM_RINGS;i++) {
        SENRing *ring = [[SENRing alloc] init];
        [self.rings addObject:ring];
    }
    
    self.viewGL.context = context;    // set the context
    self.viewGL.delegate = self;        // set the delegate ( to receive callbacks )

    [self.view addSubview:self.viewGL];    // add the GLKView to your view
    [EAGLContext setCurrentContext: context];    // set the current context
    
    self.viewGL.drawableMultisample = GLKViewDrawableMultisample4X;

    // the following will start the timer to call the rendering
    // drawFrame is the render trigger function

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
    
    link.frameInterval = 1;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDisable(GL_DEPTH_TEST);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawFrame
{
    // notify that we want to update the context
    [self.viewGL setNeedsDisplay];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    CFTimeInterval previousTimestamp = CFAbsoluteTimeGetCurrent();
    
    glClearColor(0, 0, 0, 0.1f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    for (int i=0;i<NUM_RINGS;i++) {
        glPushMatrix();
        SENRing *ring = [self.rings objectAtIndex:i];
        [ring updateVals];
        glTranslatef(ring.x,ring.y,0);
        [self renderRing:ring.shapeType withDiameter:ring.diameter withBlur:ring.blur withThickness:ring.thickness withNumSides:ring.numSides withColor:ring.color withOpacity:ring.opacity];
        glPopMatrix();
    }
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);

//    CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - previousTimestamp;
//    NSLog(@"Frame duration: %f ms", frameDuration * 1000.0);
}


- (void)renderRing:(NSInteger)shapeType withDiameter:(float)diameter withBlur:(float)blur withThickness:(float)thickness withNumSides:(NSInteger)numSides withColor:(UIColor *)col withOpacity:(float)opacity
{
    float Red, Green, Blue, Alpha;
    [col getRed:&Red green:&Green blue:&Blue alpha:&Alpha];
    
    if (shapeType == 1) {
        [self drawGradient:diameter-blur withTransparentSize:0 withOpacity:Alpha withBlur:0 withNumSides:numSides withColor:col];
        [self drawGradient:diameter withTransparentSize:diameter-blur withOpacity:opacity withBlur:0 withNumSides:numSides withColor:col];
    } else if (shapeType == 2) {
        [self drawGradient:diameter+thickness-blur withTransparentSize:diameter-thickness+blur withOpacity:Alpha withBlur:0 withNumSides:numSides withColor:col];
        [self drawGradient:diameter+thickness withTransparentSize:diameter+thickness-blur withOpacity:0 withBlur:0 withNumSides:numSides withColor:col];
        [self drawGradient:diameter-thickness withTransparentSize:diameter-thickness+blur withOpacity:0 withBlur:0 withNumSides:numSides withColor:col];
    } else if (shapeType == 3) {
        [self drawGradient:diameter-thickness withTransparentSize:diameter+thickness withOpacity:0 withBlur:0 withNumSides:numSides withColor:col];
        [self drawGradient:diameter+thickness+thickness*0.07 withTransparentSize:diameter+thickness withOpacity:0 withBlur:0 withNumSides:numSides withColor:col];
    }
}

- (void)drawGradient:(float)opaqueSize withTransparentSize:(float)transparentSize withOpacity:(float)opacity withBlur:(float)blur withNumSides:(NSInteger)numSides withColor:(UIColor *)color
{
    float Red, Green, Blue, Alpha;
    [color getRed:&Red green:&Green blue:&Blue alpha:&Alpha];
    
    GLfloat ver_coords[(numSides+1) * 4];
    GLfloat ver_cols[(numSides+1) * 8];
    
    float angle;
    float angleSize =  2 * PI / numSides;
    float middleRadius;
    
    if (opaqueSize < transparentSize) {
        middleRadius = opaqueSize - ((transparentSize-opaqueSize)+blur);
    } else {
        middleRadius = opaqueSize - ((transparentSize-opaqueSize)+blur);
    }
    
    middleRadius = (opaqueSize + transparentSize)/2;
    
    for (int i=0; i< (1 + numSides); i++) {
        angle = i* angleSize;
        ver_coords[i*4+0] = (opaqueSize * cos(angle));
        ver_coords[i*4+1] = (opaqueSize * sin(angle));
        ver_cols[i*8+0] = Red;
        ver_cols[i*8+1] = Green;
        ver_cols[i*8+2] = Blue;
        ver_cols[i*8+3] = opacity;
        ver_coords[i*4+2] = (transparentSize * cos(angle));
        ver_coords[i*4+3] = (transparentSize * sin(angle));
        ver_cols[i*8+4] = Red;
        ver_cols[i*8+5] = Green;
        ver_cols[i*8+6] = Blue;
        ver_cols[i*8+7] = Alpha;
    }
    
    glVertexPointer( 2, GL_FLOAT, 0, ver_coords);
    glColorPointer(4, GL_FLOAT, 0, ver_cols);
    glDrawArrays( GL_TRIANGLE_STRIP, 0, ( numSides + 1 ) * 2 );
}

@end
