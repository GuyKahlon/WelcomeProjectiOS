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

@interface WPUnrecognizedGuestViewController ()<UIPickerViewDelegate, UITextFieldDelegate>
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.firstNameTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    [self.lastNameTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
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
-(BOOL) IsValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter{
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

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

- (IBAction)nextButtonAction:(UIButton *)sender{
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;

    UIImage* comImg = [self compressForUpload:appDelegate.profileImage scale:0.25];
    
    UIImage *scaledImage = [UIImage imageWithCGImage:[comImg CGImage]
                                               scale:(comImg.scale * 1.0)
                                         orientation:(UIImageOrientationRight)];
    
    NSString *imageBase64 = [self imageBase64String:scaledImage];

    appDelegate.userDetails = @{@"firstName":   [self emptyIfNil:self.firstNameTextField.text],
                                @"lastName":    [self emptyIfNil:self.lastNameTextField.text],
                                @"email":       [self emptyIfNil:self.emailTextField.text],
                                @"phoneNumber": [self emptyIfNil:appDelegate.phoneNumber],
                                @"base64img":imageBase64
                                };
    
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
- (BOOL)textFieldDidChange:(UITextField *)textField {
    
    if (self.firstNameTextField.text.length > 1 && self.lastNameTextField.text.length > 1){
        self.nextButton.enabled = YES;
    }
    else{
        self.nextButton.enabled = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.firstNameTextField && textField.text.length > 0){
        [self.lastNameTextField becomeFirstResponder];
    }else if (textField == self.lastNameTextField && textField.text.length > 0){
        [self.emailTextField becomeFirstResponder];
    }else if(textField == self.emailTextField){
        [self.emailTextField resignFirstResponder];
    }
    return YES;
}

@end
