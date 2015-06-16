//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreeViewController.h"
#import "GMGridView.h"
#import "const.h"
#import "ViewCategory.h"

@interface ThreeViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ThreeViewController
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    _data = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for(i=0; i< 3; i++) {
        [_data addObject:[NSString stringWithFormat:@"HomePageThree - %ld", (long)i]];
    }
    
    self.scrollView.contentSize = CGSizeMake([_data count] * (SIZE_GRID_VIEW_PAGE_WIDTH + 100), 237);
    self.view.backgroundColor = [UIColor blueColor];
    NSLog(@"scrollView: %@",NSStringFromCGRect(self.scrollView.bounds));
    
    // GMGridView Configuration
    [self configGMGridView];
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
    _gmGridView.dataSource = self;
    _gmGridView.backgroundColor = [UIColor clearColor];
    _gmGridView.mainSuperView = self.scrollView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    _gmGridView.tag = GridViewThree;
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
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
        viewCategory.labelTitle.text = [_data objectAtIndex:index];
        
        [viewCategory setFrame:CGRectMake(0, 0, 76,107)];
        [cell setContentView: viewCategory];
    }
    
    return cell;
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_data removeObjectAtIndex:index];
}

@end