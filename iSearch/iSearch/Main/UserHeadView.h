//
//  UserHeadView.h
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeadView : UIControl

@property(nonatomic,weak)IBOutlet UIImageView *headView;
@property(nonatomic,weak)IBOutlet UILabel *nameView;
@property(nonatomic,weak)IBOutlet UILabel *dateView;
@property(nonatomic,weak)IBOutlet UILabel *stateView;

@end
