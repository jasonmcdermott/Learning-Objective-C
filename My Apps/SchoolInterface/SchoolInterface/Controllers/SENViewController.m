//
//  SENGraphicsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENViewController.h"

@interface SENViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bluetoothButton;
@property (weak, nonatomic) IBOutlet UILabel *ibiLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic) NSInteger mode;
@property (nonatomic) NSNumber* num;
@property (strong, nonatomic) NSString *chosenMode;
@property (strong, nonatomic) IBOutlet GLKView *viewGL;

@end

@implementation SENViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupOpenGL];

    
    [self registerDefaultsFromSettingsBundle];
    self.SENUserDefaultsHelper = [[SENUserDefaultsHelper alloc] init];

    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    self.ibiLabel.text = self.chosenMode;

    self.rings = [[NSMutableArray alloc] init];
    for (int i=0;i<NUM_RINGS;i++) {
        SENRing *ring = [[SENRing alloc] init];
        [self.rings addObject:ring];
    }
    
    [self setSettingsValues];
    
    [self createViewControllers];
    [self setVisibility];
}

- (void)setupOpenGL
{
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    self.viewGL = [[GLKView alloc] initWithFrame:self.viewGL.frame context:context];
    self.viewGL.context = context;    // set the context
    self.viewGL.delegate = self;        // set the delegate ( to receive callbacks )
    [self.view addSubview:self.viewGL];    // add the GLKView to your view
    [self.viewGL addSubview:self.settingsButton];
    [self.viewGL addSubview:self.bluetoothButton];
    
    [EAGLContext setCurrentContext: context];    // set the current context
    self.viewGL.drawableMultisample = GLKViewDrawableMultisample4X;
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
    link.frameInterval = 1;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDisable(GL_DEPTH_TEST);
    
    
}

- (void)createViewControllers
{
    self.utilities = [[SENUtilities alloc] init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main_iPad" bundle:[NSBundle mainBundle]];
    self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
    [self.view addSubview:self.questionnaireViewController.view];
    self.questionnaireViewController.view.hidden = YES;
    
    // see if a unique app value has been set before.
    // if not, set a new unique app value. 
    if ([[self.utilities getStringForKey:@"appUniqueID"] isEqualToString:@""]) {
        self.appID = [self.utilities getUUID];
    } else {
        self.appID = [self.utilities getStringForKey:@"appUniqueID"];
    }
    self.questionnaireViewController.appID = self.appID;
    
    self.BLEDevice = [storyboard instantiateViewControllerWithIdentifier:@"Redbear"];
    [self.view addSubview:self.BLEDevice.view];
    self.BLEDevice.view.hidden = YES;
    self.BLEDevice.delegate = self;

}

- (void)drawFrame
{
    // notify that we want to update the context
    [self.viewGL setNeedsDisplay];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //    CFTimeInterval previousTimestamp = CFAbsoluteTimeGetCurrent();
    
    glClearColor(0, 0, 0, 0);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
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


- (void)renderRing:(NSInteger)shapeType withDiameter:(float)diameter withBlur:(float)blur withThickness:(float)thickness withNumSides:(int)numSides withColor:(UIColor *)col withOpacity:(float)opacity
{
    CGFloat Red, Green, Blue, Alpha;
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

- (void)drawGradient:(float)opaqueSize withTransparentSize:(float)transparentSize withOpacity:(float)opacity withBlur:(float)blur withNumSides:(int)numSides withColor:(UIColor *)color
{
    CGFloat Red, Green, Blue, Alpha;
    [color getRed:&Red green:&Green blue:&Blue alpha:&Alpha];
    
    int vertexArrayLength = ( numSides + 1 ) * 2;
    
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
    glDrawArrays( GL_TRIANGLE_STRIP, 0, vertexArrayLength);
}

- (void)setVisibility
{
    if ([self.chosenMode isEqualToString:@"Questionnaire"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.settingsButton.hidden = NO;
    } else {
        self.settingsButton.hidden = YES;
    }
    
    if ([self.chosenMode isEqualToString:@"Sensor"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.bluetoothButton.hidden = NO;
    } else {
        self.bluetoothButton.hidden = YES;
    }
    self.ibiLabel.text = _chosenMode;
}

#pragma mark -
#pragma mark Navigation Interface

- (void)setLabel:(NSString *)label
{
    self.ibiLabel.text = label;
}

- (IBAction)touchSettingsButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.questionnaireViewController.view.hidden = NO;
}


- (IBAction)clickBluetoothButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.BLEDevice.view.hidden = NO;
}

#pragma mark -
#pragma mark Settings Bundle

- (void)registerDefaultsFromSettingsBundle {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAutoUpdateSettingsForNotificaiton:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultsFromPlistNamed:@"Root"]];
}

- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSAssert(settingsBundle, @"Could not find Settings.bundle while loading defaults.");
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFullName]];
    NSAssert1(settings, @"Could not load plist '%@' while loading defaults.", plistFullName);
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSAssert1(preferences, @"Could not find preferences entry in plist '%@' while loading defaults.", plistFullName);
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value) {
            [defaults setObject:value forKey:key];
        }
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            NSAssert1(file, @"Unable to get child plist name from plist '%@'", plistFullName);
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }
    }
    
    return defaults;
}

-(void)viewWillActive:(id)sender{
    _chosenMode = [[SENUserDefaultsHelper sharedManager] appMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setVisibility];
    NSLog(@"num: %@",_chosenMode);
}

- (void)checkAutoUpdateSettingsForNotificaiton:(NSNotification *)aNotification
{
    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"checked auto update");
}

- (NSString*) getVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ build %@", version, build];
}

- (void)setSettingsValues
{
    
    //Get the bundle file
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];

    //Get the Preferences Array from the dictionary
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"Preference Items"];

    //Save default value of "version_number" in preference to NSUserDefaults
    for(NSDictionary * item in preferencesArray) {
        if([[item objectForKey:@"key"] isEqualToString:@"version_number"]) {
            NSString * defaultValue = [item objectForKey:@"DefaultValue"];
            [[NSUserDefaults standardUserDefaults] setObject:defaultValue forKey:@"version_number"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }

    //Save your real version number to NSUserDefaults
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"version_number"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"version %@",version);
}
@end
