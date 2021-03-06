//
//  ViewController.m
//  iOffeline
//
//  Created by lijunjie on 15/5/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  离线搜索
//  **point** api返回字段与ContentViewController一致
//
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

#import "User.h"
#import "Slide.h"
#import "const.h"
#import "FileUtils.h"
#import "HttpUtils.h"
#import "DatabaseUtils.h"
#import "MBProgressHUD.h"
#import "ExtendNSLogFunctionality.h"
#import "OfflineCell.h"
#import "DisplayViewController.h"

@interface OfflineViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, nonatomic) DatabaseUtils  *database;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化配置数据库
    self.database = [[DatabaseUtils alloc] init];

    self.title = @"离线搜索";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(refreshSlideList:)];
    
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.dataList = [[NSMutableArray alloc] init];
    self.dataList = [self.database searchFilesWithKeywords:@[]];
    [self.tableView reloadData];
    
    // 搜索框内容改变时，实时搜索并展示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SearchValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.searchTextField setTag:TextFieldSearchDB];
    [self.searchTextField addTarget:self action:@selector(SearchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  监听输入框内容变化
 *
 *  @param notifice notifice
 */
- (void)SearchValueChanged:(NSNotification *)notifice {
    UITextField *field = [notifice object];
    // 本指定TextField，则放弃监听
    if([field tag] != TextFieldSearchDB) return;
    
    NSString *searchText = [field.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *keywords = [searchText componentsSeparatedByString:NSLocalizedString(@" ", nil)];
    
    NSLog(@"%@", keywords);
    self.dataList = [self.database searchFilesWithKeywords:keywords];
    [self.tableView reloadData];
    
    [self showPopupView: [NSString stringWithFormat:@"筛选: %lu行", (unsigned long)self.dataList.count]];
}

/**
 *  更新本地文档列表；
 *  先删除后插入；
 */
- (IBAction)refreshSlideList:(UIBarButtonItem *)sender {
    User *user = [[User alloc] init];
    NSError *error;
    NSString *urlPath = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", OFFLINE_URL_PATH, PARAM_LANG, APP_LANG, OFFLINE_PARAM_DEPTID, user.deptID];
    NSString *response = [HttpUtils httpGet:urlPath];

    NSMutableDictionary *mutableDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    NSMutableArray *mutableArray = mutableDict[CONTENT_FIELD_DATA];
    
    NSErrorPrint(error, @"string convert into json");
    if(!error) {
        [self showPopupView: [NSString stringWithFormat:@"刷新: %lu行", (unsigned long)mutableArray.count]];
        // 插入前先删除
        [self.database executeSQL:[NSString stringWithFormat:@"delete from %@;" , OFFLINE_TABLE_NAME]];

        Slide *slide;
        NSString *tmpSql = [[NSString alloc] init];
        NSMutableString *insertSql = [[NSMutableString alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for(dict in mutableArray) {
            
            // append `insert` sql sentences.
            tmpSql = [NSString stringWithFormat:@"insert into %@(%@,    %@,   %@,   %@,   %@,   %@,   %@,   %@,   %@,   %@)  \
                                                          values('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');\n",
                      OFFLINE_TABLE_NAME,
                      OFFLINE_COLUMN_FILEID,
                      OFFLINE_COLUMN_NAME,
                      OFFLINE_COLUMN_TITLE,
                      OFFLINE_COLUMN_TYPE,
                      OFFLINE_COLUMN_DESC,
                      OFFLINE_COLUMN_TAGS,
                      OFFLINE_COLUMN_PAGENUM,
                      OFFLINE_COLUMN_CATEGORYNAME,
                      OFFLINE_COLUMN_ZIPURL,
                      OFFLINE_COLUMN_ZIPSIZE,
                      dict[CONTENT_FIELD_ID],
                      dict[CONTENT_FIELD_NAME],
                      dict[CONTENT_FIELD_TITLE],
                      dict[CONTENT_FIELD_TYPE],
                      dict[CONTENT_FIELD_DESC],
                      dict[CONTENT_FIELD_ID],
                      dict[CONTENT_FIELD_PAGENUM],
                      dict[CONTENT_FIELD_CATEGORYNAME],
                      dict[CONTENT_FIELD_ID],// ZipUrl由FileID拼接
                      dict[CONTENT_FIELD_ZIPSIZE]];
            [insertSql appendString:tmpSql];
            
            // update local slide cache info
            if([dict[CONTENT_FIELD_TYPE] isEqualToString:CONTENT_SLIDE]) {
                // update local slide desc when already download
                if(isNil(slide)) {
                    slide = nil;
                }
                slide = [[Slide alloc]initSlide:dict isFavorite:NO];
                if(slide.isDownloaded) {
                    [slide save];
                }
                // write into cache then [view] slide info with popup view
                [slide toCached];
                /**
                 *  warning: 此处不更新desc的SLIDE_DESC_LOCAL_UPDATEDAT,该信息用来记录用户的操作时候
                 */
            }
        }
        [self.database executeSQL:insertSql];
        
        self.dataList = [self.database searchFilesWithKeywords:@[]];
        [self.tableView reloadData];
        
    } else {
        [self showPopupView: [error localizedDescription]];
        NSLog(@"Get %@%@ failed.", BASE_URL, OFFLINE_URL_PATH);
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)showPopupView: (NSString*) text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NSInteger cellIndex = [indexPath row];
    NSMutableDictionary *currentDict = [self.dataList objectAtIndex:cellIndex];
    //NSLog(@"indexPath - %d", cellIndex);
    
    OfflineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OfflineCell" owner:self options:nil] lastObject];
    }
    cell.labelFileName.text = currentDict[OFFLINE_COLUMN_TITLE];
    cell.labelCategory.text = currentDict[OFFLINE_COLUMN_CATEGORYNAME];
    cell.labelZipSize.text  = [FileUtils humanFileSize:currentDict[OFFLINE_COLUMN_ZIPSIZE]];
    cell.offlineViewController = self;
    cell.dict = currentDict;

    return cell;
}
/**
 *  Cell高度
 *
 *  @param tableView
 *  @param indexPath <#indexPath description#>
 *
 *  @return Cell高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

@end
