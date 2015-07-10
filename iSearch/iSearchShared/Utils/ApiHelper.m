//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ApiHelper.h"
#import "AFNetworking.h"
#import "ExtendNSLogFunctionality.h"

@implementation ApiHelper
+ (NSDictionary *) Base:(NSString *)method
                    Url:(NSString *)urlString
                 Params:(NSDictionary *)parameters {

    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlString);
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10];
    NSError *error;
    NSURLResponse *response;
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSErrorPrint(error, @"Http#get %@", urlString);
    //NSString *response    = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&error];
    NSErrorPrint(error, @"NSData convert to NSDictionary");
    return result;
}
@end
