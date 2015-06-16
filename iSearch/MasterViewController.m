//
//  ViewController.m
//  iSearch
//
//  Created by lijunjie on 15/5/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

/**
 *  左边导航栏选项点击响应处理
 *
 *  @param tableView ...
 *  @param indexPath 导航栏选项序号
 *
 *  @return ...
 */
- (UITableViewCell*)tableView:(UITableView *)iterateTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [iterateTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *cellTitle = nil;
    
    switch (indexPath.row) {
        case 0:
            cellTitle = @"Red";
            break;
        case 1:
            cellTitle = @"Orange";
            break;
        case 2:
            cellTitle = @"Yellow";
            break;
        case 3:
            cellTitle = @"Green";
            break;
        case 4:
            cellTitle = @"Blue";
            break;
            
        default:
            cellTitle = @"Error";
            break;
    }
    
    cell.textLabel.text = cellTitle;
    
    return cell;
}

#pragma mark - UITableViewDelegate
/**
 *  导航栏列表选项点击响应处理
 *
 *  @param iterateTableView 列表实例
 *  @param indexPath        被点击选项的在列表中的序号
 */
- (void)tableView:(UITableView *)iterateTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:NSStringFromClass([DetailViewController class]) bundle:nil];
    
    switch (indexPath.row) {
        case 0:
            detailVC.title = @"Red";
            detailVC.backgroundColor = [UIColor redColor];
            break;
        case 1:
            detailVC.title = @"Orange";
            detailVC.backgroundColor = [UIColor orangeColor];
            break;
        case 2:
            detailVC.title = @"Yellow";
            detailVC.backgroundColor = [UIColor yellowColor];
            break;
        case 3:
            detailVC.title = @"Green";
            detailVC.backgroundColor = [UIColor greenColor];
            break;
        case 4:
            detailVC.title = @"Blue";
            detailVC.backgroundColor = [UIColor blueColor];
            break;
            
        default:
            detailVC.title = @"Error";
            detailVC.backgroundColor = [UIColor whiteColor];
            break;
    }
    
    UINavigationController *detailNav = [[self.rzSplitViewController viewControllers] objectAtIndex:1];
    [detailNav setViewControllers:[NSArray arrayWithObject:detailVC] animated:YES];
    
    [iterateTableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
