//
//  WPUnrecognizedGuestViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 5/25/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPUnrecognizedGuestViewController.h"
#import "WPInnovaServer.h"
#import "WPSearchHostTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WPAppDelegate.h"

@interface WPUnrecognizedGuestViewController ()<UIPickerViewDelegate, UITextFieldDelegate, WPSearchHostTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *selectHostsTextField;
@property (strong, nonatomic) NSArray* hosts;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldsCollections;
@property (weak, nonatomic)UITextField* currentTextField;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton;


@property (strong, nonatomic)NSString* hostId;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation WPUnrecognizedGuestViewController

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
    self.currentTextField = self.textFieldsCollections.firstObject;
    [self.currentTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
//    WPInnovaServer *server = [[WPInnovaServer alloc]init];
//    [server getHostsListWithResualBlock:^(NSArray *hosts) {
//        self.hosts = hosts;
//    }];
}

#pragma mark - Private
-(BOOL) IsValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

#pragma mark - IBAction
- (IBAction)handleTapGestureRecognizer:(UITapGestureRecognizer *)sender {

    [self.currentTextField resignFirstResponder];
}

- (IBAction)notifyHostButtonAction:(UIButton *)sender
{
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    
        
    UIImage *scaledImage = [UIImage imageWithCGImage:[appDelegate.profileImage CGImage]
                                                   scale:(appDelegate.profileImage.scale * 1.0)
                                             orientation:(UIImageOrientationRight)];
    NSString *imageBase64 = [self imageBase64String:scaledImage];
    
    
    [server createGuestWithGuest:@{@"firstName":self.firstNameTextField.text,
                                   @"lastName": self.lastNameTextField.text,
                                   @"email": self.emailTextField.text,
                                   @"phoneNumber": appDelegate.phoneNumber,
                                   @"base64img":imageBase64
                                   }
                                   hostId:self.hostId];
    
    appDelegate.phoneNumber = nil;
    appDelegate.profileImage = nil;
    
    //[self performSegueWithIdentifier:@"Wating ViewController Segue" sender:self];
}

- (NSString *)imageBase64String:(UIImage *)image
{
    if (image == nil){
        return @"";
    }
    
    NSData * data = [UIImagePNGRepresentation(image) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}

#pragma mark - UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag + 1;
    
    if (textField == self.emailTextField)
    {
        if ([self IsValidEmail:textField.text Strict:YES] == NO) {
            textField.layer.borderColor = [[UIColor redColor]CGColor];
            textField.layer.borderWidth= 1.0f;
        }
        else {
            [[self.emailTextField layer] setBorderColor:nil];
            textField.layer.borderWidth= 0.0f;
        }
    }
    
    if (tag < self.textFieldsCollections.count)
    {
        UITextField* currentTextField = self.textFieldsCollections[tag++];
        [currentTextField becomeFirstResponder];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return NO;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.selectHostsTextField) {
        [self.currentTextField resignFirstResponder];
        [self performSegueWithIdentifier:@"SearchHostSegue" sender:self];
        return NO;
    }
    self.currentTextField = textField;
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchHostSegue"]) {
        
        WPSearchHostTableViewController* searchHostViewController = segue.destinationViewController;
        searchHostViewController.delegate = self;
    }
}

#pragma mark - WPSearchHostTableViewControllerDelegate
- (void)searchHostTableViewController:(WPSearchHostTableViewController *)sender
                      selectedChanged:(NSString *)hostName
                       selectedHostId:(NSString *)hostId{
    
    self.selectHostsTextField.text = hostName;
    self.hostId = hostId;
    self.notifyButton.enabled = YES;
}

@end
