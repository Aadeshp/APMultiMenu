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

@required
- (void)toggleLeftMenu;

@end

typedef enum {
    APMultiMenuTypeLeftMenu,
    APMultiMenuTypeRightMenu
} APMultiMenuType;

@interface APMultiMenu : UIViewController <UIGestureRecognizerDelegate, APMultiMenuDelegate>

@property (nonatomic, weak) id<APMultiMenuDelegate> delegate;
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                                  leftMenu:(UIViewController *)leftMenuViewController
                                 rightMenu:(UIViewController *)rightMenuViewController;

- (void)setMainViewController:(UIViewController *)mainViewController;

- (void)toggleLeftMenu;
- (void)toggleRightMenu;

@end


