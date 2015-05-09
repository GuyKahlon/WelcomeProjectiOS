//
//  WPSearchHostTableViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 7/6/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPSearchHostViewControllerOld.h"
#import "WPInnovaServer.h"

@interface WPSearchHostViewControllerOld ()<UISearchBarDelegate>
@property (strong,nonatomic) NSMutableArray *filteredHostsArray;
@end

@implementation WPSearchHostViewControllerOld

#pragma mark - Life cycle
- (instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.hosts == nil) {
        
        WPInnovaServer *server = [[WPInnovaServer alloc]init];
        [server getHostsListWithResualBlock:^(NSArray *hosts) {
            self.hosts = hosts;
            self.filteredHostsArray = [self.hosts mutableCopy];
            [self.tableView reloadData];
        }];
    }
    self.filteredHostsArray = [self.hosts mutableCopy];
}

#pragma mark - IBAction
- (IBAction)closeButtonAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:indexPath.row];
    
    NSString* hostName = [NSString stringWithFormat:@"%@ %@",
                          hostDetails[@"firstName"],
                          hostDetails[@"lastName"]];
    NSNumber* hostId = hostDetails[@"id"];
    
    [self.delegate searchHostTableViewController:self
                                 selectedChanged:hostName
                                  selectedHostId:[hostId stringValue]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""])
    {
        self.filteredHostsArray = [self.hosts mutableCopy];
    }
    else
    {
        [self filterContentForSearchText:searchText scope:nil];
    }
    [self.tableView reloadData];
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
