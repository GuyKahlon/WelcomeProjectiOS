//
//  NSObject+Block.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

- (void)performBlock:(void (^)())block
{
    if (block) {
        block();
    }
}

//- (void)performBlock:(void (^)())block WithComplitionBlock:(void (^)())complitionBlock
//{
//    if (block) {
//        block();
//    }
//    if (complitionBlock) {
//        complitionBlock();
//    }
//}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy];
    [self performSelector:@selector(performBlock:)
               withObject:block_
               afterDelay:delay];
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay complitionBlock:(void (^)())complitionBlock
{
    void (^block_)() = [block copy];
    void (^complitionBlock_)()= [complitionBlock copy];

  
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (block_) {
            block_();
        }
        if (complitionBlock_) {
            complitionBlock_();
        }
    });
}

@end
