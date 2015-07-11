//
//  DatabaseUtils+ActionLog.m
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseUtils+ActionLog.h"
#import "FMDB.h"
#import "FileUtils.h"
#import "const.h"

@implementation DatabaseUtils (ActionLog)
/**
 *  update #deleted when remove slide
 *
 *  @param FunName NoUse
 *  @param ActObj  slideID
 *  @param ActName Display/Download/Remove
 *  @param ActRet  Favorite or Slide
 */
- (void) insertActionLog:(NSString *)FunName
                 ActName:(NSString *)ActName
                  ActObj:(NSString *)ActObj
                  ActRet:(NSString *)ActRet {
    if([ActName isEqualToString:ACTION_REMOVE]) {
        [self updateDeletedAction:FunName ActName:ActName ActObj:ActObj ActRet:ActRet];
    }
    NSString *insertSQL = [NSString stringWithFormat:@"insert into %@(%@, %@, %@, %@, %@)   \
                           values('%@', '%@', '%@', '%@', '%@');",
                           ACTIONLOG_TABLE_NAME,
                           ACTIONLOG_COLUMN_UID,
                           ACTIONLOG_COLUMN_FUNNAME,
                           ACTIONLOG_COLUMN_ACTNAME,
                           ACTIONLOG_COLUMN_ACTOBJ,
                           ACTIONLOG_COLUMN_ACTRET,
                           self.userID,
                           FunName,
                           ActName,
                           ActObj,
                           ActRet];
    [self executeSQL:insertSQL];
}

/**
 *  update #deleted when remove slide
 *
 *  @param FunName <#FunName description#>
 *  @param ActObj  slideID
 *  @param ActName Display/Download/Remove
 *  @param ActRet  Favorite or Slide
 */
- (void)updateDeletedAction:(NSString *)FunName
                    ActName:(NSString *)ActName
                     ActObj:(NSString *)ActObj
                     ActRet:(NSString *)ActRet {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = 1 \
                     where %@ = '%@' and %@ = '%@' and %@ = 0 and     \
                     %@ = '%@' and %@ = '%@';",
                     ACTIONLOG_TABLE_NAME, ACTIONLOG_COLUMN_DELETED,
                     ACTIONLOG_COLUMN_ACTNAME, ACTION_DISPLAY, ACTIONLOG_COLUMN_UID, self.userID, ACTIONLOG_COLUMN_DELETED,
                     ACTIONLOG_COLUMN_ACTOBJ, ActObj, ACTIONLOG_COLUMN_ACTRET, ActRet];
    
    [self executeSQL:sql];
}
- (NSMutableArray *)actionLogs {
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select distinct %@, %@, %@, max(%@) from %@ \
                     where %@ = '%@' and %@ = '%@' and %@ = 0    \
                     group by %@, %@, %@                         \
                     limit 15;",
                     ACTIONLOG_COLUMN_ACTOBJ, ACTIONLOG_COLUMN_ACTNAME, ACTIONLOG_COLUMN_ACTRET, DB_COLUMN_CREATED, ACTIONLOG_TABLE_NAME,
                     ACTIONLOG_COLUMN_ACTNAME, ACTION_DISPLAY, ACTIONLOG_COLUMN_UID, self.userID, ACTIONLOG_COLUMN_DELETED,
                     ACTIONLOG_COLUMN_ACTOBJ, ACTIONLOG_COLUMN_ACTNAME, ACTIONLOG_COLUMN_ACTRET];
    NSString *slideID, *actionName, *dirName, *createdAt;
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:sql];
        while([s next]) {
            slideID    = [s stringForColumnIndex:0];
            actionName = [s stringForColumnIndex:1];
            dirName    = [s stringForColumnIndex:2];
            createdAt  = [s stringForColumnIndex:3];
            
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:slideID forKey:ACTIONLOG_COLUMN_ACTOBJ];
            [mutableDictionary setObject:actionName forKey:ACTIONLOG_COLUMN_ACTNAME];
            [mutableDictionary setObject:dirName forKey:ACTIONLOG_COLUMN_ACTRET];
            [mutableDictionary setObject:createdAt forKey:DB_COLUMN_CREATED];
            
            if([FileUtils checkSlideExist:slideID Dir:dirName Force:NO]) {
                [mutableArray addObject: mutableDictionary];
            } else {
                NSLog(@"bug# should update deleted=1");
            }
        }
        [db close];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@", sql]);
    }
    
    if([mutableArray count] > 0) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:DB_COLUMN_CREATED ascending:NO];
        mutableArray = [NSMutableArray arrayWithArray:[mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
    }
    
    return mutableArray;
}

- (NSMutableArray *)unSyncRecords {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select id, %@, %@, %@, %@, %@ from %@ \
                     where %@ = '%@' and %@ = 0 ;",
                     ACTIONLOG_COLUMN_FUNNAME,
                     ACTIONLOG_COLUMN_ACTOBJ,
                     ACTIONLOG_COLUMN_ACTNAME,
                     ACTIONLOG_COLUMN_ACTRET,
                     DB_COLUMN_CREATED,
                     ACTIONLOG_TABLE_NAME,
                     ACTIONLOG_COLUMN_UID,
                     self.userID,
                     ACTIONLOG_COLUMN_ISSYNC];
    int ID;
    NSString *funName, *actObj, *actName, *actRet, *actTime;
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    NSMutableDictionary *dict      = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:sql];
        while([s next]) {
            ID      = [s intForColumnIndex:0];
            funName = [s stringForColumnIndex:1];
            actObj  = [s stringForColumnIndex:2];
            actName = [s stringForColumnIndex:3];
            actRet  = [s stringForColumnIndex:4];
            actTime = [s stringForColumnIndex:5];
            
            dict    = [NSMutableDictionary dictionaryWithCapacity:0];
            dict[@"id"]                   = [NSNumber numberWithInt:ID];
            dict[ACTIONLOG_FIELD_UID]     = self.userID;
            dict[ACTIONLOG_FIELD_FUNNAME] = funName;
            dict[ACTIONLOG_FIELD_ACTOBJ]  = actObj;
            dict[ACTIONLOG_FIELD_ACTNAME] = actName;
            dict[ACTIONLOG_FIELD_ACTRET]  = actRet;
            dict[ACTIONLOG_FIELD_ACTTIME] = actTime;
            
            [array addObject:dict];
        }
        [db close];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@", sql]);
    }
    
    return array;
}

- (void)updateSyncedRecords:(NSMutableArray *)IDS {
    if([IDS count] == 0) return;
    
    NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@ = 1 where %@ = '%@' and %@ = 0 and id in (%@)",
                           ACTIONLOG_TABLE_NAME,
                           ACTIONLOG_COLUMN_ISSYNC,
                           ACTIONLOG_COLUMN_UID,
                           self.userID,
                           ACTIONLOG_COLUMN_ISSYNC,
                           [IDS componentsJoinedByString:@","]];
    [self executeSQL:updateSQL];
}

@end