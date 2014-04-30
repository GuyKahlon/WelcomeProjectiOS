//
//  NSObject+Block.h
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Block)
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay complitionBlock:(void (^)())complitionBlock;
@end
