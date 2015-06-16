//
//  GMGridViewCell.h
//  GMGridView
//
//  Created by Gulam Moledina on 11-10-22.
//  Copyright (c) 2011 GMoledina.ca. All rights reserved.
//
//  Latest code can be found on GitHub: https://github.com/gmoledina/GMGridView
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Modify by junjie.li at 2014/05/18
//  内容重组时，文件页面选择进入收藏...
//
//  function:
//      UIImage *selectingButtonIcon;
//      UIImage *selectedButtonIcon;
//
//
//
#import <UIKit/UIKit.h>
#import "GMGridView-Constants.h"
#define DEBUG 1
#import "ExtendNSLogFunctionality.h"

@interface GMGridViewCell : UIView
{
    
}

@property (nonatomic, strong) UIView *contentView;         // The contentView - default is nil
@property (nonatomic, strong) UIImage *deleteButtonIcon;   // Delete button image
@property (nonatomic, strong) UIImage *selectingButtonIcon;// 编辑状态下，显示待选择状态
@property (nonatomic, strong) UIImage *selectedButtonIcon; // 编辑状态下，已选择状态
@property (nonatomic) CGPoint deleteButtonOffset;          // Delete button offset relative to the origin
@property (nonatomic) CGPoint selectingButtonOffset;       // 把整个Cell撑满
@property (nonatomic) CGPoint selectedButtonOffset;        // 把整个Cell撑满

- (void)prepareForReuse;

@end
