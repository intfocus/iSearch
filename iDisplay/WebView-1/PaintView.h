//
//  PaintView.h
//  PaintDemo
//
//  Created by delacro on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintView : UIView{
    NSMutableArray *linesArray;
    //NSMutableArray *currentLineArray;
    UIImage *currentImage;
}
@property(nonatomic,retain) UIColor *paintColor; // 画皮颜色
@property(nonatomic,assign) BOOL erase;          // 橡皮擦状态
@property(nonatomic,assign) BOOL laser;          // 激光笔状态
@end
