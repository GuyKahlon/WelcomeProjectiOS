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
    if (!_manager)
    {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://10.29.96.215/"]];
//        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        _manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    return _manager;
}

- (void)searchGuestByPicture:(NSArray *)arrayImages resualtBloack:(WPServerSearchResualt)resualtBloack;
{
    //Return mock not find guest.
    if (resualtBloack) {
        resualtBloack(NO,nil);
    }
    return ;
    
    [self.manager POST:@"guests/search"
            parameters:@{@"pictures":arrayImages}
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                   NSLog(@"JSON Response: %@", responseObject);
                   NSDictionary *JSON = (NSDictionary *) responseObject;
                   id user = JSON[@"guest"];
                   if ([[user description]isEqualToString:@"{}"])
                   {
                       if (resualtBloack) {
                           resualtBloack(NO,nil);
                       }
                   }
                   else
                   {
                       if (resualtBloack) {
                           resualtBloack(YES,@{@"id":@(597),
                                               @"firstName":@"Avi",
                                               @"lastName": @"Cohen",
                                               @"email":@"avi.cohen@gmail.com",
                                               @"telephone":@"0500000000",
                                               @"picId":@(1298)});
                       }
                       
                   }
                   
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   
                   NSLog(@"Error: %@", error);
               }];
    
//    [self createGuestWithGuest:nil];
//    AFHTTPRequestOperationManager *manager = self.manager;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:@"guests/search" parameters:nil
//                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:imageData name:@"image" fileName:imageFilename mimeType:@"image/png"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"Success: %@", string);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
//    resualtBloack(YES,@{@"id":@(597),
//                        @"firstName":@"Avi",
//                        @"lastName": @"Cohen",
//                        @"email":@"avi.cohen@gmail.com",
//                        @"telephone":@"0500000000",
//                        @"picId":@(1298)});
   
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:@"http://10.29.33.200"
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//         
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//             NSLog(@"Error: %@", error);
//    }];
}

- (void)getHostsListWithResualBlock:(WPServerHostsListResualt)resualtBlock;
{
  [self.manager GET:@"hosts"
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON Response: %@", responseObject);
                NSDictionary *JSON = (NSDictionary *) responseObject;
                NSArray *hosts = JSON[@"hosts"];
                if (resualtBlock) {
                    resualtBlock(hosts);
                }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (resualtBlock) {
                 resualtBlock(nil);
             }
         }];
}

- (void)notifyWithHost:(NSObject *)host guest:(NSObject *)guest
{

}

- (void)createGuestWithGuest:(NSObject *)guest
{
//    NSURL *baseURL = [NSURL URLWithString:@"http://10.29.33.200/hosts"];
//    
//    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [manager GET:@""
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             
//             NSLog(@"JSON: %@", responseObject);
//             NSLog(@"JSON: %@", responseObject);
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             
//             NSLog(@"Error: %@", error);
//         }];

    [self.manager POST:@"guests" parameters:@{@"firstName":@"Guy",
                                              @"lastName": @"Kahlon",
                                              @"email":@"guykahlon@gmail.com",
                                              @"phoneNumber":@"0509944364"}
     
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
    }];
}
@end
