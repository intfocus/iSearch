//
//  MainEntryButton.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "MainEntryButton.h"

@implementation MainEntryButton

- (void)awakeFromNib{
    [super awakeFromNib];
//    self.heightConstraint.constant = 0.5;
//    self.heightConstraint2.constant = 0.5;
    UIView *darkSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 1)];
    darkSeparator.backgroundColor = [UIColor blackColor];
    [self addSubview:darkSeparator];
    UIView *lightSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
    lightSeparator.backgroundColor = [UIColor grayColor];
    [self addSubview:lightSeparator];
}

@end
