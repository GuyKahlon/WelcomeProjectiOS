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
#import "WPAppDelegate.h"

@interface WPRecognizedGuestViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) NSArray* hosts;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic)NSString* hostId;
@property (strong, nonatomic)NSString* guestId;
@property (strong,nonatomic) NSMutableArray *filteredHostsArray;
@property (weak, nonatomic) IBOutlet UIView *searchContinerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic) NSInteger row;

@end

@implementation WPRecognizedGuestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.row = -1;
    
    // Do any additional setup after loading the view.
    if (self.model)
    {
        NSString* firstName = self.model[@"firstName"];
        NSString* lastName  = self.model[@"lastName"];
        
        self.welcomeLabel.text = [NSString stringWithFormat:@"Hi %@ %@, notify your host to welcome you",firstName, lastName];
        NSData* data = [[NSData alloc] initWithBase64EncodedString:self.model[@"picture"] options:0];
        self.userImage.image = [UIImage imageWithData:data];
        
        self.guestId = self.model[@"id"];
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    [server getHostsListWithResualBlock:^(NSArray *hosts) {
        self.hosts = hosts;
    }];
}

#pragma mark - IBAction
- (IBAction)notifyButtonAction:(UIButton *)sender
{    
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    
    [server notifyWithHostId:self.hostId guestId:self.guestId];
    
    [self performSegueWithIdentifier:@"Wating ViewController Segue" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchHostSegue"]) {
        
        WPSearchHostTableViewController* searchHostViewController = segue.destinationViewController;
        searchHostViewController.hosts = self.hosts;
    }
}

- (IBAction)notifyAction {

    if (self.row == -1){
        return;
    }
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:self.row];

    NSNumber* hostId = hostDetails[@"id"];
    NSString* guestId = self.model[@"id"];
    
    WPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;

    WPInnovaServer *server = [[WPInnovaServer alloc]init];

    [server notifyWithHostId:hostId guestId:guestId];
    appDelegate.userDetails = nil;
    appDelegate.profileImage = nil;
    
    [self performSegueWithIdentifier:@"Wating ViewController Segue"
                              sender:self];
}

- (IBAction)clearSearch{
    
    self.searchButton.selected = NO;
    self.searchTextField.text = @"";
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.alpha = 1.0;
    }];
    
    self.row = -1;
    self.notifyButton.enabled = NO;
    self.filteredHostsArray = [self.hosts mutableCopy];
    [self.tableView reloadData];
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
    self.searchButton.selected = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.alpha = 0.0;
    }];
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
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.alpha = 1.0;
    }];
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
