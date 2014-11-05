//
//  WPServer.h
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WPServerSearchResualt)(BOOL find, NSDictionary *jsonData);
typedef void(^WPServerHostsListResualt)(NSArray *hosts);

@protocol WPServer <NSObject>
//Search Guest by picture
- (void)searchGuestByPicture:(NSArray *)arrayImages resualtBloack:(WPServerSearchResualt)resualtBloack;

//Get Hosts List
- (void)getHostsListWithResualBlock:(WPServerHostsListResualt)resualtBlock;

//Notify Host
- (void)notifyWithHostId:(NSObject *)hostId guestId:(NSString *)guestId;


//Create Guest
- (void)createGuestWithGuest:(NSDictionary *)guest hostId:(NSString *)hostId;
@end
