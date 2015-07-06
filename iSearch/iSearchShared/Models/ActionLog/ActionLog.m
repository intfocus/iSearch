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

- (NSMutableArray *)records {
    if(!self.databaseUtils) {
        self.databaseUtils = [[DatabaseUtils alloc] init];
    }
    return [self.databaseUtils actionLogs];
}

- (void)recordSlide:(Slide*)slide {
    if(!self.databaseUtils) {
        self.databaseUtils = [[DatabaseUtils alloc] init];
    }
    [self.databaseUtils insertActionLog:[NSString stringWithFormat:@"display slide#%@ %@", slide.ID, slide.dirName]
                                ActName:@"display"
                                 ActObj:slide.ID
                                 ActRet:slide.dirName];
}

@end