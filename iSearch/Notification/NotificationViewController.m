//
//  ViewController.m
//  iNotification
//
//  Created by lijunjie on 15/5/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  说明:
//  公告: 当前日期向前推30天
//  预告: 当前日期向后推30天
//
//  A 从服务器获取公告通知
//      A.1 error => 跳至步骤B
//      A.2 无法连接 => 跳至步骤B
//      A.3 成功 =>
//          如果存在缓存文件，则删除（待确认是否会保证该文件可读取）
//          把服务器响应内容写入本地缓存文件中
//          继续步骤C
//
//  B 从本地缓存读取旧的公告通知
//      B1. 存在缓存则读取
//      B2. 不存在则初始化公告通知数组为空， 继续步骤C
//
//  C 处理公告通知数组实例
//      C1. 分解数据
//          公告数组：元素为NSDirecotry, [发生日期]为空
//          预告数组：元素为NSDirecotry, [发成日期]不为空
//          预告日期数组: 元素为字符串， [发生日期]不空，并格式化为"yyyy/mm/dd", *去重* 。 为日历控件加状态使用
//
//  D 控件
//      D1. 公告列表栏，显示公告数组中信息
//      D2. 预告使用日历控件，有预告的日期在控件中加状态，点击在下方显示预告内容
//      D3. 可以收缩日历控件，腾出更多空间显示预告内容 (TODO)
//
//  E 数组格式
//      json {
//          title: 标题,
//          msg: 内容,
//          created_date: 发布时间
//          occur_date: 发生时间
//          type: 通告类型isearch/ilearn
//      }
//  TODO: 任何服务器响应result不为空时，则popupVIew


#import "NotificationViewController.h"
#import "NotificationCell.h"
#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "extendNslogfunctionality.h"


@interface NotificationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOne;  // 通告列表图
@property (weak, nonatomic) IBOutlet UITableView *tableViewTwo;  // 预告列表图
@property (weak, nonatomic) IBOutlet UITextView *notificationZone;  // 显示预告
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;  // 预告显示布局-按月/
@property (weak, nonatomic) IBOutlet UIView *viewCalendar;                // 全部显示时，会隐藏掉日历控件
@property (strong, nonatomic) NSMutableDictionary *dataList; // 通告预告混合数据
@property (strong, nonatomic) NSMutableArray *dataListOne; // 通告数据列表
@property (strong, nonatomic) NSMutableArray *dataListTwo; // 预告数据列表
@property (strong, nonatomic) NSMutableArray *dataListTwoDate; // 预告列表日期去重，为日历控件加效果时使用
@end

@implementation NotificationViewController
@synthesize tableViewOne;
@synthesize notificationZone;
@synthesize dataListOne;
@synthesize dataListTwo;
@synthesize dataListTwoDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * 实例变量初始化/赋值
     */
    self.dataList        = [[NSMutableDictionary alloc] init];
    self.dataListOne     = [[NSMutableArray alloc] init];
    self.dataListTwo     = [[NSMutableArray alloc] init];
    self.dataListTwoDate = [[NSMutableArray alloc] init];
    // 通知列表
    self.tableViewOne.delegate   = self;
    self.tableViewOne.dataSource = self;
    self.tableViewOne.tag = NotificationTableViewONE;
    self.tableViewTwo.delegate   = self;
    self.tableViewTwo.dataSource = self;
    self.tableViewTwo.tag = NotificationTableViewTWO;
    // 日历控件
    [self configCalendar];

    // 服务器取数据
    [self dealWithData];
    
    /**
     * 控件事件
     */
    [self.segmentControl addTarget:self action:@selector(actionSegmentControlClick:) forControlEvents:UIControlEventValueChanged];
}

/**
 *  界面每次出现时都会被触发，动态加载动作放在这里
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // Must be call in viewDidAppear
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _calendar = nil;
}

- (void)configCalendar {
    self.calendar = [JTCalendar new];
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 1.;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            NSString *monthText = [[NSString alloc] init];
            if([APP_LANG isEqual: @"zh-CN"])
                monthText = [NSString stringWithFormat:@"%ld月", (long)(currentMonthIndex - 1)];
            else
                monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld年%@", comps.year, monthText];
        };
        
    }
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

#pragma mark - IBAction
- (IBAction)actionSegmentControlClick:(id)sender {
//    NSInteger calendarHeight = self.viewCalendar.bounds.size.height;
//    CGRect bounds = self.notificationZone.bounds;
    
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0: { // 按月
            self.viewCalendar.hidden = NO;
//            bounds.size.height = bounds.size.height - calendarHeight;
        }
            break;
        case 1: { // 全部
            self.viewCalendar.hidden = YES;
            self.dataListTwo = self.dataList[NOTIFICATION_FIELD_HDDATA]; // 预告数据
            [self.tableViewTwo reloadData];
//            bounds.size.height = bounds.size.height + calendarHeight;
        }
            break;
        default:
            break;
    }
//    self.notificationZone.frame = bounds;
}

#pragma mark - Utils

- (void)dealWithData {
    // 服务器获取成功则写入cache,否则读取cache
    NSString *cachePath = [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];

    // 从服务器端获取[公告通知], 不判断网络环境，获取不到则取本地cache
    NSString *deptID = @"1";
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    NSString *notifiction_url = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", NOTIFICATION_URL_PATH, NOTIFICATION_PARAM_DEPTID, deptID, NOTIFICATION_PARAM_DATESTR, currentDate];
    NSLog(@"%@", notifiction_url);
    NSString *response = [HttpUtils httpGet: notifiction_url];
    NSError *error;
    // 确保该实例可以被读取
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    notificationDatas = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSErrorPrint(error, @"http get notifications and convert into json.");

    // 情况一: 服务器获取公告通知成功
    if(!error) {
        // 有时文件属性原因，能写入但无法读取
        // 先删除文件再写入
        if([FileUtils checkFileExist:cachePath isDir:false])
            [FileUtils removeFile:cachePath];
        
        // 写入本地作为cache
        [response writeToFile:cachePath atomically:true encoding:NSUTF8StringEncoding error:&error];
        NSErrorPrint(error, @"notifications cache write");
        
        // 情况二: 如果缓存文件存在则读取
    } else if([FileUtils checkFileExist:cachePath isDir:false]) {
        NSErrorPrint(error, @"http get notifications list");
        
        // 读取本地cache
        NSLog(@"%@", cachePath);
        NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath usedEncoding:NULL error:&error];
        NSErrorPrint(error, @"notifications cache read");
        if(!error) {
            // 解析为json数组
            notificationDatas = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            NSErrorPrint(error, @"notifications cache parse into json");
        }
        // 情况三:
    } else {
        NSLog(@"<# HttpGET and cache all failed!>");
    }


    // 通告、预告的判断区别在于occur_date字段是否为空, 或NSNULL
    NSInteger toIndex = [DATE_SIMPLE_FORMAT length];
    self.dataList    = notificationDatas;
    self.dataListOne = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据
    self.dataListTwo = notificationDatas[NOTIFICATION_FIELD_HDDATA]; // 预告数据


    // 初始化时需要遍历日历控件所有日期，此操作会减少比较次数
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *occurDate = [[NSString alloc] init];
    for(dict in self.dataListTwo) {
        // 日历精确至天，如果服务器提示occur_date精确到秒时需要截取
        occurDate = [dict[NOTIFICATION_FIELD_OCCURDATE] substringToIndex:toIndex];
        dict[NOTIFICATION_FIELD_OCCURDATE] = occurDate;
        if(![self.dataListTwoDate containsObject:occurDate])
            [self.dataListTwoDate addObject:occurDate];
    }

    // 公告通知按created_date升序
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_CREATEDATE ascending:YES];
    [self.dataListOne sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    // 预告通知按occur_date升序
    descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_OCCURDATE ascending:YES];
    [self.dataListTwo sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
}
#pragma mark - JTCalendarDataSource
/**
 *  JTCanlendar回调函数；预告通知,自定义状态；有预告的日期在日历控件上加标注。
 *  说明: 处理今日以后的日期，其他不做处理
 *
 *  @param calendar 日历控件实例
 *  @param date     有日程安排的日期
 *
 *  @return 有日程安排则返回true
 */
- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    NSComparisonResult compareResult = [currentDate compare:date];
    // 日历日期只有不比当前日期小时才有可能出现预告
    // 此操作会减少比较次数
    if(compareResult != NSOrderedAscending)
        return false;
    
    NSString *dateStr = [DateUtils dateToStr:date Format:DATE_SIMPLE_FORMAT];
    return [self.dataListTwoDate containsObject:dateStr];
}

/**
 *  JTCanlendar回调函数；点击日历表中某日期时，响应处理
 *  Question:
 *      [NSPredicate predicateWithFormat:@"(OccurTime == %@)", dateStr];
 *      => OccurTime == "2015/06/18"
 *      [NSPredicate predicateWithFormat:@"(%@ == %@)", @"OccurTime", dateStr];
 *      => "OccurTime" == "2015/06/18"
 *   Solution:
 *      String format and not use predicateWithFormat!
 *
 *  @param calendar 日历控件实例
 *  @param date     选择的日期
 */
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    NSString *dateStr = [DateUtils dateToStr:date Format:DATE_SIMPLE_FORMAT];
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", NOTIFICATION_FIELD_OCCURDATE, dateStr];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];

    self.dataListTwo = [NSMutableArray arrayWithArray:[self.dataListTwo filteredArrayUsingPredicate:filter]];
    [self.tableViewTwo reloadData];
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 300;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch([tableView tag]) {
        case NotificationTableViewONE:
            count = [self.dataListOne count];
            break;
        case NotificationTableViewTWO:
            count = [self.dataListTwo count];
            break;
        default:
            NSLog(@"Warning Cannot find tableView#tag=%ld", [tableView tag]);
            break;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NSInteger cellIndex = indexPath.row;
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil] lastObject];
    }
    
    switch ([tableView tag]) {
        case NotificationTableViewONE: {
            cell.selectedBackgroundView          = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            
            NSMutableDictionary *currentDict = [self.dataListOne objectAtIndex:cellIndex];
            cell.cellTitle.text = currentDict[NOTIFICATION_FIELD_TITLE];
            
            [cell.cellTitle setFont:[UIFont systemFontOfSize:NOTIFICATION_TITLE_FONT]];
            [cell.cellMsg setFont:[UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]];
            cell.cellMsg.text = currentDict[NOTIFICATION_FIELD_MSG];
            [cell.cellCreatedDate setFont:[UIFont systemFontOfSize:NOTIFICATION_DATE_FONT]];
            [cell setCreatedDate:currentDict[NOTIFICATION_FIELD_CREATEDATE]];
        }
            break;
        case NotificationTableViewTWO: {
            cell.selectedBackgroundView          = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            
            NSMutableDictionary *currentDict = [self.dataListTwo objectAtIndex:cellIndex];
            cell.cellTitle.text = currentDict[NOTIFICATION_FIELD_TITLE];
            
            [cell.cellTitle setFont:[UIFont systemFontOfSize:NOTIFICATION_TITLE_FONT]];
            [cell.cellMsg setFont:[UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]];
            cell.cellMsg.text = currentDict[NOTIFICATION_FIELD_MSG];
            [cell.cellCreatedDate setFont:[UIFont systemFontOfSize:NOTIFICATION_DATE_FONT]];
            [cell setCreatedDate:currentDict[NOTIFICATION_FIELD_CREATEDATE]];
        }
        default:
            cell.cellMsg.text = @"Unknow cell.";
            break;
    }
    
    return cell;
}

/**
 *  动态设置NotificationCell的高度
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 *
 *  @return 当前NotificationCell的高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc] init];
    switch([tableView tag]) {
        case NotificationTableViewONE:
            currentDict = [self.dataListOne objectAtIndex:indexPath.row];
            break;
        case NotificationTableViewTWO:
            currentDict = [self.dataListTwo objectAtIndex:indexPath.row];
            break;
        default:
            NSLog(@"Warning Cannot find tableView#tag=%ld", [tableView tag]);
            break;
    }
    NSString *text = currentDict[NOTIFICATION_FIELD_MSG];
    CGSize size = [ViewUtils sizeForTableViewCell:text Width:240 FontSize:NOTIFICATION_MSG_FONT];
    return size.height + 50.0f;
}


@end
