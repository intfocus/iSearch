//
//  ViewUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewUtils.h"
#import "MBProgressHUD.h"

@implementation ViewUtils

+ (void) simpleAlertView: delegate Title: (NSString*) title Message: (NSString*) message ButtonTitle: (NSString*) buttonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:buttonTitle otherButtonTitles:nil];
    [alert show];
}

+ (NSString *) dateToStr: (NSDate *)date Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}
+ (NSDate *) strToDate: (NSString *)str Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString: str];
}

+ (UIView *)loadNibClass:(Class)cls {
    UINib *nib=[UINib nibWithNibName:NSStringFromClass(cls) bundle:nil];
    NSArray *views=[nib instantiateWithOwner:nil options:nil];
    return [views firstObject];
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  弹出框架显示临时性文字
 *
 *  @param view controller.view
 *  @param text 提示文字
 */
+ (void)showPopupView:(UIView *)view Info:(NSString*)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode                      = MBProgressHUDModeText;
    hud.labelText                 = text;
    hud.margin                    = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}
/**
 *  tableViewCell根据内容自定义高度
 *
 *  @param text     cell显示内容
 *  @param width    cell的宽度，以此自适应高度
 *  @param fontSize 内容字段大小
 *
 *  @return CGSize
 */
+ (CGSize) sizeForTableViewCell:(NSString *)text
                          Width:(NSInteger)width
                       FontSize:(NSInteger)fontSize {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50000)];
    textLabel.text=text;
    textLabel.numberOfLines=0;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:fontSize];
    [textLabel sizeToFit];
    CGRect rect = textLabel.frame;;
    return rect.size;
}
@end