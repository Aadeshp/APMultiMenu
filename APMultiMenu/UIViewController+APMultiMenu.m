//
//  UIViewController+APMultiMenu.m
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/6/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import "UIViewController+APMultiMenu.h"
#import "APMultiMenu.h"

@implementation UIViewController (APMultiMenu)

- (APMultiMenu *)sideMenuContainerViewController {
    UIViewController *container = self.parentViewController;

    while (container) {
        if ([container isKindOfClass:[APMultiMenu class]])
            return (APMultiMenu *)container;
        else if (container.parentViewController != container && container.parentViewController)
            container = container.parentViewController;
        else
            container = nil;
    }

    return nil;
    /*
    id containerView = self;
    while (![containerView isKindOfClass:[APMultiMenu class]] && containerView) {
        if ([containerView respondsToSelector:@selector(parentViewController)])
            containerView = [containerView parentViewController];
        if ([containerView respondsToSelector:@selector(splitViewController)] && !containerView)
            containerView = [containerView splitViewController];
    }
    return containerView;*/
}

- (IBAction)toggleLeftMenu:(id)sender {
    [self.sideMenuContainerViewController toggleLeftMenu];
}

- (IBAction)toggleRightMenu:(id)sender {
    [self.sideMenuContainerViewController toggleRightMenu];
}

@end
