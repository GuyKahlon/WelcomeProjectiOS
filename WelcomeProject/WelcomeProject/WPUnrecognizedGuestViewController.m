//
//  WPUnrecognizedGuestViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 5/25/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPUnrecognizedGuestViewController.h"
#import "WPInnovaServer.h"
@interface WPUnrecognizedGuestViewController ()<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *selectHostsTextField;
@property (strong, nonatomic) NSArray* hosts;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldsCollections;

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
    // Do any additional setup after loading the view.
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    [server getHostsListWithResualBlock:^(NSArray *hosts) {
        
        self.hosts = hosts;
    }];
    
    
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.selectHostsTextField.inputView = pickerView;
    
    UITextField *firstTextField = self.textFieldsCollections.firstObject;
    [firstTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSInteger tag = textField.tag + 1;
    
    if (tag < self.textFieldsCollections.count)
    {
        UITextField *firstTextField = self.textFieldsCollections[tag++];
        [firstTextField becomeFirstResponder];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return NO;
    }
}
#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.hosts.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%@ %@", self.hosts[row][@"firstName"],self.hosts[row][@"lastName"]];
    return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *hostName = [NSString stringWithFormat:@"%@ %@", self.hosts[row][@"firstName"],self.hosts[row][@"lastName"]];
    self.selectHostsTextField.text = hostName;
    [self.selectHostsTextField resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
