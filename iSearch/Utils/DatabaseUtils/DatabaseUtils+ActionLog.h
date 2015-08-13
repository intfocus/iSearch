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

/**
 *  我的记录，需要使用的数据
 *
 *  @returnNSMutableArray
 */
- (NSArray *)actionLogs;

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
                  ActRet:(NSString *)ActRet
                 SlideID:(NSString *)slideID
               SlideType:(NSString *)slideType
             SlideAction:(NSString *)slideAction;
/**
 *  update #deleted when remove slide
 *
 *  @param FunName <#FunName description#>
 *  @param ActObj  slideID
 *  @param ActName Display/Download/Remove
 *  @param ActRet  Favorite or Slide
 */
- (void)updateDeletedSlide:(NSString *)slideID
                 SlideType:(NSString *)slideType;

/**
 *  未同步数据到服务器的数据列表
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)unSyncRecords;
- (void)updateSyncedRecords:(NSMutableArray *)IDS;

/**
 *  设置界面中用户信息显示，用以调试
 *
 *  @return 最近播放的文档数量/未同步的记录数量/当前个人记录数量/所有记录数量
 */
- (NSString *)localInfo;
@end

#endif
