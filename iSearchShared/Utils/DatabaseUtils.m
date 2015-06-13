//
//  Database_Utils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DatabaseUtils.h"
#import "const.h"
#import "FileUtils.h"

@implementation DatabaseUtils

#define myNSLog

- (id) init {
    if (self = [super init]) {
        self.databaseFilePath = [FileUtils getPathName:DATABASE_DIRNAME
                                              FileName:DATABASE_FILEAME];
        //NSLog(@"%@", self.databaseFilePath);
    }
    return self;
}

/**
 *  数据库初始化时，集中配置在这里
 */
+ (DatabaseUtils *) setUP {
    DatabaseUtils *databaseUtils = [[DatabaseUtils alloc] init];
    
    NSString *createTableOfflineSQL= [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( \
            id integer PRIMARY KEY AUTOINCREMENT, \
            %@ varchar(100) NOT NULL,                                                        \
            %@ varchar(100) NOT NULL,                                                        \
            %@ varchar(100) NOT NULL,                                                        \
            %@ varchar(1000) NULL,                                                           \
            %@ varchar(100) NULL,                                                            \
            %@ varchar(100) NULL,                                                            \
            %@ varchar(100) NULL,                                                            \
            %@ varchar(100) NULL,                                                            \
            %@ varchar(100) NULL DEFAULT '0',                                                \
            create_time datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')), \
            modify_time datetime NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime'))  \
            );                                                                               \
        CREATE INDEX IF NOT EXISTS idx_type ON %@(%@); \
        CREATE INDEX IF NOT EXISTS idx_create_time ON %@(create_time);",
        OFFLINE_TABLE_NAME,
        OFFLINE_COLUMN_FILEID,
        OFFLINE_COLUMN_NAME,
        OFFLINE_COLUMN_TYPE,
        OFFLINE_COLUMN_DESC,
        OFFLINE_COLUMN_TAGS,
        OFFLINE_COLUMN_PAGENUM,
        OFFLINE_COLUMN_CATEGORYNAME,
        OFFLINE_COLUMN_ZIPURL,
        OFFLINE_COLUMN_ZIPSIZE,
        OFFLINE_TABLE_NAME,OFFLINE_COLUMN_TYPE,
        OFFLINE_TABLE_NAME];
    [databaseUtils executeSQL: createTableOfflineSQL];
    
    return databaseUtils;
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
- (NSInteger) executeSQL: (NSString *) sql {
    sqlite3 *database;
    //NSLog(@"executeSQL: %@", sql);
    int result = sqlite3_open([self.databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        NSLog(@"DatabaseUtils#executeSQL open database failed - line number: %i.", __LINE__);
        return -__LINE__;
    }
 
    char *errorMsg;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@  error: %s", sql, errorMsg]);
        return -__LINE__;
    } else {
        NSLog(@"%@", @"DatabaseUtils#executeSQL successfully!");
    }

    ////////////////////////////////
    // Get the ID just execute
    ////////////////////////////////
    NSInteger lastRowId = [[NSNumber numberWithLongLong: sqlite3_last_insert_rowid(database)] integerValue];
    if (lastRowId > 0) return lastRowId;
    
    return -__LINE__;
} // end of executeSQL()

- (NSMutableArray*) selectFilesWithKeywords: (NSArray *) keywords {
    sqlite3 *database;
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    int result = sqlite3_open([self.databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        NSLog(@"DatabaseUtils#selectWithResult open database failed - line number: %i.", __LINE__);
    }
    NSString *sql = [NSString stringWithFormat:@"select id, fid, name, type, desc, tags, page_count, zip_url, create_time, modify_time from %@ ", OFFLINE_SEARCH_TABLENAME];
    NSString *keyword;
    NSMutableArray *likes = [[NSMutableArray alloc] init];
    for(keyword in keywords) {
        //[likes addObject:[NSString stringWithFormat:@" name like '%%%@%%' or desc like '%%%@%%' ", keyword, keyword]];
        [likes addObject:[NSString stringWithFormat:@" name like '%%%@%%' ", keyword]];
    }
    // 关键字不为空，SQL语句添加where过滤
    NSString *where = @" where ";
    if([keywords count]) {
        where = [where stringByAppendingString:[likes componentsJoinedByString:@" or "]];
        sql   = [sql stringByAppendingString:where];
    }
    
    char *errorMsg;
    sqlite3_stmt *statement;
    int _id, _fid, _type, _page_count;
    NSString *_name, *_desc, *_tags, *_zip_url;
    NSString *_create_time, *_modify_time;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _id          = sqlite3_column_int(statement, 0);
            _fid         = sqlite3_column_int(statement, 1);
            _name        = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2)encoding:NSUTF8StringEncoding];
            _type        = sqlite3_column_int(statement, 3);
            _desc        = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4)encoding:NSUTF8StringEncoding];
            _tags        = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5)encoding:NSUTF8StringEncoding];
            _page_count  = sqlite3_column_int(statement, 6);
            _zip_url     = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 7)encoding:NSUTF8StringEncoding];
            _create_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 8)encoding:NSUTF8StringEncoding];
            _modify_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 9)encoding:NSUTF8StringEncoding];
            
            
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_id]  forKey:@"id"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_fid] forKey:@"fid"];
            [mutableDictionary setObject:_name forKey:@"name"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_type] forKey:@"type"];
            [mutableDictionary setObject:_desc  forKey:@"desc"];
            [mutableDictionary setObject:_tags forKey:@"tags"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_page_count]  forKey:@"page_count"];
            [mutableDictionary setObject:_zip_url forKey:@"zip_url"];
            [mutableDictionary setObject:_create_time forKey:@"create_time"];
            [mutableDictionary setObject:_modify_time forKey:@"modify_time"];
            
            [mutableArray addObject: mutableDictionary];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@  error: %s", sql, errorMsg]);
    }

    
    return mutableArray;
} // end of selectFilesWithKeywords()

- (void) deleteWithId: (NSString *) id {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id = %@;", OFFLINE_SEARCH_TABLENAME, id];
    [self executeSQL: sql];
}

@end

