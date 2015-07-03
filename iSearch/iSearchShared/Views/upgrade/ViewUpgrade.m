//
//  ViewUpgrade.m
//  iSearch
//
//  Created by lijunjie on 15/7/3.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewUpgrade.h"

@interface ViewUpgrade()

@end

@implementation ViewUpgrade

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnUpgrade addTarget:self action:@selector(actionUpgrade:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - controls action
- (IBAction)actionUpgrade:(id)sender {
    NSURL *url = [NSURL URLWithString:self.insertUrl];
    [[UIApplication sharedApplication] openURL:url];
}

@end