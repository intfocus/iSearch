//
//  JayPlayTest.m
//  iSearch
//
//  Created by lijunjie on 15/7/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface JayPlayTest : XCTestCase

@end

@implementation JayPlayTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}
#pragma mark -  阿拉伯数字转化为汉语数字
- (NSString *)translation:(NSString *)arebic {
    NSString *str             = arebic;
    NSArray *arabic_numerals  = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits           = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary  = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        NSString *b = digits[str.length -i-1];
        NSString *sum = [a stringByAppendingString:b];
        if ([a isEqualToString:chinese_numerals[9]])
        {
            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
            {
                sum = b;
                if ([[sums lastObject] isEqualToString:chinese_numerals[9]])
                {
                    [sums removeLastObject];
                }
            }else
            {
                sum = chinese_numerals[9];
            }
            
            if ([[sums lastObject] isEqualToString:sum])
            {
                continue;
            }
        }
        
        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums  componentsJoinedByString:@""];
    NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
    return chinese;
}

- (void)testTranslation {
    XCTAssertEqualObjects([self translation:@"127"], @"一百二十七");
    XCTAssertEqualObjects([self translation:@"1270"], @"一千二百七十");
    XCTAssertEqualObjects([self translation:@"12700"], @"一万二千七百");
}


#pragma mark - args
//1.参数类型是NSString类型,后面params是第一个参数,它后面跟着逗号和三个点(固定格式)
- (void)dynaArgs:(NSString*)params,... {
    NSString* curStr;
    va_list list;
    if(params)
    {
        //1.取得第一个参数的值
        NSLog(@"%@", params);
        //2.从第2个参数开始，依此取得所有参数的值
        va_start(list, params);
        while ((curStr = va_arg(list, NSString*))){
            NSLog(@"%@", curStr);
        }
        va_end(list);
    }
}

- (void)testDynaArgs {
    //2.测试改函数
    [self  dynaArgs:@"1",@"2",@"3",nil];
    //3.注意,一定要写nil,不然改函数无法跳出while循环.
}

@end
