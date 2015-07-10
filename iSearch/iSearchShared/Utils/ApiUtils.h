//
//  ApiUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ApiUtils_h
#define iSearch_ApiUtils_h

@interface ApiUtils : NSObject

+ (NSString *)loginUrl:(NSString *)cookieValue;
+ (NSURL *)downloadSlideURL:(NSString *)slideID;
+ (NSMutableDictionary *)notifications;
+ (NSString *)postActionLog:(NSMutableDictionary *) params;

+ (void) get;
+ (NSString *)apiUrl:(NSString *)path;
+ (NSDictionary *) POST:(NSString *)url Param:(NSMutableDictionary *)parameters;
@end

#endif
