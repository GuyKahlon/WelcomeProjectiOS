//
//  WPSearchHostTableViewController.h
//  WelcomeProject
//
//  Created by Guy Kahlon on 7/6/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WPSearchHostTableViewController;

@protocol WPSearchHostTableViewControllerDelegate <NSObject>

- (void)searchHostTableViewController:(WPSearchHostTableViewController *)sender
                      selectedChanged:(NSString *)hostName
                       selectedHostId:(NSString *)hostId;
@end


@interface WPSearchHostTableViewController : UITableViewController
@property (nonatomic, strong)NSArray * hosts;
@property (nonatomic, weak)id<WPSearchHostTableViewControllerDelegate> delegate;
@end
