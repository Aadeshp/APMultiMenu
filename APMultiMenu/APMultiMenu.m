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

@interface APMultiMenu()

//Views
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *leftMenu;
@property (nonatomic, strong) UIView *rightMenu;

//Shadow Layer
@property (nonatomic) CALayer *shadowLayer;

//Tap Gesture
//@property (nonatomic) UITapGestureRecognizer *tapGesture;
//@property (nonatomic, assign) BOOL tapGestureEnabled;

//Swipe Gesture
//@property (nonatomic) UISwipeGestureRecognizer *leftSwipeGesture;
//@property (nonatomic) UISwipeGestureRecognizer *rightSwipeGesture;

//Pan Gesture
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign, readwrite) CGFloat xPos;

//Current Menu Status (Open/Close)
@property (nonatomic, assign, readwrite) APMultiMenuStatus leftMenuStatus;
@property (nonatomic, assign, readwrite) APMultiMenuStatus rightMenuStatus;

//Current Transition Setup
@property (nonatomic, assign, readwrite) APMultiMenuTransition currentTransition;

//Private Setup
- (void)defaultInit;
- (void)setUpViewController:(APMultiMenuViewController)viewController;
- (void)resizeView:(UIView *)view
          menuType:(APMultiMenuType)menuType;
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

//Update Methods
- (void)updateMenuFrame:(APMultiMenuType)menuType;

//Get Current Transition For Menu Type
- (APMultiMenuTransition)getTransitionForMenuType:(APMultiMenuType)menuType;

//Update Menu's Status According to Transition
- (void)setMenuStatusForTransition:(APMultiMenuTransition)transition;

//Does A Specific Menu Exist
- (BOOL)isMenuExist:(APMultiMenuType)menuType;

//Status For Menu
- (APMultiMenuStatus)getOppositeStatusFor:(APMultiMenuStatus)status;
- (BOOL)isCurrentStatusForLeftMenu:(APMultiMenuStatus)leftMenuStatus
         isRightMenuStatusOpposite:(BOOL)isOpposite;

//Delegate Helper Methods
- (void)fireDelegateMethodThatRespondsTo:(APMultiMenuTransition)transition
                              fireBefore:(BOOL)isFireBefore;
- (void)fireWillRevealMenuDelegateForViewController:(UIViewController *)sideMenuViewController;
- (void)fireDidRevealMenuDelegateForViewController:(UIViewController *)sideMenuViewController;
- (void)fireWillHideMenuDelegateForViewController:(UIViewController *)sideMenuViewController;
- (void)fireDidHideMenuDelegateForViewController:(UIViewController *)sideMenuViewController;
- (BOOL)isConformToProtocol;

//General Toggle Menu
- (void)toggleMenu:(APMultiMenuType)menuType
          animated:(BOOL)animated;

//TapGestureRecognizer Methods
/*- (UITapGestureRecognizer *)tapGestureRecognizer;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (void)enableTapGesture;
- (void)removeTapGesture;*/

//SwipeGestureRecognizer Methods
/*- (UISwipeGestureRecognizer *)swipeGestureRecognizerForMenu:(APMultiMenuType)menuType;
- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)enableSwipeGesture;
- (void)removeSwipeGesture;*/

//PanGestureRecognizer Methods
- (UIPanGestureRecognizer *)panGestureRecognizer;
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)translateMenu:(APMultiMenuType)menuType
          translation:(CGPoint)translation
           recognizer:(UIPanGestureRecognizer *)recognizer
            newCenter:(CGPoint)newCenter
           transition:(APMultiMenuTransition)transition;
- (void)translateLeftMenu:(CGPoint)translation
               recognizer:(UIPanGestureRecognizer *)recognizer
            withNewCenter:(CGPoint)newCenter;
- (void)translateRightMenu:(CGPoint)translation
                recognizer:(UIPanGestureRecognizer *)recognizer
             withNewCenter:(CGPoint)newCenter;
- (void)sendSubViewToBackForTransition:(APMultiMenuTransition)transition;
- (void)enablePanGesture;
- (void)removePanGesture;

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
    if (self = [super init])
        [self defaultInit];
    
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
        
        self.panGestureEnabled = NO;
        self.menuIndentationEnabled = NO;
        _currentTransition = APMultiMenuTransitionNone;
        
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
            [self addShadowToMainView];
    } else if (viewController == APMultiMenuViewControllerLeft) {
        if (self.leftMenuViewController) {
            _leftMenu = self.leftMenuViewController.view;
            _leftMenuStatus = APMultiMenuStatusClose;
            [self addViewController:self.leftMenuViewController toView:self.view];
            [self resizeView:_leftMenu menuType:APMultiMenuTypeLeftMenu];
        }
    } else if (viewController == APMultiMenuViewControllerRight) {
        if (self.rightMenuViewController) {
            _rightMenu = self.rightMenuViewController.view;
            _rightMenuStatus = APMultiMenuStatusClose;
            [self addViewController:self.rightMenuViewController toView:self.view];
            [self resizeView:_rightMenu menuType:APMultiMenuTypeRightMenu];
        }
    }
}

#pragma mark - Shadow On Main View

- (void)setMainViewShadowEnabled:(BOOL)mainViewShadowEnabled {
    if (_mainViewShadowEnabled == mainViewShadowEnabled)
        return;
    
    _mainViewShadowEnabled = mainViewShadowEnabled;
    
    if (mainViewShadowEnabled)
        [self addShadowToMainView];
    else
        [self removeShadowFromMainView];
}

- (void)addShadowToMainView {
    if (!_shadowLayer)
        _shadowLayer = _mainView.layer;

    _shadowLayer.shadowOffset = self.mainViewShadowOffset;
    _shadowLayer.shadowColor = [self.mainViewShadowColor CGColor];
    _shadowLayer.shadowRadius = self.mainViewShadowRadius;
    _shadowLayer.shadowOpacity = self.mainViewShadowOpacity;
    _shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:_shadowLayer.bounds] CGPath];
}

- (void)removeShadowFromMainView {
    _mainView.layer.shadowOpacity = 0.0f;
    _mainView.layer.shadowRadius = 0.0f;
    _mainView.layer.shadowOffset = CGSizeZero;
    _mainView.layer.shadowPath = nil;
}

#pragma mark - Menu Indentation

- (void)setMenuIndentationEnabled:(BOOL)menuIndentationEnabled {
    if (_menuIndentationEnabled == menuIndentationEnabled)
        return;
    
    _menuIndentationEnabled = menuIndentationEnabled;
    
    if (_leftMenuStatus == APMultiMenuStatusOpen)
        [self toggleLeftMenuWithAnimation:YES];
    else if (_rightMenuStatus == APMultiMenuStatusOpen)
        [self toggleRightMenuWithAnimation:YES];
    
    if (!menuIndentationEnabled) {
        _rightMenu.frame = [self rightMenuFrameForStatus:APMultiMenuStatusClose];
        _leftMenu.frame = [self leftMenuFrameForStatus:APMultiMenuStatusClose];
    }
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
        frame.origin.x -= kMENU_WIDTH;
    else if (position == APMultiMenuMainViewPositionRight)
        frame.origin.x += kMENU_WIDTH;
    
    return frame;
}

- (CGRect)leftMenuFrameForStatus:(APMultiMenuStatus)status {
    CGRect frame = self.view.bounds;

    frame.size.width = kMENU_WIDTH;

    if (status == APMultiMenuStatusClose && _menuIndentationEnabled)
        frame.origin.x -= kMENU_INDENT;

    return frame;
}

- (CGRect)rightMenuFrameForStatus:(APMultiMenuStatus)status {
    CGRect frame = self.view.bounds;
    frame.size.width = kMENU_WIDTH;
    frame.origin.x = self.view.frame.size.width - kMENU_WIDTH;
    
    if (status == APMultiMenuStatusClose && _menuIndentationEnabled)
        frame.origin.x += kMENU_INDENT;
    
    return frame;
}

#pragma mark - Update Methods

- (void)updateMenuFrame:(APMultiMenuType)menuType {
    if (menuType == APMultiMenuTypeLeftMenu)
        _leftMenu.frame = [self leftMenuFrameForStatus:_leftMenuStatus];
    else if (menuType == APMultiMenuTypeRightMenu)
        _rightMenu.frame = [self rightMenuFrameForStatus:_rightMenuStatus];
}

#pragma mark - UIView Manipulation

- (void)resizeView:(UIView *)view
          menuType:(APMultiMenuType)menuType {
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    
    view.autoresizesSubviews = YES;
    
    if ([self isValidMenuType:menuType]) {
        if (menuType == APMultiMenuTypeLeftMenu)
            view.frame = [self leftMenuFrameForStatus:APMultiMenuStatusClose];
        else if (menuType == APMultiMenuTypeRightMenu)
            view.frame = [self rightMenuFrameForStatus:APMultiMenuStatusClose];
    }
    
    view.clipsToBounds = YES;
    [view sizeThatFits:CGSizeMake(kMENU_WIDTH, self.view.frame.size.height)];
}

#pragma mark - Handle Rotations So Menus Don't Get Misplaced

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusOpen isRightMenuStatusOpposite:YES])
        [self toggleLeftMenuWithAnimation:NO];
    else if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusClose isRightMenuStatusOpposite:YES])
        [self toggleRightMenuWithAnimation:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateMenuFrame:APMultiMenuTypeLeftMenu];
    [self updateMenuFrame:APMultiMenuTypeRightMenu];
}

- (APMultiMenuStatus)getOppositeStatusFor:(APMultiMenuStatus)status {
    if (status == APMultiMenuStatusOpen)
        return APMultiMenuStatusClose;
    else
        return APMultiMenuStatusOpen;
}

- (BOOL)isCurrentStatusForLeftMenu:(APMultiMenuStatus)leftMenuStatus
         isRightMenuStatusOpposite:(BOOL)isOpposite {
    APMultiMenuStatus rightMenuStatus = leftMenuStatus;
    
    if (isOpposite)
        rightMenuStatus = [self getOppositeStatusFor:leftMenuStatus];
    
    return (_leftMenuStatus == leftMenuStatus && _rightMenuStatus == rightMenuStatus);
}

#pragma mark - Change MainViewController

- (void)setMainViewController:(UIViewController *)nextVC {
    NSParameterAssert(nextVC);
    
    [self.view endEditing:YES];
    [self addChildViewController:nextVC];
    nextVC.view.alpha = 0;
    nextVC.view.frame = _mainView.bounds;
    [_mainView addSubview:nextVC.view];
    
    if (_leftMenuStatus == APMultiMenuStatusOpen)
        [self toggleLeftMenuWithAnimation:YES];
    else if (_rightMenuStatus == APMultiMenuStatusOpen)
        [self toggleRightMenuWithAnimation:YES];
    
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
    if (transition == APMultiMenuTransitionToLeft) {
        _rightMenuStatus = APMultiMenuStatusOpen;
        
        if (_leftMenuStatus == APMultiMenuStatusOpen)
            [self toggleLeftMenuWithAnimation:NO];
    } else if (transition == APMultiMenuTransitionResetFromLeft)
        _rightMenuStatus = APMultiMenuStatusClose;
    else if (transition == APMultiMenuTransitionToRight) {
        _leftMenuStatus = APMultiMenuStatusOpen;
        
        if (_rightMenuStatus == APMultiMenuStatusOpen)
            [self toggleRightMenuWithAnimation:NO];
    } else if (transition == APMultiMenuTransitionResetFromRight)
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
            [self fireWillRevealMenuDelegateForViewController:[self getMenuViewControllerForTransition:transition]];
        else if (transition == APMultiMenuTransitionResetFromLeft || transition == APMultiMenuTransitionResetFromRight)
            [self fireWillHideMenuDelegateForViewController:[self getMenuViewControllerForTransition:transition]];
    } else {
        if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionToRight)
            [self fireDidRevealMenuDelegateForViewController:[self getMenuViewControllerForTransition:transition]];
        else if (transition == APMultiMenuTransitionResetFromLeft || transition == APMultiMenuTransitionResetFromRight)
            [self fireDidHideMenuDelegateForViewController:[self getMenuViewControllerForTransition:transition]];
    }
}

- (void)fireWillRevealMenuDelegateForViewController:(UIViewController *)sideMenuViewController  {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:willRevealSideMenu:)])
        [self.delegate sideMenu:self willRevealSideMenu:sideMenuViewController];
}

- (void)fireDidRevealMenuDelegateForViewController:(UIViewController *)sideMenuViewController {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:didRevealSideMenu:)])
        [self.delegate sideMenu:self didRevealSideMenu:sideMenuViewController];
}

- (void)fireWillHideMenuDelegateForViewController:(UIViewController *)sideMenuViewController {
    if ([self isConformToProtocol] && [self.delegate respondsToSelector:@selector(sideMenu:willHideSideMenu:)])
        [self.delegate sideMenu:self willHideSideMenu:sideMenuViewController];
}

- (void)fireDidHideMenuDelegateForViewController:(UIViewController *)sideMenuViewController {
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
                       if (finished) {
                           [self fireDelegateMethodThatRespondsTo:transition fireBefore:NO];
                       }
                   }];
}

- (void)toggleLeftMenuWithAnimation:(BOOL)animated {
    [self toggleMenu:APMultiMenuTypeLeftMenu animated:animated];
}

- (void)toggleRightMenuWithAnimation:(BOOL)animated {
    [self toggleMenu:APMultiMenuTypeRightMenu animated:animated];
}

#pragma mark - UITapGestureRecognizer

/*- (void)setTapGestureEnabled:(BOOL)tapGestureEnabled {
    if (_tapGestureEnabled == tapGestureEnabled)
        return;
    
    _tapGestureEnabled = tapGestureEnabled;
    
    if (tapGestureEnabled)
        [self enableTapGesture];
    else
        [self removeTapGesture];
}

- (void)enableTapGesture {
    if (!_tapGesture)
        _tapGesture = [self tapGestureRecognizer];
    
    [_mainView addGestureRecognizer:_tapGesture];
}

- (void)removeTapGesture {
    if (!_tapGesture)
        return;
    
    [_mainView removeGestureRecognizer:_tapGesture];
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    
    return tapGestureRecognizer;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (_leftMenuStatus == APMultiMenuStatusOpen)
        [self toggleLeftMenuWithAnimation:YES];
    
    if (_rightMenuStatus == APMultiMenuStatusOpen)
        [self toggleRightMenuWithAnimation:YES];
}*/

#pragma mark - UISwipeGestureRecognizer

/*- (void)setSwipeGestureEnabled:(BOOL)swipeGestureEnabled {
    if (_swipeGestureEnabled == swipeGestureEnabled)
        return;
    
    _swipeGestureEnabled = swipeGestureEnabled;
    
    if (swipeGestureEnabled)
        [self enableSwipeGesture];
    else
        [self removeSwipeGesture];
}

- (void)enableSwipeGesture {
    if (!_leftSwipeGesture)
        _leftSwipeGesture = [self swipeGestureRecognizerForMenu:APMultiMenuTypeLeftMenu];
    
    if (!_rightSwipeGesture)
        _rightSwipeGesture = [self swipeGestureRecognizerForMenu:APMultiMenuTypeRightMenu];
    
    if (_leftSwipeGesture)
        [self.view addGestureRecognizer:_leftSwipeGesture];
    
    if (_rightSwipeGesture)
        [self.view addGestureRecognizer:_rightSwipeGesture];
}

- (void)removeSwipeGesture {
    if (!_leftSwipeGesture && !_rightSwipeGesture)
        return;
    
    if (_leftSwipeGesture)
        [_mainView removeGestureRecognizer:_leftSwipeGesture];
    
    if (_rightSwipeGesture)
        [_mainView removeGestureRecognizer:_rightSwipeGesture];
}

- (UISwipeGestureRecognizer *)swipeGestureRecognizerForMenu:(APMultiMenuType)menuType {
    if (![self isValidMenuType:menuType])
        return nil;
    
    if (menuType == APMultiMenuTypeLeftMenu) {
        if (_leftMenuViewController) {
            UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
            rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            
            return rightSwipeGesture;
        } else
            return nil;
    } else if (menuType == APMultiMenuTypeRightMenu) {
        if (_rightMenuViewController) {
            UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
            leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            
            return leftSwipeGesture;
        } else
            return nil;
    } else
        return nil;
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusClose isRightMenuStatusOpposite:NO])
        [self toggleLeftMenuWithAnimation:YES];
    else if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusClose isRightMenuStatusOpposite:YES])
        [self toggleRightMenuWithAnimation:YES];
}

- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer {
    if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusOpen isRightMenuStatusOpposite:YES])
        [self toggleLeftMenuWithAnimation:YES];
    else if ([self isCurrentStatusForLeftMenu:APMultiMenuStatusClose isRightMenuStatusOpposite:NO])
        [self toggleRightMenuWithAnimation:YES];
}*/

#pragma mark - UIPanGestureRecognizer

- (void)setPanGestureEnabled:(BOOL)panGestureEnabled {
    if (_panGestureEnabled == panGestureEnabled)
        return;
    
    _panGestureEnabled = panGestureEnabled;
    
    if (panGestureEnabled)
        [self enablePanGesture];
    else
        [self removePanGesture];
}

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
       // _rightMenu.frame = [self getMenuFrameForTransition:APMultiMenuTransitionResetFromLeft];
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
            if (_xPos <= kMENU_WIDTH && _xPos >= 0)
                [self translateMenu:APMultiMenuTypeLeftMenu
                        translation:translation
                         recognizer:recognizer
                          newCenter:newCenter
                         transition:APMultiMenuTransitionToRight];
            else if (_xPos >= (-1 * kMENU_WIDTH) && _xPos < 0)
                [self translateMenu:APMultiMenuTypeRightMenu
                        translation:translation
                         recognizer:recognizer
                          newCenter:newCenter
                         transition:APMultiMenuTransitionResetFromLeft];
        } else if (velocity.x < 0) {
            if (_xPos <= kMENU_WIDTH && _xPos >= 0)
                [self translateMenu:APMultiMenuTypeLeftMenu
                        translation:translation
                         recognizer:recognizer
                          newCenter:newCenter
                         transition:APMultiMenuTransitionResetFromRight];
            else if (_xPos >= (-1 * kMENU_WIDTH) && _xPos < 0)
                [self translateMenu:APMultiMenuTypeRightMenu
                        translation:translation
                         recognizer:recognizer
                          newCenter:newCenter
                         transition:APMultiMenuTransitionToLeft];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.x >= 0 && recognizer.view.frame.origin.x <= kMENU_WIDTH)
            [self toggleLeftMenuWithAnimation:YES];
        else if (recognizer.view.frame.origin.x < 0 && recognizer.view.frame.origin.x >= -1 * kMENU_WIDTH)
            [self toggleRightMenuWithAnimation:YES];
    }
}

- (void)translateMenu:(APMultiMenuType)menuType
          translation:(CGPoint)translation
           recognizer:(UIPanGestureRecognizer *)recognizer
            newCenter:(CGPoint)newCenter
           transition:(APMultiMenuTransition)transition
{
    [self sendSubViewToBackForTransition:transition];
    
    if (menuType == APMultiMenuTypeLeftMenu)
        [self translateLeftMenu:translation
                     recognizer:recognizer
                  withNewCenter:newCenter];
    else if (menuType == APMultiMenuTypeRightMenu)
        [self translateRightMenu:translation
                      recognizer:recognizer
                   withNewCenter:newCenter];
}

- (void)translateLeftMenu:(CGPoint)translation
               recognizer:(UIPanGestureRecognizer *)recognizer
            withNewCenter:(CGPoint)newCenter
{
    if (!_leftMenuViewController)
        return;
    
    CGPoint center = _leftMenu.center;
    
    if (_menuIndentationEnabled)
        center.x += (translation.x / kMENU_INDENT_DIV);
    
    _leftMenu.center = center;
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)translateRightMenu:(CGPoint)translation
                recognizer:(UIPanGestureRecognizer *)recognizer
             withNewCenter:(CGPoint)newCenter
{
    if (!_rightMenuViewController)
        return;
    
    CGPoint center = _rightMenu.center;
    
    if (_menuIndentationEnabled)
        center.x += (translation.x / kMENU_INDENT_DIV);
    
    _rightMenu.center = center;
    
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)sendSubViewToBackForTransition:(APMultiMenuTransition)transition {
    if (_currentTransition == transition)
        return;
    
    _currentTransition = transition;
    
    if (transition == APMultiMenuTransitionToRight || transition == APMultiMenuTransitionResetFromRight) {
        if (_menuIndentationEnabled) {
            if (_rightMenu.frame.origin.x != self.view.frame.size.width - kMENU_WIDTH + kMENU_INDENT)
                _rightMenu.frame = [self rightMenuFrameForStatus:APMultiMenuStatusClose];
        } else {
            if (_rightMenu.frame.origin.x != self.view.frame.size.width - kMENU_WIDTH)
                _rightMenu.frame = [self rightMenuFrameForStatus:APMultiMenuStatusClose];
        }
        
        [self.view sendSubviewToBack:_rightMenu];
    } else if (transition == APMultiMenuTransitionToLeft || transition == APMultiMenuTransitionResetFromLeft) {
        if (_menuIndentationEnabled) {
            if (_leftMenu.frame.origin.x != -1 * kMENU_INDENT)
                _leftMenu.frame = [self leftMenuFrameForStatus:APMultiMenuStatusClose];
        } else {
            if (_leftMenu.frame.origin.x != 0)
                _leftMenu.frame = [self leftMenuFrameForStatus:APMultiMenuStatusClose];
        }
    
        [self.view sendSubviewToBack:_leftMenu];
    }
}

@end
