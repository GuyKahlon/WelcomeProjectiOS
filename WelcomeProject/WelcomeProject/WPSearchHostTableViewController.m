//
//  WPSearchHostTableViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 7/6/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPSearchHostTableViewController.h"
#import "WPInnovaServer.h"

@interface WPSearchHostTableViewController ()<UISearchBarDelegate>
@property (strong,nonatomic) NSMutableArray *filteredHostsArray;
@end

@implementation WPSearchHostTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)closeButtonAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredHostsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HostCell"];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HostCell"];
    }
    
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:indexPath.row];
   
    
    NSString* hostName = [NSString stringWithFormat:@"%@ %@", hostDetails[@"lastName"], hostDetails[@"firstName"]];
    cell.textLabel.text = hostName;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSDictionary *hostDetails = [self.filteredHostsArray objectAtIndex:indexPath.row];
    
    NSString* hostName = [NSString stringWithFormat:@"%@ %@", hostDetails[@"lastName"], hostDetails[@"firstName"]];
    NSNumber* hostId = hostDetails[@"id"];
    
    [self.delegate searchHostTableViewController:self
                                 selectedChanged:hostName
                                  selectedHostId:[hostId stringValue]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
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



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
