//
//  DatabaseUtils+ActionLog.h
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DatabaseUtils_ActionLog_h
#define iSearch_DatabaseUtils_ActionLog_h
#import "DatabaseUtils.h"

@interface DatabaseUtils (ActionLog)

- (NSMutableArray *)actionLogs;

- (void) insertActionLog:(NSString *)FunName
                 ActName:(NSString *)ActName
                  ActObj:(NSString *)ActObj
                  ActRet:(NSString *)ActRet;

- (NSMutableArray *)unSyncRecords;
- (void)updateSyncedRecords:(NSMutableArray *)IDS;
@end

#endif
