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
#import "DataHelper.h"
#import "DatabaseUtils+ActionLog.h"
#import "ExtendNSLogFunctionality.h"

@interface ActionLog()
@property (nonatomic, strong) DatabaseUtils *databaseUtils;
@end

@implementation ActionLog
- (ActionLog *)init {
    if(self = [super init]) {
        _databaseUtils = [[DatabaseUtils alloc] init];
    }
    return self;
}

/**
 *  记录列表
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)records {
    return [self.databaseUtils actionLogs];
}

/**
 *  操作记录
 *
 *  @param slide  action object
 *  @param action action name
 */
- (void)recordSlide:(Slide*)slide Action:(NSString *)action {
    [self.databaseUtils insertActionLog:[NSString stringWithFormat:@"%@ slide#%@ in %@", action,slide.ID, slide.dirName]
                                ActName:action
                                 ActObj:slide.ID
                                 ActRet:slide.dirName];
}

- (void)syncRecords {
    NSMutableArray *unSyncRecords = [self.databaseUtils unSyncRecords];
    if([unSyncRecords count] == 0) { return; }
//    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    NSString *actionLogUrl = [ApiUtils apiUrl:ACTION_LOGGER_URL_PATH];
//    NSDictionary *response = [[NSDictionary alloc] init];
//    NSMutableArray *IDS = [[NSMutableArray alloc] init];
//    NSString *ID;
//    for(dict in unSyncRecords) {
//        ID = dict[@"id"];
//        [dict removeObjectForKey:@"id"];
//        response = [ApiUtils POST:actionLogUrl Param:dict];
//    }
//    [self.databaseUtils updateSyncedRecords:IDS];
}
@end