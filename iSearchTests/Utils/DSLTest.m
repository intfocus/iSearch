//
//  DSLTest.m
//  iSearch
//
//  Created by lijunjie on 15/8/7.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "BaseModel.h"
@interface DSL : BaseModel
@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSMutableArray *tmpArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *children;

- (void)tag:(NSString *)tagName content:(NSString *)content;
////- (void)field:(void(^)(DSL *dsl))someBlock;
//- (void)field:(void(^)(DSL *dsl, int level))someBlock;
- (void)tag:(NSString *)tagName field:(void(^)(DSL *dsl))someBlock;
@end
@implementation DSL

- (DSL *)init {
    if(self = [super init]) {
        self.tmpArray = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
        self.children = [NSMutableArray array];
        self.level = 1;
        self.string = @"";
    }
    return self;
}

- (void)tag:(NSString *)tagName content:(NSString *)content {
    [self.tmpArray addObject: @{@"level": [NSNumber numberWithInteger:self.level], @"type": @"tag", @"tag":tagName, @"content": content}];
    //[NSString stringWithFormat:@"<%@>%@</%@>", tagName, content, tagName];
}

- (void)content:(NSString *)content {
    [self.tmpArray addObject: @{@"level": [NSNumber numberWithInteger:self.level], @"type": @"content", @"content": content}];
}

- (void)tag:(NSString *)tagName field:(void(^)(DSL *dsl))someBlock{
   [self.tmpArray addObject: @{@"level": [NSNumber numberWithInteger:self.level], @"type": @"block", @"tag": tagName}];
    self.level++;
    DSL *dsl = [[DSL alloc] init];
    [self.children addObject:dsl];
    someBlock(dsl);
    
    [self pop];
}


//- (void)field:(void(^)(DSL *dsl, int level))someBlock{
//    someBlock(self, self.level);
//    [self pop];
//}

- (NSString *)pop {
    NSString *retString;
    for(NSInteger index=[self.tmpArray count]-1; index >= 0; index --) {
        NSDictionary *item = self.tmpArray[index];
        if([item[@"type"] isEqualToString:@"tag"]) {
            NSString *tmp = [NSString stringWithFormat:@"<%@>%@</%@>", item[@"tag"], item[@"content"], item[@"tag"]];
            self.string = [tmp stringByAppendingString:self.string];
            
            [self.tmpArray removeObjectAtIndex:index];
        }
        else if([item[@"type"] isEqualToString:@"block"]) {
            
            self.string = [NSString stringWithFormat:@"<%@>%@</%@>", item[@"tag"], self.string, item[@"tag"]];
            
            [self.dataArray addObject:@{@"level": item[@"level"], @"content":self.string}];
            retString = [self.string copy];
            self.string = @"";
            [self.tmpArray removeObjectAtIndex:index];
            
            break;
        }
    }
    
    return retString;
}
- (NSString *)output {
    //return [self.tmpArray componentsJoinedByString:@"\n"];
    
    NSEnumerator *enumerator = [self.tmpArray reverseObjectEnumerator];
    NSDictionary *item;
    NSString *html = @"", *tmp;
    while(item = [enumerator nextObject]) {
        if([item[@"type"] isEqualToString:@"tag"]) {
            tmp = [NSString stringWithFormat:@"<%@>%@</%@>", item[@"tag"], item[@"content"], item[@"tag"]];
            html = [tmp stringByAppendingString:html];
        }
        else if([item[@"type"] isEqualToString:@"block"]) {
            html = [NSString stringWithFormat:@"<%@>%@</%@>", item[@"tag"], html, item[@"tag"]];
        }
    }
    return html;
}
@end

#import <XCTest/XCTest.h>

@interface DSLTest : XCTestCase

@end

@implementation DSLTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    
    DSL *dsl = [[DSL alloc] init];
//    [dsl tag:@"div" content:@"hello"];
//    XCTAssertEqualObjects([dsl string], @"<div>hello</div>");
//    
    dsl = [[DSL alloc] init];
    [dsl tag:@"html" field:^(id html) {
        [html tag:@"head" field:^(id head) {
            [head tag:@"title" content:@"i am title"];
        }];
        [html tag:@"body" field:^(id body) {
            [body tag:@"h1" content:@"Objective-C DSL"];
            [body tag:@"div" field:^(id div) {
                [div tag:@"span" content:@"hello world"];
            }];
        }];
    }];
    
    //XCTAssertEqualObjects([dsl string], @"<html><head><title>i am title</title></head><body><h1>Objective-C DSL</h1><div><span>hello world</span></div></body></html>");
}
@end
