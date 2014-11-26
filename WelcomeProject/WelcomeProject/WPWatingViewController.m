//
//  WPWatingViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 8/24/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPWatingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface WPWatingViewController()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic)UIWebView* videoView;
@property (nonatomic, strong)NSArray * waitingMessages;
@end

@implementation WPWatingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CitiInnovationLabTLV" ofType:@"mov"]];
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:oneRef];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnailImage];
    
    imageView.frame = CGRectMake(0,
                                 0,
                                 thumbnailImage.size.width/2,
                                 thumbnailImage.size.height/2);
    
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:self.playButton];
}

- (IBAction)buttonPressed:(id)sender
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CitiInnovationLabTLV" ofType:@"mov"]];
    MPMoviePlayerViewController *playercontroller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:playercontroller];
    playercontroller.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playercontroller.moviePlayer play];
}

- (IBAction)closeButtonAction:(UIButton *)sender
{
    UIViewController* mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:mainViewController animated:YES completion:nil];
}

@end
