//
//  DSL.h
//  ss
//
//  Created by huangyi on 15/8/12.
//  Copyright (c) 2015年 wettags. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSL : NSObject

-(void)tag:(NSString*)tagName field:(void (^)(DSL *parent))block;
-(void)tag:(NSString*)tagName content:(NSString*)contentString;

-(NSString*)toString;

@end
