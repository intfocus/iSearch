//
//  FileSlide.h
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef WebStructure_ViewSlide_h
#define WebStructure_ViewSlide_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface ViewSlide : UIView

@property (weak, nonatomic) IBOutlet UILabel *slideTitle;
@property (weak, nonatomic) IBOutlet UILabel *slideDate;
@property (weak, nonatomic) IBOutlet UILabel *slideDesc;
@property (weak, nonatomic) IBOutlet UIButton *slideDownload;

@property (strong, nonatomic) NSMutableDictionary *dict; // 该文件的信息，json格式


// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
// http download variables end


@end


#endif
