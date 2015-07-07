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



@interface DatabaseUtils : NSObject

@property NSString *databaseFilePath;
@property NSString *userID;

// instance methods
- (NSInteger)executeSQL:(NSString *)sql;
- (void) deleteWithId:(NSString *)ID;
- (NSMutableArray*)searchFilesWithKeywords:(NSArray *)keywords;
- (void) insertActionLog:(NSString *)FunName
                 ActName:(NSString *)ActName
                  ActObj:(NSString *)ActObj
                  ActRet:(NSString *)ActRet;
- (NSMutableArray *)actionLogs;
@end

#endif
