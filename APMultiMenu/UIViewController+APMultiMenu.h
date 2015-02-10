//
//  UIViewController+APMultiMenu.h
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/6/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APMultiMenu;

@interface UIViewController (APMultiMenu)

@property (nonatomic, strong) APMultiMenu *sideMenuContainerViewController;

- (IBAction)toggleLeftMenu:(id)sender;
- (IBAction)toggleRightMenu:(id)sender;

@end
