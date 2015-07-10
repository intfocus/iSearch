//
//  Database_Utils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_Database_Utils_h
#define AudioNote_Database_Utils_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>



@interface DatabaseUtils : NSObject

@property NSString        *databaseFilePath;

+ (DatabaseUtils *) setUP;
- (NSInteger) executeSQL: (NSString *) sql;
- (void) deleteWithId: (NSString *) id;
- (NSMutableArray*) searchFilesWithKeywords: (NSArray *) keywords;

@end

#endif
