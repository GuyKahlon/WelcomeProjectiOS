//
//  WPViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 3/30/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPViewController.h"

@interface WPViewController ()<UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>
{
    UIDynamicAnimator* _animator;
    UIGravityBehavior* _gravity;
    UICollisionBehavior* _collision;
    
    __weak IBOutlet UIView *citiIcone;
    __weak IBOutlet UILabel *citiLabel;
    __weak IBOutlet UIView *innovationIcon;
    __weak IBOutlet UILabel *innovationLabel;
    __weak IBOutlet UIView *labIcon;
    __weak IBOutlet UILabel *labLabel;
    __weak IBOutlet UIView *tlvIcon;
    __weak IBOutlet UILabel *tlvLabel;
    __weak IBOutlet UILabel *welcomeLabel;
    
    BOOL _firstContact;
}
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *iconsView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsView;

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     // Do any additional setup after loading the view, typically from a nib.
    
    for (UILabel *label in self.labelsView)
    {
        label.frame = CGRectMake(label.frame.origin.x,
                                 label.frame.origin.y,
                                 0,
                                 100);
    }
    for (UIView *view in self.iconsView)
    {
        view.frame = CGRectMake(view.frame.origin.x,
                                0,
                                view.frame.size.width,
                                view.frame.size.height);
    }
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _gravity  = [[UIGravityBehavior alloc] initWithItems:@[citiIcone, innovationIcon, labIcon, tlvIcon]];
    
    _animator.delegate = self;
    //UIView* barrier = [[UIView alloc] initWithFrame:CGRectMake(0, 550, 100, 20)];
    //barrier.backgroundColor = [UIColor redColor];
    //[self.view addSubview:barrier];
    
    //_gravity.angle = 0.5;
    //_gravity.magnitude = 0.5;
    [_animator addBehavior:_gravity];
    
    
    //Citi
    _collision = [[UICollisionBehavior alloc]initWithItems:@[citiIcone]];
    _collision.collisionDelegate = self;
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    CGPoint rightEdge = CGPointMake(citiLabel.frame.origin.x,citiLabel.frame.origin.y + citiLabel.frame.size.height - 14);
    CGPoint leftEdge = CGPointMake(0,citiLabel.frame.origin.y + citiLabel.frame.size.height -14);
    [_collision addBoundaryWithIdentifier:@"citiLabel"
                                fromPoint:leftEdge
                                  toPoint:rightEdge];
    [_animator addBehavior:_collision];
    
    //Innovation
    _collision = [[UICollisionBehavior alloc]initWithItems:@[innovationIcon]];
    _collision.collisionDelegate = self;
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    rightEdge = CGPointMake(innovationLabel.frame.origin.x,innovationLabel.frame.origin.y + innovationLabel.frame.size.height - 14);
    leftEdge = CGPointMake(0,innovationLabel.frame.origin.y + innovationLabel.frame.size.height -14);
    [_collision addBoundaryWithIdentifier:@"innovationLabel"
                                fromPoint:leftEdge
                                  toPoint:rightEdge];
    [_animator addBehavior:_collision];
    
    
    //Lab
    _collision = [[UICollisionBehavior alloc]initWithItems:@[labIcon]];
    _collision.collisionDelegate = self;
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    rightEdge = CGPointMake(labLabel.frame.origin.x,labLabel.frame.origin.y + labLabel.frame.size.height - 14);
    leftEdge = CGPointMake(0,labLabel.frame.origin.y + labLabel.frame.size.height -14);
    [_collision addBoundaryWithIdentifier:@"labLabel"
                                fromPoint:leftEdge
                                  toPoint:rightEdge];
    [_animator addBehavior:_collision];
    
    
    //Tlv
    _collision = [[UICollisionBehavior alloc]initWithItems:@[tlvIcon]];
    _collision.collisionDelegate = self;
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    rightEdge = CGPointMake(tlvLabel.frame.origin.x,tlvLabel.frame.origin.y + tlvLabel.frame.size.height - 14);
    leftEdge = CGPointMake(0,tlvLabel.frame.origin.y + tlvLabel.frame.size.height -14);
    [_collision addBoundaryWithIdentifier:@"tlvLabel"
                                fromPoint:leftEdge
                                  toPoint:rightEdge];
    [_animator addBehavior:_collision];
    _collision.action =  ^{
        //NSLog(@"%@, %@",NSStringFromCGAffineTransform(citiIcone.transform),NSStringFromCGPoint(citiIcone.center));
    };
    
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[citiIcone, innovationIcon, labIcon, tlvIcon]];
    itemBehaviour.elasticity = 0.3;
    [_animator addBehavior:itemBehaviour];
    
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    NSLog(@"dynamicAnimatorDidPause");
    
    [UIView animateKeyframesWithDuration:1.0
                                   delay:2.0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  welcomeLabel.hidden = NO;

                              } completion:^(BOOL finished) {
                                  
                                  [self performSelector:@selector(moveToCamera)
                                             withObject:nil
                                             afterDelay:1.0];
                              }];
}

- (void)moveToCamera
{
    [self performSegueWithIdentifier:@"main" sender:self];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier
                  atPoint:(CGPoint)p
{
    NSString *ide = (NSString *)identifier;
    UILabel *label = [self valueForKey:ide];
    
    if (label.frame.size.height != 511)
    {
        [UIView animateWithDuration:2.0 animations:^{
            label.frame = CGRectMake(label.frame.origin.x,
                                     label.frame.origin.y,
                                     511,
                                     label.frame.size.height);
        }];
    }
    
    NSLog(@"Boundary contact occurred - %@", identifier);
    UIView* view = (UIView*)item;
    UIColor *color = view.backgroundColor;
    view.backgroundColor = [self randomColor];
    [UIView animateWithDuration:0.4 animations:^{
        view.backgroundColor = color;
    }];
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior
      endedContactForItem:(id <UIDynamicItem>)item
   withBoundaryIdentifier:(id <NSCopying>)identifier
{
    NSLog(@"%@",(NSString *)identifier);
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
