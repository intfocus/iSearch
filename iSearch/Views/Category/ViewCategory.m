//
//  ViewFolder.m
//  WebStructure
//
//  Created by lijunjie on 15-4-15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewCategory.h"
#import "const.h"
#import "FileUtils.h"

@implementation ViewCategory
@synthesize labelTitle;


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

#pragma mark - GMGridViewCellPotocol
- (void)activate {
    NSString *imageName = [NSString stringWithFormat:@"%@.png", self.categoryID];
    NSString *imagePath = [FileUtils getPathName:THUMBNAIL_DIRNAME FileName:imageName];
    UIImage *image;
    if([FileUtils checkFileExist:imagePath isDir:NO]) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        image = [self imageWithImage:image scaledToSize:CGSizeMake(184, 102)];
        
        [self.btnImageCover setImage:image forState:UIControlStateNormal];
        self.btnImageCover.frame = CGRectMake(0,0, 184, 102);
    }
    
    [self bringSubviewToFront:self.btnImageCover];
}

- (void)deactivate {
    [self.btnImageCover setImage:nil forState:UIControlStateNormal];
}
@end