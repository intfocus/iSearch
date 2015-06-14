//
//  ViewController.m
//  iOffeline
//
//  Created by lijunjie on 15/5/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  离线搜索
//  1. 有网络时连接服务器获取文档列表(json)格式
//      GET /OFFLINE_URL_PATH, {
//          user: user-name or user-email,
//          lang: zh-CN -- app language
//      }
//      Response
//      [{
//          id: fileId,
//          type: 1,
//          name: fileName,
//          desc: fileDesc,
//          tags: fileTags,
//          page_count: filePageCount,
//          zip_url: fileDowloadUrl **format: zip**
//      }]三
//  2. 文档列表写入数据库（先清除旧数据）[TODO: 如何保证写入顺利?]
//  3. 搜索使用SQL语句 like
//  **注意**
//  1. 从服务器获取数据，使用OFFLINE_FIELD_*
//     从本地数据取数据，使用OFFLINE_COLUMN_*
#import "OfflineViewController.h"
#import <UIKit/UIKit.h>
#import "DatabaseUtils.h"
#import "const.h"
#import "PopupView.h"
#import "HttpUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface OfflineViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, nonatomic) DatabaseUtils  *database;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (nonatomic, nonatomic) PopupView      *popupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 初始化配置数据库
    self.database = [DatabaseUtils setUP];

    self.title = @"离线搜索";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(reDownloadFilesList)];
    
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.dataList = [[NSMutableArray alloc] init];
    self.dataList = [self.database searchFilesWithKeywords:@[]];
    [self.tableView reloadData];
    
    // 搜索框内容改变时，实时搜索并展示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SearchValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.searchTextField addTarget:self action:@selector(SearchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    // 信息提示
    self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    self.popupView.ParentView = self.view;
    [self showPopupView: [NSString stringWithFormat:@"缓存: %lu行", (unsigned long)self.dataList.count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)SearchValueChanged:(NSNotification*)notifice {
    UITextField *field=[notifice object];
    NSString *searchText = [field.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *keywords = [searchText componentsSeparatedByString:NSLocalizedString(@" ", nil)];
    
    NSLog(@"%@", keywords);
    self.dataList = [self.database searchFilesWithKeywords:keywords];
    [self.tableView reloadData];
    
    [self showPopupView: [NSString stringWithFormat:@"筛选: %lu行", (unsigned long)self.dataList.count]];
}

- (void)reDownloadFilesList {
    NSString *deptID = @"10";
    NSError *error;
    NSString *urlPath = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", OFFLINE_URL_PATH, PARAM_LANG, APP_LANG, OFFLINE_PARAM_DEPTID, deptID];
    NSString *response = [HttpUtils httpGet:urlPath];
    NSLog(@"url: %@\response: %@", urlPath, response);
    NSMutableDictionary *mutableDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    NSMutableArray *mutableArray = mutableDict[OFFLINE_FIELD_DATA];
    
    NSErrorPrint(error, @"string convert into json");
    if(!error) {
        [self showPopupView: [NSString stringWithFormat:@"刷新: %lu行", (unsigned long)mutableArray.count]];
        // 插入前先删除
        [self.database executeSQL:[NSString stringWithFormat:@"delete from %@;" , OFFLINE_TABLE_NAME]];
        
        NSLog(@"Get %@ successfully.", urlPath);
        NSLog(@"DataList count: %lu", (unsigned long)mutableArray.count);

        NSString *tmpSql = [[NSString alloc] init];
        NSMutableString *insertSql = [[NSMutableString alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for(dict in mutableArray) {
            tmpSql = [NSString stringWithFormat:@"insert into %@(%@,    %@,   %@,   %@,   %@,   %@,   %@,   %@,   %@) \
                                                          values('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');\n",
                      OFFLINE_TABLE_NAME,
                      OFFLINE_COLUMN_FILEID,
                      OFFLINE_COLUMN_NAME,
                      OFFLINE_COLUMN_TYPE,
                      OFFLINE_COLUMN_DESC,
                      OFFLINE_COLUMN_TAGS,
                      OFFLINE_COLUMN_PAGENUM,
                      OFFLINE_COLUMN_CATEGORYNAME,
                      OFFLINE_COLUMN_ZIPURL,
                      OFFLINE_COLUMN_ZIPSIZE,
                      dict[OFFLINE_FIELD_ID],
                      dict[OFFLINE_FIELD_NAME],
                      dict[OFFLINE_FIELD_TYPE],
                      dict[OFFLINE_FIELD_DESC],
                      dict[OFFLINE_FIELD_TYPE],
                      dict[OFFLINE_FIELD_PAGENUM],
                      dict[OFFLINE_FIELD_CATEGORYNAME],
                      dict[OFFLINE_FIELD_ID],// ZipUrl由FileID拼接
                      dict[OFFLINE_FIELD_ZIPSIZE]];
            [insertSql appendString:tmpSql];
        }
        //NSLog(@"DataList: %@", insertSql);
        [self.database executeSQL:insertSql];
        
        self.dataList = [self.database searchFilesWithKeywords:@[]];
        [self.tableView reloadData];
        
    } else {
        [self showPopupView: [error localizedDescription]];
        NSLog(@"Get %@%@ failed.", BASE_URL, OFFLINE_URL_PATH);
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void) showPopupView: (NSString*) text {
    [self.popupView setText: text];
    [self.view addSubview:self.popupView];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NSInteger cellIndex = [indexPath row];
    NSLog(@"indexPath - %d", cellIndex);
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    NSMutableDictionary *dict = [self.dataList objectAtIndex:cellIndex];
    cell.textLabel.text       = [NSString stringWithFormat:@"%@ - %@", dict[OFFLINE_COLUMN_NAME], dict[OFFLINE_COLUMN_FILEID]];
    cell.detailTextLabel.text = [dict[OFFLINE_COLUMN_DESC] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16.0]];
    
    // remove blue selection
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
//    [cell addGestureRecognizer:gesture];
    
    return cell;
}


@end
