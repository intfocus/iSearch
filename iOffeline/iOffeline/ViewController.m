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

#import "ViewController.h"
#import "HttpUtils.h"
#import "const.h"
#import "DatabaseUtils.h"
#import "PopupView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, nonatomic) DatabaseUtils  *database;
@property (nonatomic, nonatomic) NSMutableArray *dataList;
@property (nonatomic, nonatomic) PopupView      *popupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 初始化配置数据库
    self.database = [DatabaseUtils setUP];

    self.navigation.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(reDownloadFilesList)];
    
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.dataList = [self.database selectFilesWithKeywords:@[]];
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
    self.dataList = [self.database selectFilesWithKeywords:keywords];
    [self.tableView reloadData];
    
    [self showPopupView: [NSString stringWithFormat:@"筛选: %lu行", (unsigned long)self.dataList.count]];
}

- (void)reDownloadFilesList {
    NSError *error;
    NSString *jsonStr = [HttpUtils httpGet:OFFLINE_URL_PATH];
    NSMutableArray *dataList = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];

    if(error==NULL) {
        [self showPopupView: [NSString stringWithFormat:@"刷新: %lu行", (unsigned long)dataList.count]];
        // 插入前先删除
        [self.database executeSQL:[NSString stringWithFormat:@"delete from %@;" , OFFLINE_SEARCH_TABLENAME]];
        
        NSLog(@"Get %@%@ successfully.", BASE_URL, OFFLINE_URL_PATH);
        NSLog(@"DataList count: %lu", (unsigned long)dataList.count);

        NSString *tmpSql = [[NSString alloc] init];
        NSMutableString *insertSql = [[NSMutableString alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for(dict in dataList) {
            tmpSql = [NSString stringWithFormat:@"insert into %@(fid, name, type, desc, tags, page_count, zip_url) \
                      values(%@,  '%@', %@,   '%@', '%@', %@,         '%@');\n",
                      OFFLINE_SEARCH_TABLENAME,
                      dict[@"id"], dict[@"name"], dict[@"type"], dict[@"desc"], dict[@"tags"], dict[@"page_count"], dict[@"zip_url"]];
            [insertSql appendString:tmpSql];
        }
        //NSLog(@"DataList: %@", insertSql);
        [self.database executeSQL:insertSql];
        
        self.dataList = [self.database selectFilesWithKeywords:@[]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    NSMutableDictionary *dict = [self.dataList objectAtIndex:indexPath.row];
    cell.textLabel.text       = [NSString stringWithFormat:@"%@ - %@", dict[@"name"], dict[@"fid"]];
    cell.detailTextLabel.text = [dict[@"desc"] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16.0]];
    
    // remove blue selection
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
//    [cell addGestureRecognizer:gesture];
    
    return cell;
}


@end
