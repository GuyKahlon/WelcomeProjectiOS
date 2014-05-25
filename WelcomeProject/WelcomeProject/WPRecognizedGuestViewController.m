//
//  WPRecognizedGuestViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPRecognizedGuestViewController.h"

@interface WPRecognizedGuestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;

@end

@implementation WPRecognizedGuestViewController

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
    
//    resualtBloack(YES,@{@"id":@(597),
//                        @"firstName":@"Avi",
//                        @"lastName": @"Cohen",
//                        @"email":@"avi.cohen@gmail.com",
//                        @"telephone":@"0500000000",
//                        @"picId":@(1298)});
    if (self.model)
    {
        self.firstNameLabel.text = self.model[@"firstName"];
        self.lastNameLabel.text = self.model[@"lastName"];
        self.emailLabel.text = self.model[@"email"];
        self.telephoneLabel.text = self.model[@"telephone"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
