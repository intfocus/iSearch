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

@protocol ViewUpgradeProtocol <NSObject>
- (void)dismissViewUpgrade;
@end

@interface ViewUpgrade:UIViewController


@property (nonatomic, weak) id <ViewUpgradeProtocol> delegate;

- (void)checkAppVersionUpgrade:(void(^)())successBloc
                     FailBlock:(void(^)())failBlock;
@end

#endif
