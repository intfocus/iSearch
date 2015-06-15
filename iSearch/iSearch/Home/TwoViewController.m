//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwoViewController.h"
#import "GMGridView.h"
#import "const.h"
#import "ViewFolder.h"
#import "ContentUtils.h"

#import "MainViewController.h"
#import "ContentViewController.h"

@interface TwoViewController ()<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString  *deptID;
@end

@implementation TwoViewController
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.deptID = @"10";
    _data = [[NSMutableArray alloc] init];
//    NSInteger i = 0;
//    for(i=0; i< 3; i++) {
//        [_data addObject:[NSString stringWithFormat:@"HomePageTwo - %ld", (long)i]];
//    }
    
    _data = [ContentUtils loadContentData:self.deptID CategoryID:@"1" Type:LOCAL_OR_SERVER_LOCAL];
    self.view.backgroundColor = [UIColor redColor];
    self.scrollView.contentSize = CGSizeMake([_data count] * (SIZE_GRID_VIEW_PAGE_WIDTH + 100), 237);
    NSLog(@"scrollView: %@",NSStringFromCGRect(self.scrollView.bounds));
    
    // GMGridView Configuration
    [self configGMGridView];
//    
//    // 耗时间的操作放在些block中
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSMutableArray *tmpArray = [ContentUtils loadContentData:self.deptID CategoryID:@"1" Type:LOCAL_OR_SERVER_SREVER];
//        if([tmpArray count]) {
//            _data = tmpArray;
//            [_gmGridView reloadData];
//        }
//    });
}

- (void) configGMGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = 50;
    _gmGridView.itemHSpacing = 50;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
    _gmGridView.backgroundColor = [UIColor clearColor];
    _gmGridView.mainSuperView = self.scrollView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    _gmGridView.tag = GridViewTwo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gmGridView = nil;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_data count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    NSMutableDictionary *currentDict = [_data objectAtIndex:index];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        ViewFolder *folder = [[[NSBundle mainBundle] loadNibNamed:@"ViewFolder" owner:self options:nil] lastObject];
        folder.labelTitle.text = [currentDict objectForKey:CONTENT_FIELD_NAME];
        [folder setImageWith:@"0" CategoryID:[currentDict objectForKey:CONTENT_FIELD_ID]];
        [folder.btnEvent addTarget:self action:@selector(helloWorld:) forControlEvents:UIControlEventTouchUpInside];
        
        //folder.btnEvent.alpha = 1;
        //[folder setFrame:CGRectMake(0, 0, 76,107)];
        [cell setContentView: folder];
    }
    
    return cell;
}

- (IBAction)helloWorld:(id)sender {
    NSLog(@"hellWorld");
    MainViewController *mainViewController = (MainViewController *)[self masterViewController];
    ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    mainViewController.rightViewController = contentViewController;

}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_data removeObjectAtIndex:index];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

/**
 *  GridView中各cell点击响应处理，
 *  如果是目录，点击cell则加载该目录下的数据结构；
 *  如果是文件，则点击cell上的功能按钮
 *
 *  @param gridView GridView
 *  @param position 该cell在GridView中的序号
 */
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    // 根据服务器返回的JSON数据显示文件夹或文档。
    NSMutableDictionary *dict = [_data objectAtIndex:position];
    NSLog(@"click %d", position);
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
    NSObject *object = [_data objectAtIndex:oldIndex];
    [_data removeObject:object];
    [_data insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_data exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


//////////////////////////////////////////////////////////////
#pragma mark DraggableGridViewTransformingDelegate
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{   //310, 310
    return CGSizeMake(150, 100);
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %ld", (long)index];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.font = [UIFont boldSystemFontOfSize:15];
    
    [fullView addSubview:label];
    
    return fullView;
}


- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor yellowColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell {}

@end