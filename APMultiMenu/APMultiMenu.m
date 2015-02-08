//
//  APMultiMenu.m
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/6/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import "APMultiMenu.h"

#define MENU_WIDTH 260
#define SHADOW_RADIUS 4.0f
#define SHADOW_OPACITY 0.8f
#define ANIMATION_DURATION 0.4

#define CLOSED_TAG 0
#define OPEN_TAG 1

@interface APMultiMenu()

@property (nonatomic) BOOL showMenu;
@property (nonatomic) CGFloat gestureVelocity;

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic) UIViewController *menuContainerView;

@end

@implementation APMultiMenu

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController
                                 rightMenu:(UIViewController *)rightMenuViewController {
    if (self = [super init]) {
        //mainViewController Required
        NSParameterAssert(mainViewController);
        
        _mainViewController = mainViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
        _mainView = [[UIView alloc] init];
    }
    
    return self;
}

- (void)setMainViewController:(UIViewController *)nextVC {
    NSParameterAssert(nextVC);
    
    [self addChildViewController:nextVC];
    nextVC.view.alpha = 0;
    nextVC.view.frame = _mainView.bounds;
    [_mainView addSubview:nextVC.view];
    [self toggleLeftMenu];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        nextVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self removeViewControllerFromSuperView:self.mainViewController];
        
        [nextVC didMoveToParentViewController:self];
        _mainViewController = nextVC;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftMenuViewController.view.tag = CLOSED_TAG;
    self.rightMenuViewController.view.tag = CLOSED_TAG;
    [_mainView addGestureRecognizer:[self panGestureRecognizer]];
    // _mainView.clipsToBounds = YES;
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addViewController:self.rightMenuViewController toView:self.view];
    [self addViewController:self.leftMenuViewController toView:self.view];
    [self resizeView:self.leftMenuViewController menuType:APMultiMenuTypeLeftMenu];
    [self resizeView:self.rightMenuViewController menuType:APMultiMenuTypeRightMenu];
    
    [self.view addSubview:_mainView];
    _mainView.frame = self.view.bounds;
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addShadowToMainView];
    
    self.mainViewController.view.frame = self.view.bounds;
    [self addViewController:self.mainViewController toView:_mainView];
}

- (void)addShadowToMainView {
    CALayer *layer = _mainView.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = SHADOW_RADIUS;
    layer.shadowOpacity = SHADOW_OPACITY;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
}

- (void)addViewController:(UIViewController *)viewController
                   toView:(UIView *)view {
    [view addSubview:viewController.view];
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}

- (void)removeViewControllerFromSuperView:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)resizeView:(UIViewController *)viewController
          menuType:(APMultiMenuType)menuType {
    UIView *view = viewController.view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    view.frame = [self getFrameFor:menuType];
    view.clipsToBounds = YES;
    [view sizeThatFits:CGSizeMake(MENU_WIDTH, self.view.frame.size.height)];
}

- (CGRect)getFrameFor:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu)
        return CGRectMake(0, 0, MENU_WIDTH, self.view.frame.size.height);
    else if (menuType == APMultiMenuTypeRightMenu)
        return CGRectMake(self.view.frame.size.width - MENU_WIDTH, 0, MENU_WIDTH, self.view.frame.size.height);
    else
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"Invalid Menu Type" userInfo:nil];
}

- (void)toggleLeftMenu {
    if (!_leftMenuViewController)
        return;
    
    [self.view sendSubviewToBack:self.rightMenuViewController.view];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        switch (self.leftMenuViewController.view.tag) {
            case CLOSED_TAG:
                _mainView.frame = CGRectMake(MENU_WIDTH, 0, _mainView.frame.size.width, _mainView.frame.size.height);
                break;
            case OPEN_TAG:
                _mainView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
                break;
        }
    } completion:^(BOOL finished) {
        if (self.leftMenuViewController.view.tag == CLOSED_TAG)
            self.leftMenuViewController.view.tag = OPEN_TAG;
        else
            self.leftMenuViewController.view.tag = CLOSED_TAG;
    }];
}

- (void)toggleRightMenu {
    if (!_rightMenuViewController)
        return;
    
    [self.view sendSubviewToBack:self.leftMenuViewController.view];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        switch (self.rightMenuViewController.view.tag) {
            case CLOSED_TAG:
                _mainView.frame = CGRectMake(-1 * MENU_WIDTH, 0, _mainView.frame.size.width, _mainView.frame.size.height);
                break;
            case OPEN_TAG:
                _mainView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
                break;
        }
    } completion:^(BOOL finished) {
        if (self.rightMenuViewController.view.tag == CLOSED_TAG)
            self.rightMenuViewController.view.tag = OPEN_TAG;
        else
            self.rightMenuViewController.view.tag = CLOSED_TAG;
    }];
}

-(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

#pragma mark - UIGestureRecognizer Pan

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    
    return panGesture;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    /*    CGPoint translatedPoint = [sender translationInView:_mainView];
     CGPoint velocity = [sender velocityInView:[sender view]];*/
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[sender view]];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
    }
}

@end
