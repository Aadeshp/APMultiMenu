//
//  MainViewController.m
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/15/15.
//  Copyright (c) 2015 aadesh. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftMenu:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:self action:@selector(toggleRightMenu:)];
}

@end
