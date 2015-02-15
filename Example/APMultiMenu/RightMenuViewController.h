//
//  RightMenuViewController.h
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/15/15.
//  Copyright (c) 2015 aadesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APMultiMenu.h>

@interface RightMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
