//
//  ViewUpgrade.h
//  iSearch
//
//  Created by lijunjie on 15/7/3.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ViewUpgrade_h
#define iSearch_ViewUpgrade_h
#import <UIKit/UIKit.h>

@interface ViewUpgrade:UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelLatestVersion;
@property (weak, nonatomic) IBOutlet UITextView *textViewChangLog;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnUpgrade;
@property (strong, nonatomic) NSString *insertUrl;
@end

#endif
