//
//  BaseModel.m
//  iSearch
//
//  Created by lijunjie on 15/6/27.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "BaseModel.h"


@implementation BaseModel

- (NSString *) to_s:(BOOL)isFormat {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    NSString *pName, *pValue;
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        pName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        pValue = [self valueForKey:pName];
        [keys addObject:[NSString stringWithFormat:@"%@: %@", pName,pValue]];
    }
    free(properties);
    
    NSString *joinStr = [keys componentsJoinedByString:(isFormat ? @",\n" : @",")];
    NSString *output = [NSString stringWithFormat:@"#<%@ %@>", self.class, joinStr];
    return output;
}

- (NSString *) to_s {
    return [self to_s:NO];
}

- (NSString *) inspect {
    return [self to_s];
}

@end