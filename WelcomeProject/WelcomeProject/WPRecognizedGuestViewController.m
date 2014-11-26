//
//  WPRecognizedGuestViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPRecognizedGuestViewController.h"
#import "WPSearchHostTableViewController.h"
#import "WPInnovaServer.h"

@interface WPRecognizedGuestViewController ()<WPSearchHostTableViewControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *selectHostsTextField;
@property (strong, nonatomic) NSArray* hosts;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton;


@property (strong, nonatomic)NSString* hostId;
@property (strong, nonatomic)NSString* guestId;

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
    if (self.model)
    {
        self.firstNameLabel.text = self.model[@"firstName"];
        self.lastNameLabel.text  = self.model[@"lastName"];
        self.emailLabel.text     = self.model[@"email"];
        self.telephoneLabel.text = self.model[@"phoneNumber"];
        //self.model[@"picUrl"];
        self.guestId = self.model[@"id"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    [server getHostsListWithResualBlock:^(NSArray *hosts) {
        self.hosts = hosts;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)notifyButtonAction:(UIButton *)sender
{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    
    [server notifyWithHostId:self.hostId guestId:self.guestId];
    
    [self performSegueWithIdentifier:@"Wating ViewController Segue" sender:self];
}

#pragma mark - UItextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.selectHostsTextField) {
        [self performSegueWithIdentifier:@"SearchHostSegue" sender:self];
        return NO;
    }
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchHostSegue"]) {
        
        WPSearchHostTableViewController* searchHostViewController = segue.destinationViewController;
        searchHostViewController.hosts = self.hosts;
        searchHostViewController.delegate = self;
    }
}

#pragma mark - WPSearchHostTableViewControllerDelegate
- (void)searchHostTableViewController:(WPSearchHostTableViewController *)sender
                      selectedChanged:(NSString *)hostName
                       selectedHostId:(NSString *)hostId{
    
    self.selectHostsTextField.text = hostName;
    if (hostName.length > 0) {
        self.notifyButton.enabled = YES;
    }
    self.hostId = hostId;
}
@end
