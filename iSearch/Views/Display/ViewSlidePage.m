//
//  ViewFilePage.m
//  WebView-1
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewSlidePage.h"
#import "const.h"
#import "message.h"
#import "FileUtils.h"
#import "ScanViewController.h"

@interface ViewSlidePage()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail; // 缩略图

@end
@implementation ViewSlidePage
@synthesize labelFrom;
@synthesize labelPageNum;


- (void)hightLight {
    self.thumbnail.layer.borderWidth = 2.0f;
    self.thumbnail.layer.borderColor = [UIColor colorWithRed:229/255.0 green:118/255.0 blue:127/255.0 alpha:1].CGColor;
}

- (void)activate {
    NSLog(@"activate: %@", labelPageNum.text);
    [self.thumbnail setImage:[UIImage imageWithContentsOfFile:self.thumbnailPath]];
}

- (void)deactivate {
    NSLog(@"deactivate: %@", labelPageNum.text);
    
    [self.thumbnail setImage:nil];
}

- (void)coverUserInterface:(NSNumber *)selectState {
    self.btnMask.enabled = ![selectState boolValue];
}
@end
