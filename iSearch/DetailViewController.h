//
//  DetailViewController.h
//  iSearch
//
//  Created by lijunjie on 15/5/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DetailViewController_h
#define iSearch_DetailViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MasterViewController.h"

/**
 *  框架为左右结构，此类为右边部分详细展示界面
 */
@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushButton;

@property (strong, nonatomic) UIColor *backgroundColor;

- (IBAction)pushButtonTapped:(id)sender;
@end

#endif
