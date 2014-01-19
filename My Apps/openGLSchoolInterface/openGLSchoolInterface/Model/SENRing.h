//
//  SENRing.h
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct Point3D {
    CGFloat x, y, z;
} Point3D;

@interface SENRing : NSObject

@property (nonatomic) struct Point3D *position;

@property (nonatomic) NSInteger posX;
@property (nonatomic) NSInteger posY;
@property (nonatomic) NSInteger posZ;

@property (nonatomic) NSInteger diameter;
@property (nonatomic) NSInteger blur;
@property (nonatomic) NSInteger thickness;

@property (nonatomic) BOOL active;
@property (nonatomic) NSInteger ID;

@property (nonatomic) NSInteger Red;
@property (nonatomic) NSInteger Green;
@property (nonatomic) NSInteger Blue;
@property (nonatomic) NSInteger Alpha;

@property (strong, nonatomic) UIColor *color;

@property (nonatomic) NSInteger ringVertexCount;

@property (nonatomic) NSInteger numSides;
@property (strong, nonatomic) NSString *shapeType;

@end
