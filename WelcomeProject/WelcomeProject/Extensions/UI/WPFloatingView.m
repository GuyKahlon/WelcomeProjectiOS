//
//  WPFloatingView.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPFloatingView.h"

@implementation WPFloatingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    // Start by filling the area with the blue color
//    [[UIColor blackColor] setFill];
//    self.alpha = 0.7;
//    UIRectFill( rect );
//    
//    // Assume that there's an ivar somewhere called holeRect of type CGRect
//    // We could just fill holeRect, but it's more efficient to only fill the
//    // area we're being asked to draw.
//    CGRect holeRectIntersection = CGRectIntersection( self.transparentRectangleRect, rect );
//    
//    [[UIColor clearColor] setFill];
//    UIRectFill( holeRectIntersection );
    
    CGRect a = CGRectMake(self.transparentRectangleRect.origin.x - 40, self.transparentRectangleRect.origin.y - 80,self.transparentRectangleRect.size.width + 80, self.transparentRectangleRect.size.height + 80);
    self.transparentRectangleRect = a;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor( context, [UIColor blackColor].CGColor );
    self.alpha = 0.7;
    CGContextFillRect( context, rect );
    
    //CGRect holeRectIntersection = CGRectIntersection( self.transparentRectangleRect, rect );
    
    CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextFillEllipseInRect( context, a );
    
}


@end
