//
//  PaintView.m
//  PaintDemo
//
//  Created by delacro on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PaintView
@synthesize paintColor = _paintColor;
@synthesize erase;
@synthesize laser;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.8;              // 图层透明度
        self.layer.shadowOffset = CGSizeMake(1, 1);  // 画笔阴影宽度
        self.backgroundColor = [UIColor clearColor]; // 背影颜色
        self.paintColor      = [UIColor blackColor]; // 画笔颜色
        // Initialization code
        linesArray = [[NSMutableArray alloc]init];   // 画笔轨迹点记录数组
        // 手指在屏幕划动姿势函数绑定
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        //self.laser = YES;
        //[panGesture release];
    }
    return self;
}

- (void)dealloc {
    //[linesArray release];
    //[_paintColor release];
    //[super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 25);
    //NSLog(@"color:%@",_paintColor);

    // 激光笔状态
    if(self.laser) {
        //[[linesArray reverseObjectEnumerator] allObjects];
        NSDictionary *lineDic = [linesArray lastObject];
        UIColor *lineColor = [lineDic objectForKey:@"color"];
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        //NSArray *linePointArray = [[[lineDic objectForKey:@"line"] reverseObjectEnumerator] allObjects];
        NSMutableArray *linePointArray = [lineDic objectForKey:@"line"];

        CGPoint point = [[linePointArray lastObject]CGPointValue];
        
        CGContextFillEllipseInRect(context, CGRectMake(point.x-20, point.y-40, 20, 20));
        CGContextSetRGBFillColor(context, 0, 0, 255, 1.0);

    } else {
        for (NSDictionary *lineDic in linesArray) {
            UIColor *lineColor = [lineDic objectForKey:@"color"];
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
            CGMutablePathRef paintPath = CGPathCreateMutable();
            NSArray *linePointArray = [lineDic objectForKey:@"line"];
            for (NSInteger i=0; i<linePointArray.count; i++) {
                CGPoint point = [[linePointArray objectAtIndex:i]CGPointValue];
                if (i==0) {
                    CGPathMoveToPoint(paintPath, NULL, point.x, point.y);
                }else {
                    CGPathAddLineToPoint(paintPath, NULL, point.x, point.y);
                }
            }
            CGContextAddPath(context, paintPath);
            CGContextStrokePath(context);
            
            if ([lineDic objectForKey:@"eraseArray"]) {
                //NSLog(@"color:%@",lineColor);
                NSMutableArray *eraseArray = [lineDic objectForKey:@"eraseArray"];
                // 橡皮擦划过的点填充白色，如果背影色不为白色，则橡皮擦效果无效
                CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
                CGMutablePathRef paintPath = CGPathCreateMutable();
                for (NSInteger i=0; i<eraseArray.count; i++) {
                    CGPoint point = [[eraseArray objectAtIndex:i]CGPointValue];
                    //NSLog(@"erase point:%@",NSStringFromCGPoint(point));
                    if (i==0) {
                        //CGContextMoveToPoint(context, point.x, point.y);
                        CGPathMoveToPoint(paintPath, NULL, point.x, point.y);
                    }else {
                        //CGContextAddLineToPoint(context, point.x, point.y);
                        CGPathAddLineToPoint(paintPath, NULL, point.x, point.y);
                    }
                }
                CGContextAddPath(context, paintPath);
                CGContextStrokePath(context);
            }
        }
        
    }
}


-(void)panGesture:(UIPanGestureRecognizer*)thePan{
    CGPoint touchPoint = [thePan locationInView:self];
    // 橡皮擦状态
    if (self.erase) {
        if (thePan.state==UIGestureRecognizerStateChanged) {
            for (NSMutableDictionary *lineDic in linesArray) {
                NSMutableArray *linePointArray = [lineDic objectForKey:@"line"];
                for (NSInteger i=0; i<linePointArray.count; i++) {
                    CGPoint point = [[linePointArray objectAtIndex:i]CGPointValue];
                    CGFloat distance = powf(point.x-touchPoint.x,point.y-touchPoint.y);
                    if (distance<20) {
                        NSMutableArray *eraseArray;
                        if ([lineDic objectForKey:@"eraseArray"]) {
                            eraseArray = [lineDic objectForKey:@"eraseArray"];
                        }else {
                            eraseArray = [NSMutableArray array];
                        }
                        [eraseArray addObject:[NSValue valueWithCGPoint:touchPoint]];
                        [lineDic setObject:eraseArray forKey:@"eraseArray"];
                        // Marks the specified rectangle of the receiver as needing to be redrawn.
                        CGRect paintRect = CGRectMake(touchPoint.x-50, touchPoint.y-50, 100, 100);
                        [self setNeedsDisplayInRect:paintRect];
                        //[self setNeedsDisplay];
                        continue;
                    }
                }
            }
        }
        //[self eraseLine:currentLineDic erase:[thePan locationInView:self]];
    // 绘图状态
    } else {
        if (thePan.state==UIGestureRecognizerStateBegan) {
            NSMutableArray *currentLineArray = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:touchPoint]];
            NSMutableDictionary *lineDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentLineArray,@"line",_paintColor,@"color", nil];
            NSLog(@"panGesture: <x=%f, y=%f>", touchPoint.x, touchPoint.y);
            [linesArray addObject:lineDic];
        } else if(thePan.state==UIGestureRecognizerStateChanged){
            NSMutableDictionary *lineDic = [linesArray lastObject];
            NSMutableArray *currentLineArray = [lineDic objectForKey:@"line"];
            [currentLineArray addObject:[NSValue valueWithCGPoint:touchPoint]];
            CGRect paintRect = CGRectMake(touchPoint.x-50, touchPoint.y-50, 100, 100);
            [self setNeedsDisplayInRect:paintRect];
        } else if(thePan.state==UIGestureRecognizerStateEnded){
            //TODO:激光笔状态，结束时应该把屏幕所以痕迹清空
        }
    }
}
@end
