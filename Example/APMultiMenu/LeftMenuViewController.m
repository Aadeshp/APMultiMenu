//
//  LeftMenuViewController.m
//  APMultiMenu
//
//  Created by Aadesh Patel on 2/15/15.
//  Copyright (c) 2015 aadesh. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController()

@property (nonatomic) NSArray *tableElements;

@end
@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableElements = [[NSArray alloc] initWithObjects:@"Home", @"Contacts", @"Settings", @"Logout", nil];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableElements count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_tableElements objectAtIndex:indexPath.row] isEqualToString:@"Home"])
        [self.sideMenuContainerViewController setMainViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainVC"]];
    else
        [self.sideMenuContainerViewController setMainViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FirstView"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LeftMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [_tableElements objectAtIndex:indexPath.row];
    
    return cell;
}

@end
