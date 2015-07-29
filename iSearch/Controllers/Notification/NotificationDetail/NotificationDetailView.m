//
//  NotificationDetailView.m
//  iSearch
//
//  Created by lijunjie on 15/7/28.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationDetailView.h"
#import "MainViewController.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"

@interface NotificationDetailView()
@property (nonatomic, strong) IBOutlet UIButton *hideButton;
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelDate;
@property (nonatomic, strong) IBOutlet UITextView *textViewMsg;

@end

@implementation NotificationDetailView

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.labelTitle.text = self.dict[NOTIFICATION_FIELD_TITLE];
    self.textViewMsg.text = self.dict[NOTIFICATION_FIELD_MSG];
    NSString *dateString = (NSString *)psd(self.dict[NOTIFICATION_FIELD_OCCURDATE], self.dict[NOTIFICATION_FIELD_CREATEDATE]);
    
    if(dateString && [dateString length] > 10) {
        dateString = [dateString substringToIndex:10];
    } else {
        dateString = @"";
    }
    self.labelDate.text = dateString;
}

- (IBAction)actionClose:(id)sender {
    [self.masterViewController dimmissPopupNotificationDetailView];
}
@end
