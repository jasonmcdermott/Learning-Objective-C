//
//  SENViewController.h
//  openGLExperiment
//
//  Created by Jason McDermott on 27/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SENRing.h"

@interface SENViewController : UIViewController <GLKViewDelegate>
{
    float diam;
}

@property (strong, nonatomic) NSMutableArray *rings;
//@property (strong, nonatomic) GLKView *viewGL;
@end
