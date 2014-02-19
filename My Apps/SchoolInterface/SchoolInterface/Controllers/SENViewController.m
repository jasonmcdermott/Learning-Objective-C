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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self setSettingsValues];
    [self createViewControllers];
    [self setVisibility];
    [self setupPD];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPulse:) name:BT_NOTIFICATION_PULSE object:[self pulseTracker]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHRDataReceived:) name:BT_NOTIFICATION_HR_DATA object:[self pulseTracker]];
}

#pragma mark - LibPd

- (void)setupPD
{
    self.audioController = [[PdAudioController alloc] init];
	PdAudioStatus status = [self.audioController configurePlaybackWithSampleRate:44100
																  numberChannels:2
																	inputEnabled:NO
																   mixingEnabled:NO];
    if (status == PdAudioError) {
		NSLog(@"Error! Could not configure PdAudioController");
	} else if (status == PdAudioPropertyChanged) {
		NSLog(@"Warning: some of the audio parameters were not accceptable.");
	} else {
		NSLog(@"Audio Configuration successful.");
	}
    // log actual settings
	[self.audioController print];
    self.audioController.active = YES;
    [PdBase setDelegate:self];
    //    self.dispatcher = (PdDispatcher *)[PdBase delegate];
    //    SampleListener *goodbyeListener = [[SampleListener alloc] init];
    //    [self.dispatcher addListener:goodbyeListener forSource:@"goodbye"];
    
//    [PdBase subscribe:@"goodbye"];
//    [PdBase subscribe:@"load-meter"];
//    [PdBase openFile:@"test.pd" path:[[NSBundle mainBundle] bundlePath]];
    [PdBase openFile:@"brighthearts-pd-master.pd" path:[[NSBundle mainBundle] bundlePath]];

    //    [PdBase sendBangToReceiver:@"hello"];    // we know this works.
}

- (void)receiveFloat:(float)received fromSource:(NSString *)source {
	if ([source isEqualToString:@"load-meter"]) {
        NSLog(@"%f",received);
	}
}

- (void)receiveBangFromSource:(NSString *)source
{
    if ([source isEqualToString:@"goodbye"]) {
        NSLog(@"have received goodbye");
    }
}

// receivePrint delegate method to receive "print" messages from Libpd
// for simplicity we are just sending print messages to the debugging console
- (void)receivePrint:(NSString *)message {
	NSLog(@"(pd) %@", message);
}

#pragma mark - OpenGL

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

    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
    self.link.frameInterval = 1;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDisable(GL_DEPTH_TEST);
    
    
}

- (void)createViewControllers
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        NSLog(@"so far so good?");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
        self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
        [self.view addSubview:self.questionnaireViewController.view];
        self.questionnaireViewController.view.hidden = YES;
        self.questionnaireViewController.appID = self.appID;
        self.questionnaireViewController.delegate = self;
        self.BLEDevice = [storyboard instantiateViewControllerWithIdentifier:@"Bluetooth"];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        self.BLEDevice = [storyboard instantiateViewControllerWithIdentifier:@"Bluetooth"];
    }

    self.pulseTracker = [[SENPulseTracker alloc] init];
    self.pulseTracker.delegate = self;
    
    [self.view addSubview:self.BLEDevice.view];
    self.BLEDevice.view.hidden = YES;
    self.BLEDevice.delegate = self;
    

    
    // see if a unique app value has been set before. if not, set a new unique app id
    if ([[SENUtilities getStringForKey:@"appUniqueID"] isEqualToString:@""]) {
        self.appID = [SENUtilities getUUID];
    } else {
        self.appID = [SENUtilities getStringForKey:@"appUniqueID"];
    }
    self.glviewIsDisplaying = YES;
}

- (void)drawFrame
{
    // notify that we want to update the context
    if (self.glviewIsDisplaying) [self.viewGL setNeedsDisplay];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    CFTimeInterval previousTimestamp = CFAbsoluteTimeGetCurrent();
//    CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - previousTimestamp;
//    NSLog(@"Frame duration: %f ms", frameDuration * 1000.0);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    for (int i=0;i<NUM_RINGS;i++) {
        SENRing *ring = [self.rings objectAtIndex:i];
        if (ring.active == YES) {
            glPushMatrix();
            [ring updateVals];
            glTranslatef(ring.x,ring.y,0);
            [self renderRing:ring.shapeType withDiameter:ring.diameter withBlur:ring.blur withThickness:ring.thickness withNumSides:ring.numSides withColor:ring.color withOpacity:ring.opacity];
            glPopMatrix();
        }
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

#pragma mark - Data Glue

- (void)changeBTMode:(scanMode)mode
{
    self.pulseTracker.mode = mode;
    [self.pulseTracker changeMode:mode];
//    NSLog(@"selected %u mode",self.pulseTracker.mode);
}

- (void)onPulse:(NSNotification *)note {

    double timePassed_ms = [self.date timeIntervalSinceNow] * -1000.0;
//    CFTimeInterval now = CFAbsoluteTimeGetCurrent();
//    
//    self.pulseDuration = now - self.previousPulseTimestamp;
    
    NSLog(@"time since last pulse: %f ms", timePassed_ms);

//    SENPulseTracker *pulseTracker = [(BTAppDelegate *)[[UIApplication sharedApplication] delegate] pulseTracker];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    double PULSESCALE = 1.5;
    
    double PULSEDURATION = 0.2 * 60.0 / self.pulseTracker.heartRate;
    [UIView animateWithDuration:PULSEDURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        if ([defaults boolForKey:DEFAULTS_HEARTBEAT_SOUND] == YES) AudioServicesPlaySystemSound(heartbeatS1Sound);
//        self.heartImage.transform = CGAffineTransformMakeScale(PULSESCALE, PULSESCALE);
//        NSLog(@"lub");
    } completion:^(BOOL finished){
        [UIView animateWithDuration:PULSEDURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            NSLog(@"dub");
//            if ([defaults boolForKey:DEFAULTS_HEARTBEAT_SOUND] == YES) AudioServicesPlaySystemSound(heartbeatS2Sound);
//            self.heartImage.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    self.date = [NSDate date];
}

- (void)onHRDataReceived:(NSNotification *)note {
//    BTPulseTracker *pulseTracker = [(BTAppDelegate *)[[UIApplication sharedApplication] delegate] pulseTracker];
//    self.heartRateLabel.text = [NSString stringWithFormat:@"%.0f BPM", pulseTracker.heartRate];
//    self.variabilityLabel.text = [NSString stringWithFormat:@"%d ms", (int) (0.5 + pulseTracker.r2r * 1000)];
//    self.BLEdevice
//    NSLog(@"heart rate received");
}

- (void)sendMessageForBLEInterface:(NSString *)string
{
    [self.BLEDevice addStringToTextView:string];
}

#pragma mark - Show/Hide

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

- (void)setLabel:(NSString *)label
{
    self.ibiLabel.text = label;
}

- (IBAction)touchSettingsButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.questionnaireViewController.view.hidden = NO;
    self.glviewIsDisplaying = NO;
    self.link.frameInterval = 3;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (IBAction)clickBluetoothButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.BLEDevice.view.hidden = NO;
    self.glviewIsDisplaying = NO;
    self.link.frameInterval = 3;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)startGLView
{
    self.glviewIsDisplaying = YES;
    self.link.frameInterval = 1;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)appHasGoneInBackground
{
    self.glviewIsDisplaying = NO;
    self.link.frameInterval = 3;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    NSLog(@"Entering background, is GL displaying? %hhd",self.glviewIsDisplaying);
}

#pragma mark - Interface

-(void)viewWillActive:(id)sender{
    _chosenMode = [[SENUserDefaultsHelper sharedManager] appMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setVisibility];
    self.glviewIsDisplaying = YES;
    NSLog(@"num: %@",_chosenMode);
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.glviewIsDisplaying = NO;
}

#pragma mark - Settings

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
