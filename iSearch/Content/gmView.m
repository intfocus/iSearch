//
//  gmView.m
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gmView.h"
#import "GMGridView.h"

#define NUMBER_ITEMS_ON_LOAD 250
#define NUMBER_ITEMS_ON_LOAD2 30
@interface gmView () <GMGridViewDataSource, GMGridViewSortingDelegate>
{
    __gm_weak GMGridView *_gridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
    
    NSMutableArray *_dataList;
    NSMutableArray *_data2;
    __gm_weak NSMutableArray *_currentData;
    NSInteger _lastDeleteItemIndexAsked;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // 目录结构图
@property (weak, nonatomic) IBOutlet UIButton *btnRandom; // 目录结构图
- (void)addMoreItem;
- (void)removeItem;
- (void)refreshItem;
- (void)presentInfo;
- (void)presentOptions:(UIBarButtonItem *)barButton;

- (void)optionsDoneAction;
- (void)dataSetChange:(UISegmentedControl *)control;

@end


//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController implementation
//////////////////////////////////////////////////////////////

@implementation gmView
//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSInteger spacing = 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingNone;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:gmGridView];
    _gridView = gmGridView;
    
    _gridView.style = GMGridViewStylePush;
    _gridView.itemSpacing = spacing;
    _gridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gridView.centerGrid = YES;
    _gridView.sortingDelegate = self;
    _gridView.dataSource = self;
    
    _gridView.mainSuperView = self.scrollView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    [self.btnRandom addTarget:self action:@selector(actionRandom:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _gridView = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)actionRandom:(UIButton *)sender {
     int value = (arc4random() % 20) + 1;
    _dataList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < value; i ++)
    {
        [_dataList addObject:[NSString stringWithFormat:@"A %d", i]];
    }
    _currentData = _dataList;
    [_gridView reloadData];
    [self.btnRandom setTitle:[NSString stringWithFormat:@"%ld", (long)value] forState:UIControlStateNormal];
}
//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}

//////////////////////////////////////////////////////////////
#pragma mark orientation management
//////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_currentData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(140, 110);

}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor redColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = (NSString *)[_currentData objectAtIndex:index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    [cell.contentView addSubview:label];
    NSLog(@"%@", label.text);
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [_currentData objectAtIndex:oldIndex];
    [_currentData removeObject:object];
    [_currentData insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

//////////////////////////////////////////////////////////////
#pragma mark private methods
//////////////////////////////////////////////////////////////

- (void)addMoreItem
{
    // Example: adding object at the last position
    NSString *newItem = [NSString stringWithFormat:@"%d", (int)(arc4random() % 1000)];
    
    [_currentData addObject:newItem];
    [_gridView insertObjectAtIndex:[_currentData count] - 1 withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
}

- (void)removeItem
{
    // Example: removing last item
    if ([_currentData count] > 0)
    {
        NSInteger index = [_currentData count] - 1;
        
        [_gridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        [_currentData removeObjectAtIndex:index];
    }
}

- (void)refreshItem
{
    // Example: reloading last item
    if ([_currentData count] > 0)
    {
        int index = [_currentData count] - 1;
        
        NSString *newMessage = [NSString stringWithFormat:@"%d", (arc4random() % 1000)];
        
        [_currentData replaceObjectAtIndex:index withObject:newMessage];
        [_gridView reloadObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    }
}

- (void)presentInfo
{
    NSString *info = @"Long-press an item and its color will change; letting you know that you can now move it around. \n\nUsing two fingers, pinch/drag/rotate an item; zoom it enough and you will enter the fullsize mode";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)dataSetChange:(UISegmentedControl *)control
{
    _currentData = ([control selectedSegmentIndex] == 0) ? _dataList : _data2;
    
    [_gridView reloadData];
}

- (void)presentOptions:(UIBarButtonItem *)barButton
{
}

- (void)optionsDoneAction
{
   
}

@end
