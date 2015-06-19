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
    self.heightConstraint.constant = 0.5;
    self.heightConstraint2.constant = 0.5;
}

@end
