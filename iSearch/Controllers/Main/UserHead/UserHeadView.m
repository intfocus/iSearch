//
//  UserHeadView.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "UserHeadView.h"
#import "User.h"
#import "const.h"
#import "DateUtils.h"

@implementation UserHeadView

-(void)awakeFromNib{
    UIImageView *head=self.headView;
    head.layer.cornerRadius=CGRectGetHeight(head.frame)/2;
    head.layer.borderColor=[UIColor whiteColor].CGColor;
    head.layer.borderWidth=2;
    
    //get saved avatar image
    NSData *imagedata = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarSmall"];
    if (imagedata){
        UIImage *avatarImage = [UIImage imageWithData:imagedata];
        head.image = avatarImage;
    }
    head.layer.masksToBounds = YES;
    
    // assign value
    User *user = [[User alloc] init];
    self.nameView.text = user.name;
    self.dateView.text = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    
    self.stateView.hidden = YES;
}

@end
