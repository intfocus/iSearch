//
//  Header.h
//  WebStructure
//
//  Created by lijunjie on 15-4-15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef WebStructure_ViewFolder_h
#define WebStructure_ViewFolder_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GMGridViewCell.h"

@interface ViewCategory : UIView <GMGridViewCellProtocol>

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnImageCover;
@property (strong, nonatomic) NSString *typeID;
@property (strong, nonatomic) NSString *categoryID;


- (void)activate;
- (void)deactivate;
@end

#endif
