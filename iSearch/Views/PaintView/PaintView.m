//
//  PaintView.m
//  PaintDemo
//
//  Created by delacro on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import <QuartzCore/QuartzCore.h>

@interface PaintView ()

@property (nonatomic) UIImageView *penIV;

@end

@implementation PaintView
@synthesize paintColor = _paintColor;
@synthesize erase;
@synthesize laser;
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.8;              // 图层透明度
        self.layer.shadowOffset = CGSizeMake(1, 1);  // 画笔阴影宽度
        self.backgroundColor = [UIColor clearColor]; // 背影颜色
        self.paintColor      = [UIColor blackColor]; // 画笔颜色
        // Initialization code
        linesArray = [[NSMutableArray alloc]init];   // 画笔轨迹点记录数组
        
        self.penIV = [[UIImageView alloc] initWithFrame:CGRectMake(-22, -22, 22, 22)];
        self.penIV.image = [UIImage imageNamed:@"pen"];
        [self addSubview:self.penIV];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panGesture];
        
        UILongPressGestureRecognizer *gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        gestureLongPress.minimumPressDuration = 0.1f; //seconds
        [self addGestureRecognizer:gestureLongPress];
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
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10);

    // 绘图
    if(!self.laser) {
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


-(void)panGesture:(UIPanGestureRecognizer*)thePan {
    CGPoint touchPoint = [thePan locationInView:self];

    if(self.laser) {
        CGPoint point = [thePan locationInView:self];
        if (thePan.state == UIGestureRecognizerStateBegan) {
            self.penIV.hidden = NO;
            self.penIV.frame = CGRectMake(point.x - 11, point.y - 61, 22, 22);
            [self bringSubviewToFront:self.penIV];
            [self setNeedsDisplay];
            NSLog(@"begin");
        }
        else if (thePan.state == UIGestureRecognizerStateChanged) {
            self.penIV.frame = CGRectMake(point.x - 11, point.y - 61, 22, 22);
        }
        else if (thePan.state == UIGestureRecognizerStateEnded) {
            self.penIV.hidden = YES;
        }
    } else {
        if (thePan.state==UIGestureRecognizerStateBegan) {
            NSMutableArray *currentLineArray = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:touchPoint]];
            NSMutableDictionary *lineDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentLineArray,@"line",_paintColor,@"color", nil];
            NSLog(@"panGesture: <x=%f, y=%f>", touchPoint.x, touchPoint.y);
            [linesArray addObject:lineDic];
        }
        else if(thePan.state==UIGestureRecognizerStateChanged){
            NSMutableDictionary *lineDic = [linesArray lastObject];
            NSMutableArray *currentLineArray = [lineDic objectForKey:@"line"];
            [currentLineArray addObject:[NSValue valueWithCGPoint:touchPoint]];
            CGRect paintRect = CGRectMake(touchPoint.x-50, touchPoint.y-50, 100, 100);
            [self setNeedsDisplayInRect:paintRect];
        }
        else if(thePan.state==UIGestureRecognizerStateEnded){
        }
    }
}

-(void)tapGesture:(UITapGestureRecognizer*)theTap {
    if(self.laser) {
        CGPoint point = [theTap locationInView:self];
        
        if (theTap.state == UIGestureRecognizerStateBegan) {
            self.penIV.hidden = NO;
        }
        else if(theTap.state==UIGestureRecognizerStateEnded){
            self.penIV.hidden = YES;
        }
        self.penIV.frame = CGRectMake(point.x - 11, point.y - 51, 22, 22);
    }
}
- (void)clearDrawRect {
    [linesArray removeAllObjects];
}
@end
