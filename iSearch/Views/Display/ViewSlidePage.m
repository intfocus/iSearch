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
    UIImage *image = [UIImage imageWithContentsOfFile:self.thumbnailPath];
    image = [self imageWithImage:image scaledToSize:CGSizeMake(213,187)];
    [self.thumbnail setImage:image];
}

- (void)deactivate {
    NSLog(@"deactivate: %@", labelPageNum.text);
    
    [self.thumbnail setImage:nil];
}

- (void)coverUserInterface:(NSNumber *)selectState {
    self.btnMask.enabled = ![selectState boolValue];
}

#pragma mark - asisstant methods
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
