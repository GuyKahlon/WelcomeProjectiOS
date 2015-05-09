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
#import "WPFaceDetectionViewControolerViewController.h"

@interface WPUnrecognizedGuestViewController ()<UIPickerViewDelegate, UITextFieldDelegate, WPSearchHostTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *selectHostsTextField;
@property (strong, nonatomic) NSArray* hosts;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldsCollections;
@property (weak, nonatomic)UITextField* currentTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic)NSString* hostId;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *guestImage;

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
    
    self.firstNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    self.lastNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.currentTextField = self.textFieldsCollections.firstObject;
    [self.currentTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    self.guestImage.image = appDelegate.profileImage;
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

- (NSString *)emptyIfNil:(NSString *)str{
    
    if (str == nil){
        return @"";
    }
    return str;
}

- (IBAction)notifyHostButtonAction:(UIButton *)sender
{
    //WPInnovaServer *server = [[WPInnovaServer alloc]init];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    UIImage *scaledImage = [UIImage imageWithCGImage:[appDelegate.profileImage CGImage]
                                                   scale:(appDelegate.profileImage.scale * 1.0)
                                             orientation:(UIImageOrientationRight)];
    NSString *imageBase64 = [self imageBase64String:scaledImage];
    
    
//    [server createGuestWithGuest:@{@"firstName":   [self emptyIfNil:self.firstNameTextField.text],
//                                   @"lastName":    [self emptyIfNil:self.lastNameTextField.text],
//                                   @"email":       [self emptyIfNil:self.emailTextField.text],
//                                   @"phoneNumber": [self emptyIfNil:appDelegate.phoneNumber],
//                                   @"base64img":imageBase64
//                                   }
//                                   hostId:self.hostId];

    appDelegate.userDetails = @{@"firstName":   [self emptyIfNil:self.firstNameTextField.text],
                                @"lastName":    [self emptyIfNil:self.lastNameTextField.text],
                                @"email":       [self emptyIfNil:self.emailTextField.text],
                                @"phoneNumber": [self emptyIfNil:appDelegate.phoneNumber],
                                @"base64img":imageBase64
                                };
    
    //appDelegate.phoneNumber = nil;
    //appDelegate.profileImage = nil;
    
    [self performSegueWithIdentifier:@"selectHost" sender:self];
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0){
        self.nextButton.enabled = YES;
    }
    else{
        self.nextButton.enabled = NO;
    }
    
    return YES;
}

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
    
    if (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0){
        self.nextButton.enabled = YES;
    }
    else{
        self.nextButton.enabled = NO;
    }
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if (textField == self.selectHostsTextField) {
//        [self.currentTextField resignFirstResponder];
//        [self performSegueWithIdentifier:@"SearchHostSegue" sender:self];
//        return NO;
//    }
//    self.currentTextField = textField;
//    return YES;
//}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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
    //self.notifyButton.enabled = YES;
}

@end
