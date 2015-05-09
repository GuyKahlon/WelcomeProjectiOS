//
//  WPInnovaServer.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPInnovaServer.h"
#import "AFHTTPRequestOperationManager.h"

@interface WPInnovaServer()
@property (strong, nonatomic)AFHTTPRequestOperationManager* manager;
@end

@implementation WPInnovaServer
- (AFHTTPRequestOperationManager *)manager
{
    if (!_manager){
//        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://52.28.11.39:5678/"]];
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.0.101/"]];
        
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    return _manager;
}

- (void)searchGuestByPhoneNumber:(NSString *)phoneNumber
                   resualtBloack:(WPServerSearchResualt)resualtBloack{
    [self.manager GET:[NSString stringWithFormat:@"guests/searchByPhone?phoneNumber=%@",phoneNumber]
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   
                   NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:nil];
                   id userDetails = jsonObject[@"guest"];
                   if ([[userDetails description]isEqualToString:@"{}"])
                   {
                       if (resualtBloack) {
                           resualtBloack(NO,jsonObject);
                       }
                   }
                   else{
                       if (resualtBloack) {
                           resualtBloack(YES,userDetails);
                       }
                   }
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog(@"Error: %@", error);
               }];
}

- (void)getHostsListWithResualBlock:(WPServerHostsListResualt)resualtBlock{
    
    //TODO -- support paging (first page number 0 "page": "1", "size")
    [self.manager GET:@"hosts"
           parameters:@{@"size": @(200)}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON Response: %@", responseObject);
                
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                             error:nil];
                NSArray *hosts = jsonObject[@"hosts"];
                if (resualtBlock) {
                    resualtBlock(hosts);
                }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (resualtBlock) {
                 resualtBlock(nil);
             }
         }];
}

- (void)notifyWithHostId:(NSObject *)hostId guestId:(NSString *)guestId{

    NSString *url = [NSString stringWithFormat:@"/notifications?hostId=%@&guestId=%@",hostId,guestId];
    
    [self.manager POST:url
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {                   
           
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
           if ([jsonObject objectForKey:@"errMsg"]) {
            
               //Report to Google analytics
               //NSString* errorMsg = [jsonObject objectForKey:@"errMsg"];
               [[[UIAlertView alloc]initWithTitle:@"Sorry 😳"
                                          message:@"We couldn't notify your host that you are here. \n Please contact our security guard."
                                         delegate:nil
                                cancelButtonTitle:@"Dismiss"
                                otherButtonTitles:nil]show];
           }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
        }];
}

- (void)createGuestWithGuest:(NSDictionary *)guest hostId:(NSString *)hostId{

    [self.manager POST:@"guests"
            parameters:guest
          success:^(AFHTTPRequestOperation *operation, id responseObject) {              
          NSLog(@"createGuestWithGuest response");
          NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
          id userDetails = jsonObject[@"guest"];
          if ([[userDetails description]isEqualToString:@"{}"] == NO)
          {
              [self notifyWithHostId:hostId guestId:userDetails[@"id"]];
          }
          NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
    }];
}
@end
