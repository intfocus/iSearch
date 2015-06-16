//
//  UserHeadView.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "UserHeadView.h"

@implementation UserHeadView

-(void)awakeFromNib{
    UIImageView *head=self.headView;
    head.layer.cornerRadius=CGRectGetHeight(head.frame)/2;
    head.layer.borderColor=[UIColor whiteColor].CGColor;
    head.layer.borderWidth=2;
}

@end
