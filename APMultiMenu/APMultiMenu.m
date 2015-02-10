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

#define SHADOW_RADIUS 4.0f
#define SHADOW_OPACITY 0.8f
#define ANIMATION_DURATION 0.4

#define CLOSED_TAG 0
#define OPEN_TAG 1

@interface APMultiMenu()

@property (nonatomic) CGFloat xPos;
@property (nonatomic) BOOL showPanel;
@property (nonatomic) CGFloat translationLimit;

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic, strong) UIView *mainView;

@end

@implementation APMultiMenu

#pragma mark - Constructors

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
    if (self = [super init]) {
        NSParameterAssert(mainViewController);
        
        _mainViewController = mainViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
        _mainView = [[UIView alloc] init];
    }
    
    return self;
}

#pragma mark - Change MainViewController

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
    
    if (self.leftMenuViewController) {
        self.leftMenuViewController.view.tag = CLOSED_TAG;
        [self addViewController:self.leftMenuViewController toView:self.view];
        [self resizeView:self.leftMenuViewController menuType:APMultiMenuTypeLeftMenu];
    }
    
    if (self.rightMenuViewController) {
        self.rightMenuViewController.view.tag = CLOSED_TAG;
        [self addViewController:self.rightMenuViewController toView:self.view];
        [self resizeView:self.rightMenuViewController menuType:APMultiMenuTypeRightMenu];
    }
    
    [_mainView addGestureRecognizer:[self panGestureRecognizer]];
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
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
        
        [self.view sendSubviewToBack:self.rightMenuViewController.view];
        main_xPos = MENU_WIDTH;
        [blocks addObject:^{
            _leftMenuViewController.view.frame = CGRectMake(0, 0, _leftMenuViewController.view.frame.size.width, _leftMenuViewController.view.frame.size.height);
        }];
        self.leftMenuViewController.view.tag = OPEN_TAG;
    } else {
        if (!_rightMenuViewController)
            return;
        
        [self.view sendSubviewToBack:self.leftMenuViewController.view];
        main_xPos = -1 * MENU_WIDTH;
        [blocks addObject:^{
            _rightMenuViewController.view.frame = CGRectMake(self.view.frame.size.width - MENU_WIDTH, 0, _rightMenuViewController.view.frame.size.width, _rightMenuViewController.view.frame.size.height);
        }];
        self.rightMenuViewController.view.tag = OPEN_TAG;
    }
    
    [blocks addObject:^{
        _mainView.frame = CGRectMake(main_xPos, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        for (void(^block)(void) in blocks)
            block();
    }];
}

- (void)closeMenu:(APMultiMenuType)menuType {
    __block NSMutableArray *blocks = [[NSMutableArray alloc] init];
    
    if (menuType == APMultiMenuTypeLeftMenu) {
        if (!_leftMenuViewController)
            return;
        
        [self.view sendSubviewToBack:self.rightMenuViewController.view];
        [blocks addObject:^{
            _leftMenuViewController.view.frame = CGRectMake(-1 * MENU_INDENT, 0, _leftMenuViewController.view.frame.size.width, _leftMenuViewController.view.frame.size.height);
        }];
        self.leftMenuViewController.view.tag = CLOSED_TAG;
    } else {
        if (!_rightMenuViewController)
            return;
        
        [self.view sendSubviewToBack:self.leftMenuViewController.view];
        [blocks addObject:^{
            _rightMenuViewController.view.frame = CGRectMake(self.view.frame.size.width - MENU_WIDTH + MENU_INDENT, 0, _rightMenuViewController.view.frame.size.width, _rightMenuViewController.view.frame.size.height);
        }];
        self.rightMenuViewController.view.tag = CLOSED_TAG;
    }
    
    [blocks addObject:^{
        _mainView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    }];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        for (void(^block)(void) in blocks)
            block();
    }];
}

#pragma mark - Slide Out Menu Toggle

- (void)toggleLeftMenu {
    switch (self.leftMenuViewController.view.tag) {
        case CLOSED_TAG:
            [self openMenu:APMultiMenuTypeLeftMenu];
            break;
        case OPEN_TAG:
            [self closeMenu:APMultiMenuTypeLeftMenu];
            break;
    }
}

- (void)toggleRightMenu {
    switch (self.rightMenuViewController.view.tag) {
        case CLOSED_TAG:
            [self openMenu:APMultiMenuTypeRightMenu];
            break;
        case OPEN_TAG:
            [self closeMenu:APMultiMenuTypeRightMenu];
            break;
    }
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
    CGPoint velocity = [sender velocityInView:[sender view]];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (velocity.x > 0) {
            if (_rightMenuViewController.view.tag == CLOSED_TAG)
                [self.view sendSubviewToBack:_rightMenuViewController.view];
        } else {
            if (_leftMenuViewController.view.tag == CLOSED_TAG)
                [self.view sendSubviewToBack:_leftMenuViewController.view];
        }
        
        [self.view endEditing:YES];
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.view];
        CGPoint newCenter = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y);
        
        _xPos = newCenter.x - (self.view.frame.size.width / 2);
        
        if (((velocity.x > 0)
             && (_leftMenuViewController.view.tag == CLOSED_TAG && (_xPos <= MENU_WIDTH && _xPos >= 0)))
            || ((velocity.x < 0)
                && (_leftMenuViewController.view.tag == OPEN_TAG || (_xPos <= MENU_WIDTH && _xPos >= 0))))
        {
            _leftMenuViewController.view.frame = CGRectMake(_leftMenuViewController.view.frame.origin.x + translation.x / MENU_INDENT_DIV, 0, _leftMenuViewController.view.frame.size.width, _leftMenuViewController.view.frame.size.height);
        }
        
        if (((velocity.x < 0)
             && (_rightMenuViewController.view.tag == CLOSED_TAG && (_xPos >= (-1 * MENU_WIDTH) && _xPos < 0)))
            || ((velocity.x > 0)
                && (_rightMenuViewController.view.tag == OPEN_TAG || (_xPos >= (-1 * MENU_WIDTH) && _xPos < 0)))) {
                _rightMenuViewController.view.frame = CGRectMake(_rightMenuViewController.view.frame.origin.x + translation.x / MENU_INDENT_DIV, 0, _rightMenuViewController.view.frame.size.width, _rightMenuViewController.view.frame.size.height);
            }
        
        if (((velocity.x > 0)
             && ((_leftMenuViewController.view.tag == CLOSED_TAG && _xPos <= MENU_WIDTH)
                 || _rightMenuViewController.view.tag == OPEN_TAG))
            || ((velocity.x < 0)
                && ((_rightMenuViewController.view.tag == CLOSED_TAG && _xPos >= (-1 * MENU_WIDTH))
                    || _leftMenuViewController.view.tag == OPEN_TAG)))
        {
            sender.view.center = newCenter;
            [sender setTranslation:CGPointZero inView:self.view];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            if (_xPos > 0)
                [self openMenu:APMultiMenuTypeLeftMenu];
            else
                [self closeMenu:APMultiMenuTypeRightMenu];
        } else {
            if (_xPos > 0)
                [self closeMenu:APMultiMenuTypeLeftMenu];
            else
                [self openMenu:APMultiMenuTypeRightMenu];
        }
    }
}

@end
