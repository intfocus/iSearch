//
//  ActionLog.h
//  iSearch
//
//  Created by lijunjie on 15/7/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ActionLog_h
#define iSearch_ActionLog_h
#import "BaseModel.h"
@class Slide;
/**
 *  行为记录:
 *
 */
@interface ActionLog : BaseModel

// firm.im attributes
@property (nonatomic, strong) NSString *FunName;
@property (nonatomic, strong) NSString *ActName;
@property (nonatomic, strong) NSString *ActRet;
@property (nonatomic, strong) NSString *ActObj;

// local fields
@property (nonatomic, strong) NSString *localCreatedDate;
@property (nonatomic, strong) NSString *localUpdatedDate;

// instance methods
- (NSMutableArray *)records;
- (void)recordSlide:(Slide*)slide;
@end

#endif
