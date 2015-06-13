//
//  GMGridViewCell.m
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

#import "GMGridViewCell+Extended.h"
#import "UIView+GMGridViewAdditions.h"

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface Private
//////////////////////////////////////////////////////////////

@interface GMGridViewCell (Privates) 

- (void)actionDelete;
- (void)actionSelect;

@end

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation GMGridViewCell
//////////////////////////////////////////////////////////////

@implementation GMGridViewCell

@synthesize contentView = _contentView;
@synthesize editing = _editing;
@synthesize inShakingMode = _inShakingMode;
@synthesize fullSize = _fullSize;
@synthesize fullSizeView = _fullSizeView;
@synthesize inFullSizeMode = _inFullSizeMode;
@synthesize defaultFullsizeViewResizingMask = _defaultFullsizeViewResizingMask;
@synthesize deleteButton = _deleteButton;
@synthesize selectButton = _selectButton;
@synthesize deleteBlock = _deleteBlock;
@synthesize selectBlock = _selectBlock;
@synthesize deleteButtonIcon = _deleteButtonIcon;
@synthesize selectingButtonIcon = _selectingButtonIcon;
@synthesize selectedButtonIcon = _selectedButtonIcon;
@synthesize deleteButtonOffset;
@synthesize selectingButtonOffset;
@synthesize selectedButtonOffset;

//////////////////////////////////////////////////////////////
#pragma mark Constructors
//////////////////////////////////////////////////////////////

- (id)init
{
    if (self = [self initWithFrame:CGRectZero]) 
    {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.autoresizesSubviews = !YES;
        self.editing = NO;
        self.selectState = NO;
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton = deleteButton;
        [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.deleteButton.showsTouchWhenHighlighted = YES;
        self.deleteButtonIcon = nil;
        self.deleteButtonOffset = CGPointMake(-5, -5);
        self.deleteButton.alpha = 0;
        [self addSubview:deleteButton];
        [deleteButton addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];
        
        // add by junjie.li
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectButton = selectButton;
        self.selectButton.showsTouchWhenHighlighted = YES;
        self.selectingButtonIcon = nil;
        self.selectedButtonIcon = nil;
        self.selectingButtonOffset = CGPointMake(0, 0);
        self.selectedButtonOffset = CGPointMake(0, 0);
        self.selectButton.alpha = 0;
        [self addSubview:selectButton];
        [selectButton addTarget:self action:@selector(actionSelect) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////

- (void)layoutSubviews
{
    if(self.inFullSizeMode)
    {
        CGPoint origin = CGPointMake((self.bounds.size.width - self.fullSize.width) / 2, 
                                     (self.bounds.size.height - self.fullSize.height) / 2);
        self.fullSizeView.frame = CGRectMake(origin.x, origin.y, self.fullSize.width, self.fullSize.height);
    }
    else
    {
        self.fullSizeView.frame = self.bounds;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark Setters / getters
//////////////////////////////////////////////////////////////

- (void)setContentView:(UIView *)contentView
{
    [self shake:NO];
    [self.contentView removeFromSuperview];
    
    if(self.contentView)
    {
        contentView.frame = self.contentView.frame;
    }
    _contentView = contentView;
    
    self.contentView.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:self.contentView];
    
    [self bringSubviewToFront:self.deleteButton];
    // add by junjie.li
    [self bringSubviewToFront:self.selectButton];
}

- (void)setFullSizeView:(UIView *)fullSizeView
{
    if ([self isInFullSizeMode]) 
    {
        fullSizeView.frame = _fullSizeView.frame;
        fullSizeView.alpha = _fullSizeView.alpha;
    }
    else
    {
        fullSizeView.frame = self.bounds;
        fullSizeView.alpha = 0;
    }
    
    self.defaultFullsizeViewResizingMask = fullSizeView.autoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    fullSizeView.autoresizingMask = _fullSizeView.autoresizingMask;
    
    [_fullSizeView removeFromSuperview];
    _fullSizeView = fullSizeView;
    [self addSubview:_fullSizeView];
    
    [self bringSubviewToFront:self.deleteButton];
}

- (void)setFullSize:(CGSize)fullSize
{
    _fullSize = fullSize;
    
    [self setNeedsLayout];
}

- (void)setEditing:(BOOL)editing
{
    //NSLog(@"click Cell#setEditing %d", editing);
    _editing = editing;
    
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
                     animations:^{
                         self.deleteButton.alpha = editing ? 1 : 0;
                     } 
                     completion:nil];
    
    self.contentView.userInteractionEnabled = !editing;
    //[self shakeStatus:editing];
}

- (void)setDeleteButtonOffset:(CGPoint)offset
{
    self.deleteButton.frame = CGRectMake(offset.x, 
                                         offset.y, 
                                         self.deleteButton.frame.size.width, 
                                         self.deleteButton.frame.size.height);
}

- (CGPoint)deleteButtonOffset
{
    return self.deleteButton.frame.origin;
}

- (void)setDeleteButtonIcon:(UIImage *)deleteButtonIcon
{
    [self.deleteButton setImage:deleteButtonIcon forState:UIControlStateNormal];
    
    if (deleteButtonIcon) 
    {
        self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, 
                                             self.deleteButton.frame.origin.y, 
                                             deleteButtonIcon.size.width, 
                                             deleteButtonIcon.size.height);
        
        [self.deleteButton setTitle:nil forState:UIControlStateNormal];
        [self.deleteButton setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, 
                                             self.deleteButton.frame.origin.y, 
                                             35, 
                                             35);
        
        [self.deleteButton setTitle:@"X" forState:UIControlStateNormal];
        [self.deleteButton setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    
}

- (UIImage *)deleteButtonIcon
{
    return [self.deleteButton currentImage];
}

// add by junjie.li
- (void)setSelectState:(BOOL)selectState {
    // 在设置_selectState前把selected处理掉。
    // 设置为非编辑状态时，所有cell的selected都要设置为false
    // 再进入编辑状态时，重新选择
    if(selectState) {
        [self setSelected: false];
    }
    _selectState = selectState;
    
    self.selectButton.alpha = selectState ? 1 : 0;
    [self.selectButton setImage:(selectState ? _selectingButtonIcon : nil) forState:UIControlStateNormal];
    
    self.contentView.userInteractionEnabled = !selectState;
    NSLog(@"GridViewCell#264 - selectState: %d", selectState);
}

- (void)setSelected:(BOOL)selected {
    // 仅处理编辑状态时的情况
    if(!self.selectState) return;
    
    _selected = selected;
    [self.selectButton setImage:(selected ? _selectedButtonIcon : _selectingButtonIcon) forState:UIControlStateNormal];
    
    NSLog(@"275 %@", [[self.selectButton currentImage] accessibilityLabel]);

    self.contentView.userInteractionEnabled = !selected;
    NSLog(@"GridViewCell#271 - setSelected: %d", selected);
}

- (void)setSelectButtonOffset:(CGPoint)offset {
    self.selectButton.frame = CGRectMake(offset.x,
                                         offset.y,
                                         self.selectButton.frame.size.width,
                                         self.selectButton.frame.size.height);
}

- (CGPoint)selectButtonOffset {
    return self.selectButton.frame.origin;
}

// 可以传递两种状态的ButtonIcon
- (void)setSelectingButtonIcon:(UIImage *)selectButtonIcon {
    _selectingButtonIcon = selectButtonIcon;
    NSLog(@"set selecting");
    
    // set icon when click select it
    [self.selectButton setImage:nil forState:UIControlStateNormal];
    NSLog(@"setSelectingButtonIcon#295 %@", [selectButtonIcon accessibilityIdentifier]);
    
    if (selectButtonIcon) {
        self.selectButton.frame = CGRectMake(self.selectButton.frame.origin.x,
                                             self.selectButton.frame.origin.y,
                                             selectButtonIcon.size.width,
                                             selectButtonIcon.size.height);
        
        [self.selectButton setTitle:nil forState:UIControlStateNormal];
        [self.selectButton setBackgroundColor:[UIColor blackColor]];
    }
}

- (void)setSelectedButtonIcon:(UIImage *)selectButtonIcon {
    _selectedButtonIcon = selectButtonIcon;
    NSLog(@"set selected");
}

- (UIImage *)selectButtonIcon {
    return [self.selectButton currentImage];
}

//////////////////////////////////////////////////////////////
#pragma mark Private methods
//////////////////////////////////////////////////////////////

- (void)actionDelete
{
    if (self.deleteBlock) 
    {
        self.deleteBlock(self);
    }
}

- (void)actionSelect {
    if (self.selectBlock) {
        self.selectBlock(self);
    }
}

//////////////////////////////////////////////////////////////
#pragma mark Public methods
//////////////////////////////////////////////////////////////

- (void)prepareForReuse
{
    self.fullSize = CGSizeZero;
    self.fullSizeView = nil;
    self.editing = NO;
    self.deleteBlock = nil;
    self.selectBlock = nil;
}

- (void)shake:(BOOL)on
{
    if ((on && !self.inShakingMode) || (!on && self.inShakingMode)) 
    {
        [self.contentView shakeStatus:on];
        _inShakingMode = on;
    }
}

- (void)switchToFullSizeMode:(BOOL)fullSizeEnabled
{
    if (fullSizeEnabled) 
    {
        self.fullSizeView.autoresizingMask = self.defaultFullsizeViewResizingMask;
        
        CGPoint center = self.fullSizeView.center;
        self.fullSizeView.frame = CGRectMake(self.fullSizeView.frame.origin.x, self.fullSizeView.frame.origin.y, self.fullSize.width, self.fullSize.height);
        self.fullSizeView.center = center;
        
        _inFullSizeMode = YES;
        
        self.fullSizeView.alpha = MAX(self.fullSizeView.alpha, self.contentView.alpha);
        self.contentView.alpha  = 0;
        
        [UIView animateWithDuration:0.3 
                         animations:^{
                             self.fullSizeView.alpha = 1;
                             self.fullSizeView.frame = CGRectMake(self.fullSizeView.frame.origin.x, self.fullSizeView.frame.origin.y, self.fullSize.width, self.fullSize.height);
                             self.fullSizeView.center = center;
                         } 
                         completion:^(BOOL finished){
                             [self setNeedsLayout];
                         }
        ];
    }
    else
    {
        self.fullSizeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _inFullSizeMode = NO;
        self.fullSizeView.alpha = 0;
        self.contentView.alpha  = 0.6;
        
        [UIView animateWithDuration:0.3 
                         animations:^{
                             self.contentView.alpha  = 1;
                             self.fullSizeView.frame = self.bounds;
                         } 
                         completion:^(BOOL finished){
                             [self setNeedsLayout];
                         }
         ];
    }
}

- (void)stepToFullsizeWithAlpha:(CGFloat)alpha {
    return; // not supported anymore - to be fixed
    
    
//    if (![self isInFullSizeMode])  {
//        alpha = MAX(0, alpha);
//        alpha = MIN(1, alpha);
//        
//        self.fullSizeView.alpha = alpha;
//        self.contentView.alpha  = 1.4 - alpha;
//    }
}

@end
