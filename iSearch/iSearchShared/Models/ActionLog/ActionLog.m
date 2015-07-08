//
//  ActionLog.m
//  iSearch
//
//  Created by lijunjie on 15/7/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionLog.h"

#import "const.h"
#import "Slide.h"
#import "DatabaseUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface ActionLog()
@property (nonatomic, strong) DatabaseUtils *databaseUtils;
@end

@implementation ActionLog
//- (ActionLog *)init {
//    if(self = [self init]) {
//        self.databaseUtils = [[DatabaseUtils alloc] init];
//    }
//    return self;
//}

/**
 *  记录列表
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)records {
    if(!self.databaseUtils) {
        self.databaseUtils = [[DatabaseUtils alloc] init];
    }
    return [self.databaseUtils actionLogs];
}

/**
 *  操作记录
 *
 *  @param slide  action object
 *  @param action action name
 */
- (void)recordSlide:(Slide*)slide Action:(NSString *)action {
    if(!self.databaseUtils) {
        self.databaseUtils = [[DatabaseUtils alloc] init];
    }
    [self.databaseUtils insertActionLog:[NSString stringWithFormat:@"%@ slide#%@ in %@", action,slide.ID, slide.dirName]
                                ActName:action
                                 ActObj:slide.ID
                                 ActRet:slide.dirName];
}

@end