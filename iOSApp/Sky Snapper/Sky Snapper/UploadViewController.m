//
//  UploadViewController.m
//  Sky Snapper
//
//  Created by Ben Noble on 12/04/2014.
//  Copyright (c) 2014 PA Consulting. All rights reserved.
//

#import "UploadViewController.h"

#import "ResultViewController.h"

#import "SkySnapperWS.h"
#import "PhotoDetails.h"

@interface UploadViewController ()

@end

@implementation UploadViewController
@synthesize uploadImage, uploadImageView, progressView;

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
    // Do any additional setup after loading the view.
    uploadImageView.image = uploadImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSTimer* uploadTimer = nil;
double maxProgress = 0.75f;

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.progressView.progress = 0.0f;
    uploadTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("photo url", NULL);
    dispatch_async(fetchQueue, ^{
        SkySnapperWS* ws = [SkySnapperWS new];
        //NSString* photoUploadUrl = [ws getUploadUrl];
        NSString* photoId = [ws uploadImage:self.uploadImage];
        NSLog(@"Photo id: %@", photoId);
        maxProgress = 0.90f;
        PhotoDetails* photoDetails = [ws getPhotoInformationForPhotoWithId:photoId];
        NSLog(@"Got photo details for photo with id: %@", photoDetails.photoId);

        dispatch_async(dispatch_get_main_queue(), ^{
            [uploadTimer invalidate];
            uploadTimer = nil;
            self.progressView.progress = 1.0f;
            [self forwardToResult];
        });
    });
}

-(void) viewWillDisappear:(BOOL)animated {
    [uploadTimer invalidate];
    uploadTimer = nil;
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ResultSegue"]) {
        NSLog(@"Finished uploading");
        ResultViewController* resultController = segue.destinationViewController;
        resultController.image = self.uploadImage;
    }
}

double step = 0.05f;

-(void) updateProgress {
//    dispatch_async(dispatch_get_main_queue(), ^{
        double newProgress = self.progressView.progress + step;
        if (newProgress < maxProgress) {
            NSLog(@"Setting progress: %f + %f = %f", self.progressView.progress, step, newProgress);
            [self.progressView setProgress:newProgress animated:YES];
        }
//    });
}

-(void) forwardToResult{
        [uploadTimer invalidate];
        uploadTimer = nil;
        [self performSegueWithIdentifier:@"ResultSegue" sender:nil];
}

@end
