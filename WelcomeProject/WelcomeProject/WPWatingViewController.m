//
//  WPWatingViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 8/24/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPWatingViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface WPWatingViewController()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic)UIWebView* videoView;
@property (nonatomic, strong)NSArray * waitingMessages;
@end

@implementation WPWatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
