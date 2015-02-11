//
//  APMultiMenu.h
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/6/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+APMultiMenu.h"

@protocol APMultiMenuDelegate <NSObject>

@optional
//Occurs BEFORE Side Menu Appears
- (void)sideMenu:(APMultiMenu *)sideMenu willRevealSideMenu:(UIViewController *)sideMenuViewController;
- (void)sideMenu:(APMultiMenu *)sideMenu willHideSideMenu:(UIViewController *)sideMenuViewController;

//Occurs AFTER Side Menu Appears
- (void)sideMenu:(APMultiMenu *)sideMenu didRevealSideMenu:(UIViewController *)sideMenuViewController;
- (void)sideMenu:(APMultiMenu *)sideMenu didHideSideMenu:(UIViewController *)sideMenuViewController;

@end

typedef NS_ENUM(NSInteger, APMultiMenuType) {
    APMultiMenuTypeLeftMenu,
    APMultiMenuTypeRightMenu
};

@interface APMultiMenu : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<APMultiMenuDelegate> delegate;

@property (nonatomic, assign) BOOL mainViewShadowEnabled;
@property (nonatomic, assign) CGFloat mainViewShadowRadius;
@property (nonatomic, assign) CGFloat mainViewShadowOpacity;
@property (nonatomic, assign) CGSize mainViewShadowOffset;
@property (nonatomic, assign) UIColor *mainViewShadowColor;

@property (nonatomic, assign) CGFloat animationDuration;

//Initializations
- (instancetype)init;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                 rightMenu:(UIViewController *)rightMenuViewController;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController
                                 rightMenu:(UIViewController *)rightMenuViewController;

//Change TopViewController
- (void)setMainViewController:(UIViewController *)mainViewController;

//Open/Close Left Side Menu
- (void)toggleLeftMenu;

//Open/Close Right Side Menu
- (void)toggleRightMenu;

//Adds Pan Gesture to Main View
- (void)enablePanGesture;

@end
