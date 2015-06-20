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

/**
 *  <#Description#>
 *
 *  @param klassId    <#klassId description#>
 *  @param categoryID <#categoryID description#>
 */
- (void)setImageWith:(NSString *)typeID CategoryID:(NSString *)categoryID {
    NSString *imageName = [NSString stringWithFormat:@"%@.png", categoryID];
    NSString *imagePath = [FileUtils getPathName:THUMBNAIL_DIRNAME FileName:imageName];
    UIImage *image;
    if([FileUtils checkFileExist:imagePath isDir:NO]) {
        image = [UIImage imageWithContentsOfFile:imagePath];
    } else {
        image = [UIImage imageNamed:@"category-default.png"];
        NSLog(@"%@ not thumbnail.", categoryID);
    }
    image = [self imageWithImage:image scaledToSize:CGSizeMake(SIZE_GRID_VIEW_CELL_WIDTH, SIZE_IMAGE_COVER_HEIGHT)];

    [self.btnImageCover setImage:image forState:UIControlStateNormal];
    self.btnImageCover.frame = CGRectMake(0,0,
                                     SIZE_GRID_VIEW_CELL_WIDTH,
                                     SIZE_IMAGE_COVER_HEIGHT);
    
    [self bringSubviewToFront:self.btnImageCover];
}

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