//
//  Database_Utils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DatabaseUtils.h"
#import "FMDB.h"
#import "const.h"
#import "FileUtils.h"
#import "User.h"
#import "ExtendNSLogFunctionality.h"

@implementation DatabaseUtils

#define myNSLog

- (DatabaseUtils *)init {
    if (self = [super init]) {
        _userID = [User userID];
        NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
        _dbVersion = (NSString *)psd(localVersionInfo[@"Database Version"], @"NotSet");
        _dbName = [NSString stringWithFormat:@"%@-%@.db", DATABASE_FILEAME, self.dbVersion];
        _dbPath = [FileUtils getPathName:DATABASE_DIRNAME FileName:self.dbName];

        [self executeSQL:[self createTableOffline]];
        [self executeSQL:[self createTableActionLog]];
    }
    return self;
}

/**
 *  数据库初始化时，集中配置在这里
 */
- (NSString *) createTableOffline {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (             \
            id integer PRIMARY KEY AUTOINCREMENT,                                   \
            %@ varchar(100) NOT NULL,                                               \
            %@ varchar(500) NOT NULL,                                               \
            %@ varchar(500) NOT NULL,                                               \
            %@ varchar(100) NOT NULL,                                               \
            %@ varchar(1000) NULL,                                                  \
            %@ varchar(100) NULL,                                                   \
            %@ varchar(100) NULL,                                                   \
            %@ varchar(100) NULL,                                                   \
            %@ varchar(100) NULL,                                                   \
            %@ varchar(100) NULL DEFAULT '0',                                       \
            %@ datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')), \
            %@ datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime'))  \
            );                                                                      \
        CREATE INDEX IF NOT EXISTS idx_type ON %@(%@);                              \
        CREATE INDEX IF NOT EXISTS idx_create_time ON %@(%@);",
        OFFLINE_TABLE_NAME,
        OFFLINE_COLUMN_FILEID,
        OFFLINE_COLUMN_NAME,
        OFFLINE_COLUMN_TITLE,
        OFFLINE_COLUMN_TYPE,
        OFFLINE_COLUMN_DESC,
        OFFLINE_COLUMN_TAGS,
        OFFLINE_COLUMN_PAGENUM,
        OFFLINE_COLUMN_CATEGORYNAME,
        OFFLINE_COLUMN_ZIPURL,
        OFFLINE_COLUMN_ZIPSIZE,
            DB_COLUMN_CREATED,
            DB_COLUMN_UPDATED,
        OFFLINE_TABLE_NAME,OFFLINE_COLUMN_TYPE,
        OFFLINE_TABLE_NAME,DB_COLUMN_CREATED];
}

- (NSString *) createTableActionLog {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (              \
            id integer PRIMARY KEY AUTOINCREMENT,                                    \
            %@ varchar(300) NOT NULL,                                                \
            %@ varchar(300) NOT NULL,                                                \
            %@ varchar(300) NOT NULL,                                                \
            %@ varchar(300) NOT NULL,                                                \
            %@ varchar(300) NOT NULL,                                                \
            %@ boolean NOT NULL default 0,                                           \
            %@ boolean NOT NULL default 0,                                           \
            %@ datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')),  \
            %@ datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime'))   \
            );                                                                       \
            CREATE INDEX IF NOT EXISTS idx_funname ON %@(%@);                        \
            CREATE INDEX IF NOT EXISTS idx_create_time ON %@(%@);",
            ACTIONLOG_TABLE_NAME,
            ACTIONLOG_COLUMN_UID,
            ACTIONLOG_COLUMN_FUNNAME,
            ACTIONLOG_COLUMN_ACTNAME,
            ACTIONLOG_COLUMN_ACTRET,
            ACTIONLOG_COLUMN_ACTOBJ,
            ACTIONLOG_COLUMN_ISSYNC,
            ACTIONLOG_COLUMN_DELETED,
            DB_COLUMN_CREATED,
            DB_COLUMN_UPDATED,
            ACTIONLOG_TABLE_NAME,ACTIONLOG_COLUMN_FUNNAME,
            OFFLINE_TABLE_NAME, DB_COLUMN_CREATED];
}
/**
 *  需要的取值方式未定义或过于复杂时，直接执行SQL语句
 *  若是SELECT则返回搜索到的行ID
 *  若是DELECT/INSERT可忽略返回值
 *
 *  @param sql SQL语句，请参考SQLite语法
 *
 *  @return 返回搜索到数据行的ID,执行失败返回该代码行
 */
- (NSInteger)executeSQL:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        BOOL isExecuteSuccessfully = [db executeStatements:sql];
        if(!isExecuteSuccessfully) {
            NSLog(@"Executed faile with SQL below:\n%@", sql);
        }
        [db close];
    }
    else {
        NSLog(@"Cannot open DB at the path: %@", self.dbPath);
    }
    return -__LINE__;
} // end of executeSQL()

- (NSMutableArray*) searchFilesWithKeywords: (NSArray *) keywords {
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];

    NSString *sql = [NSString stringWithFormat:@"select id, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ ",
                     OFFLINE_COLUMN_FILEID,
                     OFFLINE_COLUMN_NAME,
                     OFFLINE_COLUMN_TITLE,
                     OFFLINE_COLUMN_TYPE,
                     OFFLINE_COLUMN_DESC,
                     OFFLINE_COLUMN_TAGS,
                     OFFLINE_COLUMN_PAGENUM,
                     OFFLINE_COLUMN_CATEGORYNAME,
                     OFFLINE_COLUMN_ZIPURL,
                     OFFLINE_COLUMN_ZIPSIZE,
                     DB_COLUMN_CREATED,
                     DB_COLUMN_UPDATED,
                     OFFLINE_TABLE_NAME];
    NSString *keyword;
    NSMutableArray *likes = [[NSMutableArray alloc] init];
    for(keyword in keywords) {
        [likes addObject:[NSString stringWithFormat:@" or %@ like '%%%@%%' or %@ like '%%%@%%' ", CONTENT_FIELD_NAME, keyword, CONTENT_FIELD_DESC, keyword]];
    }
    // 关键字不为空，SQL语句添加where过滤
    NSString *where = @" where 1 = 1 ";
    if([keywords count]) {
        where = [where stringByAppendingString:[likes componentsJoinedByString:@" "]];
        sql   = [sql stringByAppendingString:where];
    }
    
    char *errorMsg;
    int _id;
    NSString *_one, *_two, *_three, *_four, *_five, *_six, *_seven, *_eight, *_nine, *_ten;
    NSString *_created_at, *_updated_at;
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:sql];
        while([s next]) {
            _id          = [s intForColumnIndex:0];
            _one         = [s stringForColumnIndex:1];
            _two         = [s stringForColumnIndex:2];
            _three       = [s stringForColumnIndex:3];
            _four        = [s stringForColumnIndex:4];
            _five        = [s stringForColumnIndex:5];
            _six         = [s stringForColumnIndex:6];
            _seven       = [s stringForColumnIndex:7];
            _eight       = [s stringForColumnIndex:8];
            _nine        = [s stringForColumnIndex:9];
            _ten         = [s stringForColumnIndex:10];
            _created_at  = [s stringForColumnIndex:11];
            _updated_at  = [s stringForColumnIndex:12];
            
            
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_id]  forKey:@"id"];
            [mutableDictionary setObject:_one forKey:OFFLINE_COLUMN_FILEID];
            [mutableDictionary setObject:_two forKey:OFFLINE_COLUMN_NAME];
            [mutableDictionary setObject:_three forKey:OFFLINE_COLUMN_TITLE];
            [mutableDictionary setObject:_four forKey:OFFLINE_COLUMN_TYPE];
            [mutableDictionary setObject:_five forKey:OFFLINE_COLUMN_DESC];
            [mutableDictionary setObject:_six forKey:OFFLINE_COLUMN_TAGS];
            [mutableDictionary setObject:_seven forKey:OFFLINE_COLUMN_PAGENUM];
            [mutableDictionary setObject:_eight forKey:OFFLINE_COLUMN_CATEGORYNAME];
            [mutableDictionary setObject:_nine forKey:OFFLINE_COLUMN_ZIPURL];
            [mutableDictionary setObject:_ten forKey:OFFLINE_COLUMN_ZIPSIZE];
            [mutableDictionary setObject:_created_at forKey:DB_COLUMN_CREATED];
            [mutableDictionary setObject:_updated_at forKey:DB_COLUMN_UPDATED];
            
            [mutableArray addObject: mutableDictionary];
        }
        [db close];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@  error: %s", sql, errorMsg]);
    }

    
    return mutableArray;
} // end of selectFilesWithKeywords()

- (void) deleteWithId: (NSString *) id {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id = %@;", OFFLINE_TABLE_NAME, id];
    [self executeSQL: sql];
}

@end

