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

@interface ViewCategory : UIView


@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet UIButton *btnEvent;

- (void)setImageWith:(NSString *)typeID CategoryID:(NSString *)categoryID;
@end

#endif
