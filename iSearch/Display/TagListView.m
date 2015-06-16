//
//  TagListView.m
//  iSearch
//
//  Created by lijunjie on 15/6/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagListView.h"
#import "DLRadioButton.h"
#import "ExtendNSLogFunctionality.h"
#import "FileUtils.h"

@interface TagListView()

@property (weak, nonatomic) IBOutlet UIButton *btnAddNewTag;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation TagListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *fileList = [FileUtils favoriteFileList];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSLog(@"favorite: %@", fileList);
    NSInteger index = 0;
    for (dict in fileList) {
        DLRadioButton *radioButton = [[DLRadioButton alloc] initWithFrame:CGRectMake(30, 240+40*index, self.view.frame.size.width - 60, 30)];
        radioButton.buttonSideLength = 30;
        [radioButton setTitle:dict[FILE_DESC_NAME] forState:UIControlStateNormal];
        [radioButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        radioButton.circleColor = [UIColor purpleColor];
        radioButton.indicatorColor = [UIColor purpleColor];
        radioButton.iconOnRight = YES;
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

        [self.scrollView addSubview:radioButton];
        index++;
    }
}


#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end