//
//  Version+Self.h
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_Version_Self_h
#define iSearch_Version_Self_h
#import "Version.h"

@interface Version (Self)

- (void)checkUpdate:(void(^)())successBlock FailBloc:(void(^)())failBlock;
@end

#endif
