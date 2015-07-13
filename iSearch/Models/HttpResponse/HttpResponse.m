//
//  HttpResponse.m
//  iSearch
//
//  Created by lijunjie on 15/7/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "HttpResponse.h"

@implementation HttpResponse

- (HttpResponse *)init {
    if(self = [super init]) {
        _data     = [[NSMutableDictionary alloc] init];
        _errors   = [[NSMutableArray alloc] init];
        _received = [[NSData alloc] init];
    }
    return self;
}

- (BOOL)isValid {
    return (self.errors && [self.errors count] > 0);
}
@end
