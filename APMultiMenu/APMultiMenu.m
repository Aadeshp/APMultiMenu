//
// APMultiMenu.m
// APMultiMenu
//
// Copyright (c) 2015 Aadesh Patel <aadeshp95@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "APMultiMenu.h"
#import "APMultiMenuConstants.h"

#define MENU_WIDTH 260
#define MENU_INDENT (260/5)
#define MENU_INDENT_DIV 5

#define CLOSED_TAG 0
#define OPEN_TAG 1

@interface APMultiMenu()

@property (nonatomic, assign, readwrite) CGFloat xPos;
@property (nonatomic) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, readonly) CGRect mainViewOriginalFrame;
@property (nonatomic, readonly) CGRect mainViewLeftMenuRevealedFrame;
@property (nonatomic, readonly) CGRect mainViewRightMenuRevealedFrame;

@property (nonatomic, strong) UIView *leftMenu;
@property (nonatomic, assign, readwrite) APMultiMenuStatus leftMenuStatus;

@property (nonatomic, strong) UIView *rightMenu;
@property (nonatomic, assign, readwrite) APMultiMenuStatus rightMenuStatus;

- (void)defaultInit;
- (void)setUpViewController:(APMultiMenuViewController)viewController;
- (void)resizeView:(UIViewController *)viewController
          menuType:(APMultiMenuType)menuType;
- (void)setUpShadowOnMainView;
- (void)addViewController:(UIViewController *)viewController
                   toView:(UIView *)view;
- (void)removeViewControllerFromSuperView:(UIViewController *)viewController;

//Get Frame For Position/Status
- (CGRect)mainViewFrameForPosition:(APMultiMenuMainViewPosition)position;
- (CGRect)leftMenuFrameForStatus:(APMultiMenuStatus)status;
- (CGRect)rightMenuFrameForStatus:(APMultiMenuStatus)status;

//Typedef ENUM Validation
- (BOOL)isValidStatus:(APMultiMenuStatus)status;
- (BOOL)isValidMainViewPosition:(APMultiMenuMainViewPosition)position;
- (BOOL)isValidTransition:(APMultiMenuTransition)transition;
- (BOOL)isValidMenuType:(APMultiMenuType)menuType;

//Get Frame/View/ViewController For Transition
- (CGRect)getMainViewFrameForTransition:(APMultiMenuTransition)transition;
- (CGRect)getMenuFrameForTransition:(APMultiMenuTransition)transition;
- (UIView *)getMenuViewForTransition:(APMultiMenuTransition)transition;
- (UIViewController *)getMenuViewControllerForTransition:(APMultiMenuTransition)transition;

//Get Current Transition For Menu Type
- (APMultiMenuTransition)getTransitionForMenuType:(APMultiMenuType)menuType;

//Update Menu's Status According to Transition
- (void)setMenuStatusForTransition:(APMultiMenuTransition)transition;

- (BOOL)isMenuExist:(APMultiMenuType)menuType;

//Delegate Helper Methods
- (void)fireDelegateMethodThatRespondsTo:(APMultiMenuTransition)transition
                              fireBefore:(BOOL)isFireBefore;
- (void)fireWillRevealMenuDelegateForTransition:(UIViewController *)sideMenuViewController;
- (void)fireDidRevealMenuDelegateForTransition:(UIViewController *)sideMenuViewController;
- (void)fireWillHideMenuDelegateForTransition:(UIViewController *)sideMenuViewController;
- (void)fireDidHideMenuDelegateForTransition:(UIViewController *)sideMenuViewController;
- (BOOL)isConformToProtocol;

//General Toggle Menu
- (void)toggleMenu:(APMultiMenuType)menuType
          animated:(BOOL)animated;

//PanGestureRecognizer Methods
- (UIPanGestureRecognizer *)panGestureRecognizer;
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)translateLeftMenu:(CGPoint)translation
               recognizer:(UIPanGestureRecognizer *)recognizer
            withNewCenter:(CGPoint)newCenter;
- (void)translateRightMenu:(CGPoint)translation
                recognizer:(UIPanGestureRecognizer *)recognizer
             withNewCenter:(CGPoint)newCenter;
@end

@implementation APMultiMenu

#pragma mark - Constructors

- (void)awakeFromNib {
    if (self.mainViewControllerStoryboardID)
        self.mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.mainViewControllerStoryboardID];
    
    if (self.leftMenuViewControllerStoryboardID)
        self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.leftMenuViewControllerStoryboardID];
    
    if (self.rightMenuViewControllerStoryboardID)
        self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.rightMenuViewControllerStoryboardID];
}

- (instancetype)init {
    if (self = [super init]) {
        [self defaultInit];
    }
    
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController {
    return [self initWithMainViewController:mainViewController
                                   leftMenu:leftMenuViewController
                                  rightMenu:nil];
}

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                 rightMenu:(UIViewController *)rightMenuViewController {
    return [self initWithMainViewController:mainViewController
                                   leftMenu:nil
                                  rightMenu:rightMenuViewController];
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
    
    [self setUpViewController:APMultiMenuViewControllerLeft];
    [self setUpViewController:APMultiMenuViewControllerRight];
    
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mainView];
    _mainView.frame = self.view.bounds;
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self setUpViewController:APMultiMenuViewControllerMain];
}

- (void)setUpViewController:(APMultiMenuViewController)viewController {
    if (viewController == APMultiMenuViewControllerMain) {
        self.mainViewController.view.frame = [self mainViewFrameForPosition:APMultiMenuMainViewPositionDefault];
        [self addViewController:self.mainViewController toView:_mainView];
        
        if (_mainViewShadowEnabled)
            [self setUpShadowOnMainView];
    } else if (viewController == APMultiMenuViewControllerLeft) {
        if (self.leftMenuViewController) {
            _leftMenu = self.leftMenuViewController.view;
            _leftMenuStatus = APMultiMenuStatusClose;
            _leftMenu.tag = CLOSED_TAG;
            [self addViewController:self.leftMenuViewController toView:self.view];
            [self resizeView:self.leftMenuViewController menuType:APMultiMenuTypeLeftMenu];
        }
    } else if (viewController == APMultiMenuViewControllerRight) {
        if (self.rightMenuViewController) {
            _rightMenu = self.rightMenuViewController.view;
            _rightMenuStatus = APMultiMenuStatusClose;
            _rightMenu.tag = CLOSED_TAG;
            [self addViewController:self.rightMenuViewController toView:self.view];
            [self resizeView:self.rightMenuViewController menuType:APMultiMenuTypeRightMenu];
        }
    }
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


#pragma mark - Get Frames

- (CGRect)mainViewFrameForPosition:(APMultiMenuMainViewPosition)position {
    CGRect frame = self.view.bounds;
    
    if (position == APMultiMenuMainViewPositionLeft)
        frame.origin.x -= MENU_WIDTH;
    else if (position == APMultiMenuMainViewPositionRight)
        frame.origin.x += MENU_WIDTH;
    
    return frame;
}

- (CGRect)leftMenuFrameForStatus:(APMultiMenuStatus)status {
    CGRect frame = self.view.bounds;
    frame.size.width = MENU_WIDTH;
    
    if (status == APMultiMenuStatusClose)
        frame.origin.x -= MENU_INDENT;
    
    return frame;
}

- (CGRect)rightMenuFrameForStatus:(APMultiMenuStatus)status {
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width - MENU_WIDTH;
    frame.size.width = MENU_WIDTH;
    
    if (status == APMultiMenuStatusClose)
        frame.origin.x += MENU_INDENT;
    
    return frame;
}

#pragma mark - UIView Manipulation

- (void)resizeView:(UIViewController *)viewController
          menuType:(APMultiMenuType)menuType {
    UIView *view = viewController.view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    
    if ([self isValidMenuType:menuType])
        view.frame = menuType == APMultiMenuTypeLeftMenu ? [self leftMenuFrameForStatus:APMultiMenuStatusClose] : [self rightMenuFrameForStatus:APMultiMenuStatusClose];
    
    view.clipsToBounds = YES;
    [view sizeThatFits:CGSizeMake(MENU_WIDTH, self.view.frame.size.height)];
}

#pragma mark - Change MainViewController

- (void)setMainViewController:(UIViewController *)nextVC {
    NSParameterAssert(nextVC);
    
    [self.view endEditing:YES];
    [self addChildViewController:nextVC];
    nextVC.view.alpha = 0;
    nextVC.view.frame = _mainView.bounds;
    [_mainView addSubview:nextVC.view];
    [self toggleLeftMenuWithAnimation:YES];
    [UIView animateWithDuration:self.animationDuration animations:^{
        nextVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self removeViewControllerFromSuperView:self.mainViewController];
        
        [nextVC didMoveToParentViewController:self];
        _mainViewController = nextVC;
    }];
}

#pragma mark - Typedef ENUM Validation Methods

- (BOOL)isValidStatus:(APMultiMenuStatus)status {
    if (status == APMultiMenuStatusOpen || status == APMultiMenuStatusClose)
        return YES;
    
    return NO;
}

- (BOOL)isValidMainViewPosition:(APMultiMenuMainViewPosition)position {
    if (position == APMultiMenuMainViewPositionDefault || position == APMultiMenuMainViewPositionLeft || position == APMultiMenuMainViewPositionRight)
        return YES;
    
    return NO;
}

- (BOOL)isValidTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionResetFromLeft || transition == APMultiMenuTransitionResetFromRight || transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionToRight)
        return YES;
    
    return NO;
}

- (BOOL)isValidMenuType:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu || menuType == APMultiMenuTypeRightMenu)
        return YES;
    
    return NO;
}

#pragma mark - Transition Getters

- (CGRect)getMainViewFrameForTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionToLeft)
        return [self mainViewFrameForPosition:APMultiMenuMainViewPositionLeft];
    else if (transition == APMultiMenuTransitionToRight)
        return [self mainViewFrameForPosition:APMultiMenuMainViewPositionRight];
    else
        return [self mainViewFrameForPosition:APMultiMenuMainViewPositionDefault];
}

- (CGRect)getMenuFrameForTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionToLeft)
        return [self rightMenuFrameForStatus:APMultiMenuStatusOpen];
    else if (transition == APMultiMenuTransitionResetFromLeft)
        return [self rightMenuFrameForStatus:APMultiMenuStatusClose];
    else if (transition == APMultiMenuTransitionToRight)
        return [self leftMenuFrameForStatus:APMultiMenuStatusOpen];
    else if (transition == APMultiMenuTransitionResetFromRight)
        return [self leftMenuFrameForStatus:APMultiMenuStatusClose];
    else
        return CGRectZero;
}

- (UIView *)getMenuViewForTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionResetFromLeft) {
        [self.view sendSubviewToBack:_leftMenu];
        return _rightMenu;
    } else if (transition == APMultiMenuTransitionToRight || transition == APMultiMenuTransitionResetFromRight) {
        [self.view sendSubviewToBack:_rightMenu];
        return _leftMenu;
    } else
        return nil;
}

- (UIViewController *)getMenuViewControllerForTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionResetFromLeft)
        return self.rightMenuViewController;
    else if (transition == APMultiMenuTransitionToRight || transition == APMultiMenuTransitionResetFromRight)
        return self.leftMenuViewController;
    else
        return nil;
}

#pragma mark - Get Transition For Menu

- (APMultiMenuTransition)getTransitionForMenuType:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu) {
        if (_leftMenuStatus == APMultiMenuStatusOpen)
            return APMultiMenuTransitionResetFromRight;
        else
            return APMultiMenuTransitionToRight;
    } else {
        if (_rightMenuStatus == APMultiMenuStatusOpen)
            return APMultiMenuTransitionResetFromLeft;
        else
            return APMultiMenuTransitionToLeft;
    }
}

#pragma mark - Set Current Menu Status

- (void)setMenuStatusForTransition:(APMultiMenuTransition)transition {
    if (transition == APMultiMenuTransitionToLeft)
        _rightMenuStatus = APMultiMenuStatusOpen;
    else if (transition == APMultiMenuTransitionResetFromLeft)
        _rightMenuStatus = APMultiMenuStatusClose;
    else if (transition == APMultiMenuTransitionToRight)
        _leftMenuStatus = APMultiMenuStatusOpen;
    else if (transition == APMultiMenuTransitionResetFromRight)
        _leftMenuStatus = APMultiMenuStatusClose;
}


#pragma mark - Does Menu Type Exist

- (BOOL)isMenuExist:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu)
        return _leftMenuViewController != nil;
    else
        return _rightMenuViewController != nil;
}


#pragma mark - Fire Delegate Methods

- (void)fireDelegateMethodThatRespondsTo:(APMultiMenuTransition)transition
                              fireBefore:(BOOL)isFireBefore {
    if (isFireBefore) {
        if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionToRight)
            [self fireWillRevealMenuDelegateForTransition:[self getMenuViewControllerForTransition:transition]];
        else if (transition == APMultiMenuTransitionResetFromLeft || transition == APMultiMenuTransitionResetFromRight)
            [self fireWillHideMenuDelegateForTransition:[self getMenuViewControllerForTransition:transition]];
    } else {
        if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionToRight)
            [self fireDidRevealMenuDelegateForTransition:[self getMenuViewControllerForTransition:transition]];
        else if (transition == APMultiMenuTransitionResetFromLeft || transition == APMultiMenuTransitionResetFromRight)
            [self fireDidHideMenuDelegateForTransition:[self getMenuViewControllerForTransition:transition]];
    }
}

- (void)fireWillRevealMenuDelegateForTransition:(UIViewController *)sideMenuViewController  {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:willRevealSideMenu:)])
        [self.delegate sideMenu:self willRevealSideMenu:sideMenuViewController];
}

- (void)fireDidRevealMenuDelegateForTransition:(UIViewController *)sideMenuViewController {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:didRevealSideMenu:)])
        [self.delegate sideMenu:self didRevealSideMenu:sideMenuViewController];
}

- (void)fireWillHideMenuDelegateForTransition:(UIViewController *)sideMenuViewController {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:willHideSideMenu:)])
        [self.delegate sideMenu:self willHideSideMenu:sideMenuViewController];
}

- (void)fireDidHideMenuDelegateForTransition:(UIViewController *)sideMenuViewController {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:didHideSideMenu:)])
        [self.delegate sideMenu:self didHideSideMenu:sideMenuViewController];
}

#pragma mark - Delegate Helper

- (BOOL)isConformToProtocol {
    return [self.delegate conformsToProtocol:@protocol(APMultiMenuDelegate)];
}

#pragma mark - Transition

- (void)beginTransitionWith:(APMultiMenuTransition)transition
                   animated:(BOOL)animated
                 completion:(void(^)(BOOL))completion {
    if (![self isValidTransition:transition])
        return;
    
    [self.view endEditing:YES];
    [self fireDelegateMethodThatRespondsTo:transition fireBefore:YES];
    [self setMenuStatusForTransition:transition];
    
    UIView *menuView = [self getMenuViewForTransition:transition];
    
    if (!animated) {
        menuView.frame = [self getMenuFrameForTransition:transition];
        _mainView.frame = [self getMainViewFrameForTransition:transition];
    } else {
        [UIView animateWithDuration:self.animationDuration animations:^{
            menuView.frame = [self getMenuFrameForTransition:transition];
            _mainView.frame = [self getMainViewFrameForTransition:transition];
        } completion:completion];
    }
}

#pragma mark - Open/Close Menu

- (void)toggleMenu:(APMultiMenuType)menuType
          animated:(BOOL)animated {
    if (![self isValidMenuType:menuType] || ![self isMenuExist:menuType])
        return;
    
    APMultiMenuTransition transition = [self getTransitionForMenuType:menuType];
    [self beginTransitionWith:transition
                     animated:animated
                   completion:^(BOOL finished) {
                       [self fireDelegateMethodThatRespondsTo:transition fireBefore:NO];
                   }];
}

- (void)toggleLeftMenuWithAnimation:(BOOL)animated {
    [self toggleMenu:APMultiMenuTypeLeftMenu animated:animated];
}

- (void)toggleRightMenuWithAnimation:(BOOL)animated {
    [self toggleMenu:APMultiMenuTypeRightMenu animated:animated];
}

#pragma mark - UIGestureRecognizer Pan

- (void)enablePanGesture {
    if (!_panGesture)
        _panGesture = [self panGestureRecognizer];
    
    [_mainView addGestureRecognizer:_panGesture];
}

- (void)removePanGesture {
    if (!_panGesture)
        return;
    
    [_mainView removeGestureRecognizer:_panGesture];
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
            if (_rightMenuStatus == APMultiMenuStatusClose)
                [self.view sendSubviewToBack:_rightMenu];
        } else {
            if (_leftMenuStatus == APMultiMenuStatusClose)
                [self.view sendSubviewToBack:_leftMenu];
        }
        
        [self.view endEditing:YES];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
        
        _xPos = recognizer.view.frame.origin.x + translation.x;
        
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
        if (recognizer.view.frame.origin.x > 0)
            [self toggleMenu:APMultiMenuTypeLeftMenu animated:YES];
        else if (recognizer.view.frame.origin.x < 0)
            [self toggleMenu:APMultiMenuTypeRightMenu animated:YES];
    }
}

- (void)translateLeftMenu:(CGPoint)translation
               recognizer:(UIPanGestureRecognizer *)recognizer
            withNewCenter:(CGPoint)newCenter
{
    if (!_leftMenuViewController)
        return;
    
    [self.view sendSubviewToBack:_rightMenu];
    if (_rightMenu.frame.origin.x != self.view.frame.size.width - MENU_WIDTH + MENU_INDENT)
        _rightMenu.frame = [self rightMenuFrameForStatus:APMultiMenuStatusClose];
    
    _leftMenu.center = CGPointMake(_leftMenu.center.x + translation.x / MENU_INDENT_DIV, _leftMenu.center.y);
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)translateRightMenu:(CGPoint)translation
                recognizer:(UIPanGestureRecognizer *)recognizer
             withNewCenter:(CGPoint)newCenter
{
    if (!_rightMenuViewController)
        return;
    
    [self.view sendSubviewToBack:_leftMenu];
    if (_leftMenu.frame.origin.x != -1 * MENU_INDENT)
        _leftMenu.frame = [self leftMenuFrameForStatus:APMultiMenuStatusClose];
    
    _rightMenu.center = CGPointMake(_rightMenu.center.x + translation.x / MENU_INDENT_DIV, _rightMenu.center.y);
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

@end
