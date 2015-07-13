//
//  HttpResponse.m
//  iSearch
//
//  Created by lijunjie on 15/7/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "HttpResponse.h"
#import "ExtendNSLogFunctionality.h"

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
    return (!self.errors || [self.errors count] == 0);
}

- (NSString *)receivedString {
    return [[NSString alloc]initWithData:self.received encoding:NSUTF8StringEncoding];
}

#pragma mark - rewrite setter
- (void)setReceived:(NSData *)received {
    if(!received) { return; }
    
    NSError *error;
    _received = received;
    _data     = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&error];
    BOOL isOK = NSErrorPrint(error, @"NSData convert to NSDictionary");
    if(!isOK) {
        [self.errors addObject:(NSString *)psd([error localizedDescription],@"服务器数据转化JSON失败")];
    }
}

- (void)setResponse:(NSURLResponse *)response {
    if(!response) { return; }
    
    //_statusCode   = [NSNumber numberWithInteger:[response statusCode]];
    _mimeType     = response.MIMEType;
    _encodingName = response.textEncodingName;
    
    _response = response;
}

#pragma mark - assistant methods

- (void)checkBaseRespose {
    if(![self.mimeType isEqualToString:@"application/json"]) {
        NSLog(@"%@ mimeType not application/json but %@", self.response.URL, self.mimeType);
    }
    if(![self.encodingName isEqualToString:@"utf-8"]) {
        NSLog(@"%@ encodingName not utf-8 but %@", self.response.URL, self.encodingName);
    }
}
@end
