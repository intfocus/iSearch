//
//  MainViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_MainViewController_h
#define iSearch_MainViewController_h
#import "PopupView.h"

/**
 *  iSearch主界面, 框架为左右结构.
 *  登录成功后，进入该界面
 */
@interface MainViewController : UIViewController

- (void)hideLeftView;
- (void)showLeftView;

- (void)onEntryClick:(id)sender;
-(void)onUserHeadClick:(id)sender;

- (void)backToLoginViewController;

@end
#endif

static inline void BlockTask(dispatch_block_t block){
    static UIWindow *window=nil;
    static NSOperationQueue *queue=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue=[[NSOperationQueue alloc] init];

        NSArray *array=[[UIApplication sharedApplication] windows];
        window=[array firstObject];
    });

    NSBlockOperation *b2=[NSBlockOperation blockOperationWithBlock:^{
        PopupView *p=[[PopupView alloc] initWithFrame:window.bounds];
        NSBlockOperation *m1=[NSBlockOperation blockOperationWithBlock:^{
            [window addSubview:p];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }];
        [[NSOperationQueue mainQueue] addOperation:m1];
        block();
        NSBlockOperation *m2=[NSBlockOperation blockOperationWithBlock:^{
            [p removeFromSuperview];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //update ui;
        }];
        [[NSOperationQueue mainQueue] addOperation:m2];
    }];
    [queue addOperation:b2];
}

