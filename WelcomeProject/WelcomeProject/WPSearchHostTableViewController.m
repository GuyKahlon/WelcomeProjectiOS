//
//  WPSearchHostTableViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 7/6/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPSearchHostTableViewController.h"
#import "WPInnovaServer.h"
#import <QuartzCore/QuartzCore.h>
#import "WPAppDelegate.h"

@interface WPSearchHostTableViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong,nonatomic) NSMutableArray *filteredHostsArray;
@property (weak, nonatomic) IBOutlet UIView *searchContinerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) NSInteger row;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton;
@end

@implementation WPSearchHostTableViewController

#pragma mark - Life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.row = -1;
    self.notifyButton.enabled = NO;
    
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if (self.hosts == nil) {
        WPInnovaServer *server = [[WPInnovaServer alloc]init];
        [server getHostsListWithResualBlock:^(NSArray *hosts) {
            self.hosts = hosts;
            self.filteredHostsArray = [self.hosts mutableCopy];
            [self.tableView reloadData];
        }];
    }

    self.searchContinerView.layer.borderColor = [UIColor blackColor].CGColor;
    self.searchContinerView.layer.borderWidth = 1.0f;
}

#pragma mark - IBAction
- (IBAction)clearSearch:(UIButton *)sender {
    
    self.searchButton.selected = NO;
    self.searchTextField.text = @"";
    self.tableView.hidden = NO;
    self.row = -1;
    self.notifyButton.enabled = NO;
    self.filteredHostsArray = [self.hosts mutableCopy];
    [self.tableView reloadData];
}

- (IBAction)notifyAction {
    
    if (self.row == -1){
        return;
    }
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:self.row];
    
    NSNumber* hostId = hostDetails[@"id"];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    [server createGuestWithGuest:appDelegate.userDetails
                          hostId:[hostId stringValue]];
    
    appDelegate.userDetails = nil;
    
    [self performSegueWithIdentifier:@"Wating" sender:self];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.filteredHostsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HostCell"];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HostCell"];
    }
    
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:indexPath.row];
   
    
    NSString* hostName = [NSString stringWithFormat:@"%@ %@",
                          hostDetails[@"firstName"],
                          hostDetails[@"lastName"]];
    cell.textLabel.text = hostName;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.searchTextField resignFirstResponder];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    self.row = indexPath.row;
    self.searchTextField.text = cell.textLabel.text;
    
    self.notifyButton.enabled = YES;
    self.tableView.hidden = YES;
}

- (NSString *)emptyIfNil:(NSString *)str{
    
    if (str == nil){
        return @"";
    }
    return str;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldDidChange:(UITextField *)textField {
    if ([textField.text isEqualToString:@""])
    {
        self.searchButton.selected = NO;
        self.notifyButton.enabled = NO;
        self.filteredHostsArray = [self.hosts mutableCopy];
    }
    else
    {
        [self filterContentForSearchText:textField.text scope:nil];
        self.searchButton.selected = YES;
    }
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchButton.selected = NO;
    self.notifyButton.enabled = NO;
    self.filteredHostsArray = [self.hosts mutableCopy];
    [self.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.row = -1;
    self.notifyButton.enabled = NO;
    self.tableView.hidden = NO;
    return YES;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    [self.filteredHostsArray removeAllObjects];
    self.filteredHostsArray = [[self.hosts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *hostDetails, NSDictionary *bindings) {
        
        NSString* hostName = [NSString stringWithFormat:@"%@ %@",
                              hostDetails[@"lastName"], hostDetails[@"firstName"]];

        NSString* nameHost = [NSString stringWithFormat:@"%@ %@",
                              hostDetails[@"firstName"], hostDetails[@"lastName"]];
        return [hostName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [nameHost rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ;
    }]]mutableCopy];
}

@end
