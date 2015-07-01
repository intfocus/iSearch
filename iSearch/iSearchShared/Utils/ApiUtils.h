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

+ (NSURL *)downloadSlideURL:(NSString *)slideID;
+ (NSMutableDictionary *)notifications;

@end

#endif
