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
#import "FileUtils.h"
#import "HttpUtils.h"
#import "ExtendNSLogFunctionality.h"
#import "OfflineCell.h"
#import "DisplayViewController.h"

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
    [self.searchTextField setTag:TextFieldSearchDB];
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

/**
 *  监听输入框内容变化
 *
 *  @param notifice notifice
 */
- (void)SearchValueChanged:(NSNotification*)notifice {
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
            tmpSql = [NSString stringWithFormat:@"insert into %@(%@,    %@,   %@,   %@,   %@,   %@,   %@,   %@,   %@)  \
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
    NSMutableDictionary *currentDict = [self.dataList objectAtIndex:cellIndex];
    //NSLog(@"indexPath - %d", cellIndex);
    
    OfflineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OfflineCell" owner:self options:nil] lastObject];
    }
    cell.dict = currentDict;
    cell.labelFileName.text = currentDict[OFFLINE_COLUMN_NAME];
    cell.labelCategory.text = currentDict[OFFLINE_COLUMN_CATEGORYNAME];
    cell.labelZipSize.text  = [FileUtils humanFileSize:currentDict[OFFLINE_COLUMN_ZIPSIZE]];
    // 如果文件已经下载，文档原[下载]按钮显示为[演示]
    cell.btnDownloadOrView.tag = [currentDict[OFFLINE_COLUMN_FILEID] intValue];
    [cell.btnDownloadOrView addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
    // 文件是否下载，文件大小等信息操作<OfflineCell#initControls>
    [cell initControls];

    return cell;
}
/**
 *  Cell高度
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 *
 *  @return Cell高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

/**
 *  本viewController中为服务端所有文件列表；
 *  如果已经下载，则可以[演示], 否则需要下载, 所下载文件在FILE_DIRNAME/下
 *
 *  与DisplayViewController传递文件ID通过CONFIG_DIRNAME/CONETNT_CONFIG_FILENAME[@CONTENT_KEY_DISPLAYID]
 *
 *  @param IBAction [演示]按钮点击事件
 *
 *  @return 演示界面
 */
// 如果文件已经下载，文档原[下载]按钮显示为[演示]
- (IBAction) actionDisplaySlide:(id)sender {
    NSString *fileID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fileID Dir:FILE_DIRNAME Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:fileID forKey:CONTENT_KEY_DISPLAYID];
        [configDict writeToFile:configPath atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}

@end