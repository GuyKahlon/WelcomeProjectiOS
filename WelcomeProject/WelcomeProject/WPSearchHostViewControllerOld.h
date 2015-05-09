//
//  WPSearchHostTableViewController.h
//  WelcomeProject
//
//  Created by Guy Kahlon on 7/6/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WPSearchHostViewControllerOld;

@protocol WPSearchHostTableViewControllerDelegate <NSObject>

- (void)searchHostTableViewController:(WPSearchHostViewControllerOld *)sender
                      selectedChanged:(NSString *)hostName
                       selectedHostId:(NSString *)hostId;
@end


@interface WPSearchHostViewControllerOld : UITableViewController
@property (nonatomic, strong)NSArray * hosts;
@property (nonatomic, weak)id<WPSearchHostTableViewControllerDelegate> delegate;
@end
