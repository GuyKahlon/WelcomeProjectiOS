//
//  WPViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 3/30/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WPMainViewController.h"
#import "MBProgressHUD.h"
#import "WPInnovaServer.h"
#import "WPRecognizedGuestViewController.h"
#import "WPUnrecognizedGuestViewController.h"
#import "WPFaceDetectionViewControolerViewController.h"
#import "WPAppDelegate.h"

@interface WPMainViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *sighnInButton;
@property (strong, nonatomic) NSDictionary* guestInfo;
@property (nonatomic, strong)NSString* guestId;
@end

@implementation WPMainViewController

#pragma mark - Life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.phoneTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.phoneTextField becomeFirstResponder];
    self.guestInfo = nil;
}

#pragma mark - Private methods
- (void)moveToCamera
{
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;

    NSString* phone = self.phoneTextField.text;
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];

    appDelegate.phoneNumber = phone;
    
    [self performSegueWithIdentifier:@"main" sender:self];
}

#pragma mark- UITextViewDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.sighnInButton.enabled = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.phoneTextField.text.length >= 9) {
        self.sighnInButton.enabled = YES;
    }
    else{
       self.sighnInButton.enabled = NO;
    }
    return YES;
}

#pragma mark - IBAction
- (IBAction)signInButtonAction:(UIButton *)sender{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WPInnovaServer *server = [[WPInnovaServer alloc]init];

    NSString* phone = self.phoneTextField.text;
    
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.phoneNumber = phone;
    
    [server searchGuestByPhoneNumber:phone resualtBloack:^(BOOL find, NSDictionary *jsonData) {
        
        if (find) {
            self.guestInfo = jsonData;
            [self performSegueWithIdentifier:@"RecognizedGuestViewControllerSegue" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"UnRecognizedGuestViewControllerSegue" sender:self];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RecognizedGuestViewControllerSegue"]) {
        
        WPRecognizedGuestViewController *recognizedGuestVC = segue.destinationViewController;
        recognizedGuestVC.model = self.guestInfo;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"UnRecognizedGuestViewControllerSegue"]) {
        
    }
}
@end
