//
//  DSL.m
//  ss
//
//  Created by huangyi on 15/8/12.
//  Copyright (c) 2015年 wettags. All rights reserved.
//

#import "DSL.h"

@interface DSL ()

@property (nonatomic, strong) NSMutableArray *childNodes;

@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, strong )NSString *nodeText;

@end

@implementation DSL

- (instancetype)init{
    self = [super init];
    self.childNodes = [NSMutableArray array];
    return self;
}

- (void)tag:(NSString*)tagName field:(void (^)(DSL *parent))block{
    DSL *node = [[DSL alloc] init];
    node.nodeName = tagName;
    [self.childNodes addObject:node];
    if (block) {
        block(node);
    }
}
- (void)tag:(NSString *)tagName content:(NSString *)contentString{
    DSL *node = [[DSL alloc] init];
    node.nodeName = tagName;
    node.nodeText = contentString;
    [self.childNodes addObject:node];
}

- (NSString*)toString{
    NSMutableString *str = [NSMutableString string];
    if (self.nodeName) {
        [str appendFormat:@"<%@>",self.nodeName];
    }
    if (self.nodeText) {
        [str appendFormat:@"%@",self.nodeText];
    }
    for (DSL *child in self.childNodes) {
        NSString *embed = [child toString];
        [str appendFormat:@"%@",embed];
    }
    if (self.nodeName) {
        [str appendFormat:@"</%@>",self.nodeName];
    }
    return [str copy];
}

-(void)example{
    DSL *dsl=[[DSL alloc] init];
    [dsl tag:@"html" field:^(DSL *dsl) {
        [dsl tag:@"head" field:^(DSL *head) {
            [head tag:@"title" content:@"i am title"];
        }];
        [dsl tag:@"body" field:^(DSL *body) {
            [body tag:@"h1" content:@"Objective-C DSL"];
            [body tag:@"div" field:^(DSL *div) {
                [div tag:@"span" content:@"hello world"];
            }];
        }];
    }];
    NSString *output=[dsl toString];
    NSLog(@"%@",output);
}

@end
