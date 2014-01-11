//
//  ViewController.m
//  Storing User Documents in iCloud
//
//  Created by Vandad NP on 29/06/2013.
//  Copyright (c) 2013 Pixolity Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CloudDocument.h"

@interface ViewController () <CloudDocumentProtocol, UITextViewDelegate>
@property (nonatomic, strong) CloudDocument *cloudDocument;
@property (nonatomic, strong) UITextView *textViewCloudDocumentText;
@property (nonatomic, strong) NSMetadataQuery *metadataQuery;
@end

@implementation ViewController

- (NSURL *) urlForDocumentsDirectoryInIcloud{
    
    NSURL *result = nil;
    
    NSString *teamID = @"F3FU372W5M";
    
    NSString *containerID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *teamIdAndContainerId = [NSString stringWithFormat:@"%@.%@",
                                      teamID,
                                      containerID];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSURL *iCloudURL = [fileManager
                        URLForUbiquityContainerIdentifier:teamIdAndContainerId];
    
    NSURL *documentsFolderURLIniCloud =
    [iCloudURL URLByAppendingPathComponent:@"Documents"
                               isDirectory:YES];
    
    /* If it doesn't exist, create it */
    if ([fileManager
         fileExistsAtPath:[documentsFolderURLIniCloud path]] == NO){
        NSLog(@"The documents folder does NOT exist in iCloud. Creating...");
        NSError *folderCreationError = nil;
        
        BOOL created = [fileManager
                        createDirectoryAtURL:documentsFolderURLIniCloud
                        withIntermediateDirectories:YES
                        attributes:nil
                        error:&folderCreationError];
        
        if (created){
            NSLog(@"Successfully created the Documents folder in iCloud.");
            result = documentsFolderURLIniCloud;
        } else {
            NSLog(@"Failed to create the Documents folder in iCloud. \
                  Error = %@", folderCreationError);
        }
    } else {
        NSLog(@"The Documents folder already exists in iCloud.");
        result = documentsFolderURLIniCloud;
    }
    
    return result;
    
}

- (NSURL *) urlForFileInDocumentsDirectoryIniCloud{
    
    return [[self urlForDocumentsDirectoryInIcloud]
            URLByAppendingPathComponent:@"UserDocument.txt"];
    
}

- (void) cloudDocumentChanged:(CloudDocument *)paramSender{
    self.textViewCloudDocumentText.text = paramSender.documentText;
}

- (void) textViewDidChange:(UITextView *)textView{
    self.cloudDocument.documentText = textView.text;
    [self.cloudDocument updateChangeCount:UIDocumentChangeDone];
}

- (void) listenForKeyboardNotifications{
    
    /* As we have a text view, when the keyboard shows on screen, we want to
     make sure our textview's content is fully visible so start
     listening for keyboard notifications */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void) setupTextView{
    /* Create the text view */
    
    CGRect textViewRect = CGRectMake(20.0f,
                                     20.0f,
                                     self.view.bounds.size.width - 40.0f,
                                     self.view.bounds.size.height - 40.0f);
    
    self.textViewCloudDocumentText = [[UITextView alloc] initWithFrame:
                                      textViewRect];
    
    self.textViewCloudDocumentText.delegate = self;
    self.textViewCloudDocumentText.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:self.textViewCloudDocumentText];
}

- (void) startSearchingForDocumentIniCloud{
    /* Start searching for existing text documents */
    self.metadataQuery = [[NSMetadataQuery alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@",
                              NSMetadataItemFSNameKey,
                              @"*"];
    
    [self.metadataQuery setPredicate:predicate];
    NSArray *searchScopes = [[NSArray alloc] initWithObjects:
                             NSMetadataQueryUbiquitousDocumentsScope,
                             nil];
    [self.metadataQuery setSearchScopes:searchScopes];
    
    NSString *metadataNotification =
    NSMetadataQueryDidFinishGatheringNotification;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleMetadataQueryFinished:)
     name:metadataNotification
     object:nil];
    
    [self.metadataQuery startQuery];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self listenForKeyboardNotifications];
    self.view.backgroundColor = [UIColor brownColor];
    [self setupTextView];
    [self startSearchingForDocumentIniCloud];
}

- (void) handleMetadataQueryFinished:(NSNotification *)paramNotification{
    
    /* Make sure this is the metadata query that we were expecting... */
    NSMetadataQuery *senderQuery = (NSMetadataQuery *)[paramNotification object];
    
    if ([senderQuery isEqual:self.metadataQuery] == NO){
        NSLog(@"Unknown metadata query sent us a message.");
        return;
    }
    
    [self.metadataQuery disableUpdates];
    
    /* Now we stop listening for these notifications because we don't really
     have to, any more */
    NSString *metadataNotification =
    NSMetadataQueryDidFinishGatheringNotification;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:metadataNotification
                                                  object:nil];
    [self.metadataQuery stopQuery];
    
    NSLog(@"Metadata query finished.");
    
    
    /* Let's find out if we had previously created this document in the user's
     cloud space because if yes, then we have to avoid overwriting that
     document and just use the existing one */
    __block BOOL documentExistsIniCloud = NO;
    NSString *FileNameToLookFor = @"UserDocument.txt";
    
    NSArray *results = self.metadataQuery.results;
    
    [results
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         NSMetadataItem *item = (NSMetadataItem *)obj;
         NSURL *itemURL = [item valueForAttribute:NSMetadataItemURLKey];
         NSString *lastComponent = [[itemURL pathComponents] lastObject];
         if ([lastComponent isEqualToString:FileNameToLookFor]){
             if ([itemURL
                  isEqual:[self urlForFileInDocumentsDirectoryIniCloud]]){
                 documentExistsIniCloud = YES;
                 *stop = YES;
             }
         }
     }];
    
    NSURL *urlOfDocument = [self urlForFileInDocumentsDirectoryIniCloud];
    self.cloudDocument = [[CloudDocument alloc] initWithFileURL:urlOfDocument
                                                       delegate:self];
    
    __weak ViewController *weakSelf = self;
    
    /* If the document exists, open it */
    if (documentExistsIniCloud){
        NSLog(@"Document already exists in iCloud. Loading it from there...");
        [self.cloudDocument openWithCompletionHandler:^(BOOL success) {
            if (success){
                ViewController *strongSelf = weakSelf;
                NSLog(@"Successfully loaded the document from iCloud.");
                strongSelf.textViewCloudDocumentText.text =
                strongSelf.cloudDocument.documentText;
            } else {
                NSLog(@"Failed to load the document from iCloud.");
            }
        }];
        
    } else {
        NSLog(@"Document does not exist in iCloud. Creating it...");
        
        /* If the document doesn't exist, ask the CloudDocument class to
         save a new file on that address for us */
        [self.cloudDocument
         saveToURL:[self urlForFileInDocumentsDirectoryIniCloud]
         forSaveOperation:UIDocumentSaveForCreating
         completionHandler:^(BOOL success) {
             if (success){
                 NSLog(@"Successfully created the new file in iCloud.");
                 ViewController *strongSelf = weakSelf;
                 
                 strongSelf.textViewCloudDocumentText.text =
                 strongSelf.cloudDocument.documentText;
                 
             } else {
                 NSLog(@"Failed to create the file.");
             }
         }];
        
    }
    
}



- (void) handleKeyboardWillShow:(NSNotification *)paramNotification{
    
    NSDictionary *userInfo = [paramNotification userInfo];
    
    NSValue *animationDurationObject =
    [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject =
    [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    /* Convert the frame from window's coordinate system to
     our view's coordinate system */
    keyboardEndRect = [self.view convertRect:keyboardEndRect
                                    fromView:window];
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect intersectionOfKeyboardRectAndWindowRect =
        CGRectIntersection(self.view.frame, keyboardEndRect);
        
        CGFloat bottomInset =
        intersectionOfKeyboardRectAndWindowRect.size.height;
        
        self.textViewCloudDocumentText.contentInset =
        UIEdgeInsetsMake(0.0f,
                         0.0f,
                         bottomInset,
                         0.0f);
    }];
    
}

- (void) handleKeyboardWillHide:(NSNotification *)paramNotification{
    
    if (UIEdgeInsetsEqualToEdgeInsets
        (self.textViewCloudDocumentText.contentInset,
         UIEdgeInsetsZero)){
            /* Our text view's content inset is intact so no need to 
             reset it */
            return;
        }
    
    NSDictionary *userInfo = [paramNotification userInfo];
    
    NSValue *animationDurationObject =
    [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    double animationDuration = 0.0f;
    
    [animationDurationObject getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.textViewCloudDocumentText.contentInset = UIEdgeInsetsZero;
    }];
        
}

@end
