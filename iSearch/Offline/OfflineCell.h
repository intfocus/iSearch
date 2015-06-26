//
//  OfflineCell.h
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_OfflineCell_h
#define iSearch_OfflineCell_h
#import <UIKit/UIKit.h>
@class OfflineViewController;

@interface OfflineCell : UITableViewCell
@property (weak, nonatomic) OfflineViewController *offlineViewController;
@property (weak, nonatomic) IBOutlet UILabel *labelFileName;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UILabel *labelZipSize;
@property (weak, nonatomic) IBOutlet UILabel *labelDownloadState;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadOrView;

@property (strong, nonatomic) NSMutableDictionary *dict;


// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
// http download variables end

- (void)dismissDisplayViewController;
@end

#endif
