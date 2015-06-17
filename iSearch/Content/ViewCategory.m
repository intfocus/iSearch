//
//  ViewFolder.m
//  WebStructure
//
//  Created by lijunjie on 15-4-15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewCategory.h"

@implementation ViewCategory
@synthesize labelTitle;
@synthesize imageCover;

/**
 *  <#Description#>
 *
 *  @param klassId    <#klassId description#>
 *  @param categoryID <#categoryID description#>
 */
- (void)setImageWith:(NSString *)typeID CategoryID:(NSString *)categoryID {
    NSString *imageName = [NSString stringWithFormat:@"%@-%@.png", typeID, categoryID];
    UIImage *image = [UIImage imageNamed:imageName];
    image = [self imageWithImage:image scaledToSize:CGSizeMake(184, 154)];
    [self.imageCover setImage:image];
    
    self.btnEvent.frame = CGRectMake(0,0,
                                     image.size.width,
                                     image.size.height);
    
    [self bringSubviewToFront:self.btnEvent];
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