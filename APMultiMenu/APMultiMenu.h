//
// APMultiMenu.h
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

#import <UIKit/UIKit.h>
#import "UIViewController+APMultiMenu.h"
#import "APMultiMenuConstants.h"

@protocol APMultiMenuDelegate <NSObject>

@optional
//Occurs BEFORE Side Menu Appears
- (void)sideMenu:(APMultiMenu *)sideMenu willRevealSideMenu:(UIViewController *)sideMenuViewController;
- (void)sideMenu:(APMultiMenu *)sideMenu willHideSideMenu:(UIViewController *)sideMenuViewController;

//Occurs AFTER Side Menu Appears
- (void)sideMenu:(APMultiMenu *)sideMenu didRevealSideMenu:(UIViewController *)sideMenuViewController;
- (void)sideMenu:(APMultiMenu *)sideMenu didHideSideMenu:(UIViewController *)sideMenuViewController;

@end

@interface APMultiMenu : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<APMultiMenuDelegate> delegate;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic) NSString *mainViewControllerStoryboardID;
@property (nonatomic) NSString *leftMenuViewControllerStoryboardID;
@property (nonatomic) NSString *rightMenuViewControllerStoryboardID;

//Shadow Variables
@property (nonatomic, assign) BOOL mainViewShadowEnabled;
@property (nonatomic, assign) CGFloat mainViewShadowRadius;
@property (nonatomic, assign) CGFloat mainViewShadowOpacity;
@property (nonatomic, assign) CGSize mainViewShadowOffset;
@property (nonatomic, assign) UIColor *mainViewShadowColor;

//Animation Variables
@property (nonatomic, assign) BOOL menuIndentationEnabled;
@property (nonatomic, assign) CGFloat animationDuration;

//PanGesture Variables
@property (nonatomic, assign) BOOL panGestureEnabled;
//@property (nonatomic, assign) BOOL swipeGestureEnabled;

//Initializations
- (instancetype)init;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                 rightMenu:(UIViewController *)rightMenuViewController;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController
                                 rightMenu:(UIViewController *)rightMenuViewController;

//Change MainViewController
- (void)setMainViewController:(UIViewController *)mainViewController;

//Toggle Left Menu
- (void)toggleLeftMenuWithAnimation:(BOOL)animated;

//Toggle Right Menu
- (void)toggleRightMenuWithAnimation:(BOOL)animated;

//Transition Menu Based on the APMultiMenuTransition Given
- (void)beginTransitionWith:(APMultiMenuTransition)transition
                   animated:(BOOL)animated
                 completion:(void(^)(BOOL))completion;

@end
