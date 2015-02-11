//
//  APMultiMenu.m
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/6/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import "APMultiMenu.h"

#define MENU_WIDTH 260
#define MENU_INDENT (260/5)
#define MENU_INDENT_DIV 5

#define CLOSED_TAG 0
#define OPEN_TAG 1

@interface APMultiMenu()

@property (nonatomic, assign, readwrite) CGFloat xPos;
@property (nonatomic, assign, readwrite) CGFloat translationLimit;

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *leftMenu;
@property (nonatomic, strong) UIView *rightMenu;

@end

@implementation APMultiMenu

#pragma mark - Constructors

- (instancetype)init {
    if (self = [super init])
        [self defaultInit];
    
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController {
    return [self initWithMainViewController:mainViewController leftMenu:leftMenuViewController rightMenu:nil];
}

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                 rightMenu:(UIViewController *)rightMenuViewController {
    return [self initWithMainViewController:mainViewController leftMenu:nil rightMenu:rightMenuViewController];
}

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController
                                 rightMenu:(UIViewController *)rightMenuViewController {
    if (self = [self init]) {
        NSParameterAssert(mainViewController);
        
        _mainViewController = mainViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    
    return self;
}

- (void)defaultInit {
    _mainView = [[UIView alloc] init];
    
    self.animationDuration = 0.4f;
    
    self.mainViewShadowEnabled = NO;
    self.mainViewShadowRadius = 4.0f;
    self.mainViewShadowOpacity = 0.8f;
    self.mainViewShadowColor = [UIColor blackColor];
    self.mainViewShadowOffset = CGSizeMake(1, 1);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.leftMenuViewController) {
        _leftMenu = self.leftMenuViewController.view;
        _leftMenu.tag = CLOSED_TAG;
        [self addViewController:self.leftMenuViewController toView:self.view];
        [self resizeView:self.leftMenuViewController menuType:APMultiMenuTypeLeftMenu];
    }
    
    if (self.rightMenuViewController) {
        _rightMenu = self.rightMenuViewController.view;
        _rightMenu.tag = CLOSED_TAG;
        [self addViewController:self.rightMenuViewController toView:self.view];
        [self resizeView:self.rightMenuViewController menuType:APMultiMenuTypeRightMenu];
    }
    
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_mainView];
    _mainView.frame = self.view.bounds;
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mainViewController.view.frame = self.view.bounds;
    [self addViewController:self.mainViewController toView:_mainView];
    
    if (_mainViewShadowEnabled)
        [self setUpShadowOnMainView];
}

#pragma mark - Change MainViewController

- (void)setMainViewController:(UIViewController *)nextVC {
    NSParameterAssert(nextVC);
    
    [self addChildViewController:nextVC];
    nextVC.view.alpha = 0;
    nextVC.view.frame = _mainView.bounds;
    [_mainView addSubview:nextVC.view];
    [self toggleLeftMenu];
    [UIView animateWithDuration:self.animationDuration animations:^{
        nextVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self removeViewControllerFromSuperView:self.mainViewController];
        
        [nextVC didMoveToParentViewController:self];
        _mainViewController = nextVC;
    }];
}

#pragma mark - Shadow On Main View

- (void)setUpShadowOnMainView {
    CALayer *layer = _mainView.layer;
    layer.shadowOffset = self.mainViewShadowOffset;
    layer.shadowColor = [self.mainViewShadowColor CGColor];
    layer.shadowRadius = self.mainViewShadowRadius;
    layer.shadowOpacity = self.mainViewShadowOpacity;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
}

#pragma mark - Add/Remove ViewControllers

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

#pragma mark - UIView Manipulation

- (void)resizeView:(UIViewController *)viewController
          menuType:(APMultiMenuType)menuType {
    UIView *view = viewController.view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    
    if (menuType == APMultiMenuTypeLeftMenu)
        view.layer.anchorPoint = CGPointMake(0, 0);
    else
        view.layer.anchorPoint = CGPointMake(1, 0);
    
    view.frame = [self getFrameFor:menuType];
    view.clipsToBounds = YES;
    [view sizeThatFits:CGSizeMake(MENU_WIDTH, self.view.frame.size.height)];
}

#pragma mark - Getters

- (CGRect)getFrameFor:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu)
        return CGRectMake(-1 * MENU_INDENT, 0, MENU_WIDTH, self.view.frame.size.height);
    else if (menuType == APMultiMenuTypeRightMenu)
        return CGRectMake(self.view.frame.size.width - MENU_WIDTH + MENU_INDENT, 0, MENU_WIDTH, self.view.frame.size.height);
    else
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"Invalid Menu Type" userInfo:nil];
}

#pragma mark - Transitions

- (void)openMenu:(APMultiMenuType)menuType {
    CGFloat main_xPos;
    
    __block NSMutableArray *blocks = [[NSMutableArray alloc] init];
    
    if (menuType == APMultiMenuTypeLeftMenu) {
        if (!_leftMenuViewController)
            return;
        
        [self.view sendSubviewToBack:_rightMenu];
        main_xPos = MENU_WIDTH;
        [blocks addObject:^{
            _leftMenu.frame = CGRectMake(0, 0, _leftMenu.frame.size.width, _leftMenu.frame.size.height);
        }];
        _leftMenu.tag = OPEN_TAG;
        
        [self isDelegateRevealMenuCalledForSideMenu:self.leftMenuViewController];
    } else {
        if (!_rightMenuViewController)
            return;
        
        [self.view sendSubviewToBack:_leftMenu];
        main_xPos = -1 * MENU_WIDTH;
        [blocks addObject:^{
            _rightMenu.frame = CGRectMake(self.view.frame.size.width - MENU_WIDTH, 0, _rightMenu.frame.size.width, _rightMenu.frame.size.height);
        }];
        _rightMenu.tag = OPEN_TAG;
        
        [self isDelegateRevealMenuCalledForSideMenu:self.rightMenuViewController];
    }
    
    [blocks addObject:^{
        _mainView.frame = CGRectMake(main_xPos, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        for (void(^block)(void) in blocks)
            block();
    }];
}

- (void)closeMenu:(APMultiMenuType)menuType {
    __block NSMutableArray *blocks = [[NSMutableArray alloc] init];
    
    if (menuType == APMultiMenuTypeLeftMenu) {
        if (!_leftMenuViewController)
            return;
        
        [self.view sendSubviewToBack:_rightMenu];
        [blocks addObject:^{
            _leftMenu.frame = CGRectMake(-1 * MENU_INDENT, 0, _leftMenu.frame.size.width, _leftMenu.frame.size.height);
        }];
        _leftMenu.tag = CLOSED_TAG;
        
        [self isDelegateHideMenuCalledForSideMenu:self.leftMenuViewController];
    } else {
        if (!_rightMenuViewController)
            return;
        
        [self.view sendSubviewToBack:_leftMenu];
        [blocks addObject:^{
            _rightMenu.frame = CGRectMake(self.view.frame.size.width - MENU_WIDTH + MENU_INDENT, 0, _rightMenu.frame.size.width, _rightMenu.frame.size.height);
        }];
        _rightMenu.tag = CLOSED_TAG;
        
        [self isDelegateHideMenuCalledForSideMenu:self.rightMenuViewController];
    }
    
    [blocks addObject:^{
        _mainView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        for (void(^block)(void) in blocks)
            block();
    }];
}

- (void)isDelegateRevealMenuCalledForSideMenu:(UIViewController *)sideMenuViewController {
    if ([self.delegate conformsToProtocol:@protocol(APMultiMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRevealSideMenu:)])
        [self.delegate sideMenu:self didRevealSideMenu:sideMenuViewController];
}

- (void)isDelegateHideMenuCalledForSideMenu:(UIViewController *)sideMenuViewController {
    if ([self.delegate conformsToProtocol:@protocol(APMultiMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didHideSideMenu:)])
        [self.delegate sideMenu:self didHideSideMenu:sideMenuViewController];
}

#pragma mark - Slide Out Menu Toggle

- (void)toggleLeftMenu {
    switch (_leftMenu.tag) {
        case CLOSED_TAG:
            [self openMenu:APMultiMenuTypeLeftMenu];
            break;
        case OPEN_TAG:
            [self closeMenu:APMultiMenuTypeLeftMenu];
            break;
    }
}

- (void)toggleRightMenu {
    switch (_rightMenu.tag) {
        case CLOSED_TAG:
            [self openMenu:APMultiMenuTypeRightMenu];
            break;
        case OPEN_TAG:
            [self closeMenu:APMultiMenuTypeRightMenu];
            break;
    }
}

#pragma mark - UIGestureRecognizer Pan

- (void)enablePanGesture {
    [_mainView addGestureRecognizer:[self panGestureRecognizer]];
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    
    return panGesture;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (velocity.x > 0) {
            if (_rightMenu.tag == CLOSED_TAG)
                [self.view sendSubviewToBack:_rightMenu];
        } else {
            if (_leftMenu.tag == CLOSED_TAG)
                [self.view sendSubviewToBack:_leftMenu];
        }
        
        [self.view endEditing:YES];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
        
        _xPos = recognizer.view.frame.origin.x + translation.x;
        NSLog(@"%f", _xPos);
        if (velocity.x > 0) {
            if (_xPos <= MENU_WIDTH && _xPos >= 0)
                [self translateLeftMenu:translation recognizer:recognizer withNewCenter:newCenter];
            else if (_xPos >= (-1 * MENU_WIDTH) && _xPos < 0)
                [self translateRightMenu:translation recognizer:recognizer withNewCenter:newCenter];
        } else if (velocity.x < 0) {
            if (_xPos <= MENU_WIDTH && _xPos >= 0)
                [self translateLeftMenu:translation recognizer:recognizer withNewCenter:newCenter];
            else if (_xPos >= (-1 * MENU_WIDTH) && _xPos < 0)
                [self translateRightMenu:translation recognizer:recognizer withNewCenter:newCenter];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            if (recognizer.view.frame.origin.x > 0)
                [self openMenu:APMultiMenuTypeLeftMenu];
            else
                [self closeMenu:APMultiMenuTypeRightMenu];
        } else {
            if (recognizer.view.frame.origin.x > 0)
                [self closeMenu:APMultiMenuTypeLeftMenu];
            else
                [self openMenu:APMultiMenuTypeRightMenu];
        }
    }
}

- (void)translateLeftMenu:(CGPoint)translation
               recognizer:(UIPanGestureRecognizer *)recognizer
            withNewCenter:(CGPoint)newCenter
{
    if (!_leftMenuViewController)
        return;
    
    _leftMenu.frame = CGRectMake(_leftMenu.frame.origin.x + translation.x / MENU_INDENT_DIV, 0, _leftMenu.frame.size.width, _leftMenu.frame.size.height);
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)translateRightMenu:(CGPoint)translation
                recognizer:(UIPanGestureRecognizer *)recognizer
             withNewCenter:(CGPoint)newCenter
{
    if (!_rightMenuViewController)
        return;
    
    _rightMenu.frame = CGRectMake(_rightMenu.frame.origin.x + translation.x / MENU_INDENT_DIV, 0, _rightMenu.frame.size.width, _rightMenu.frame.size.height);
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

@end
