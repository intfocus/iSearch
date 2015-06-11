//
//  ViewController.m
//  iNotification
//
//  Created by lijunjie on 15/5/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
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
//      C1. 遍历公告通知数组分成:
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

#import "ViewController.h"
#import "common.h"
#import "NotificationCell.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *notificationView;  // 通告列表图
@property (weak, nonatomic) IBOutlet UITextView *notificationZone;  // 显示预告
@property (strong, nonatomic) NSMutableArray *notifications;        // 通告列表
@property (strong, nonatomic) NSMutableArray *notificationsAdvance; // 预告列表
@property (strong, nonatomic) NSMutableArray *notificationsAdvanceDate;    // 预告列表日期去重，为日历控件加效果时使用
@end

@implementation ViewController
@synthesize notificationView;
@synthesize notificationZone;
@synthesize notifications;
@synthesize notificationsAdvance;
@synthesize notificationsAdvanceDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
            
            return [NSString stringWithFormat:@"%@/%ld", monthText, comps.year];
        };

    }
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
    self.notifications = [[NSMutableArray alloc] init];
    self.notificationsAdvance = [[NSMutableArray alloc] init];
    
    //[FileUtils printDir:@""];
    // 服务器获取成功则写入cache,否则读取cache
    NSString *cachePath = [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];
    
    // 从服务器端获取[公告通知], 不判断网络环境，获取不到则取本地cache
    NSString *response = [HttpUtils httpGet: NOTIFICATION_URL_PATH];
    NSError *error;
    // 确保该实例可以被读取
    NSMutableArray *notificationDatas = [[NSMutableArray alloc] init];
    notificationDatas = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    
    // 情况一: 服务器获取公告通知成功
    if(!error) {
        // 有时文件属性原因，能写入但无法读取
        // 先删除文件再写入
        if([FileUtils checkFileExist:cachePath isDir:false])
            [FileUtils removeFile:cachePath];
        
        // 写入本地作为cache
        [response writeToFile:cachePath atomically:true encoding:NSUTF8StringEncoding error:&error];
        [self logger:error Info:@"notifications cache write"];
        
    // 情况二: 如果缓存文件存在则读取
    } else if([FileUtils checkFileExist:cachePath isDir:false]) {
        [self logger:error Info:@"http get notifications list"];
        
        // 读取本地cache
        NSLog(@"%@", cachePath);
        NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath usedEncoding:NULL error:&error];
        if(error) {
            [self logger:error Info:@"notifications cache read"];
        } else {
            // 解析为json数组
            notificationDatas = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
            [self logger:error Info:@"notifications cache parse into json"];
        }
    // 情况三:
    } else {
        NSLog(@"<# HttpGET and cache all failed!>");
    }
    
    
    // 通告、预告的判断区别在于occur_date字段是否为空, 或NSNULL
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.notificationsAdvanceDate = [[NSMutableArray alloc] init];
    NSInteger toIndex = [NOTIFICATION_DATE_FORMAT length];
    NSString *occurDate = [[NSString alloc] init];
    for(dict in notificationDatas) {
        if((NSNull *)dict[NOTIFICATION_OCCUR_DATE] == [NSNull null])
            [self.notifications addObject:dict];
        else {
            // 日历精确至天，如果服务器提示occur_date精确到秒时需要截取
            occurDate = [dict[NOTIFICATION_OCCUR_DATE] substringToIndex:toIndex];
            dict[NOTIFICATION_OCCUR_DATE] = occurDate;
            [self.notificationsAdvance  addObject:dict];
            // 初始化时需要遍历日历控件所有日期，此操作会减少比较次数
            if(![self.notificationsAdvanceDate containsObject:occurDate])
               [self.notificationsAdvanceDate addObject:occurDate];
        }
    }
    // 公告通知按created_date升序
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"created_date" ascending:YES];
    [self.notifications sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    // 预告通知按occur_date升序
    descriptor = [[NSSortDescriptor alloc] initWithKey:@"occur_date" ascending:YES];
    [self.notificationsAdvance sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"%@", self.notifications);
    
    // 初始化通知列表视图
    self.notificationView.delegate   = self;
    self.notificationView.dataSource = self;
    [self.notificationView reloadData];
}

/**
 *  封装自定义内容格式的logger
 *
 *  @param error NSError实例
 *  @param info  调试使用的显示信息
 */
- (void) logger:(NSError *)error Info:(NSString *)info {
    NSString *logState = (error == NULL ? @"successfully." : [NSString stringWithFormat:@"failed: %@", [error localizedDescription]]);
    NSLog(@"<# %@ %@ >", info, logState);
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
}

#pragma mark - Buttons callback
- (IBAction)didGoTodayTouch {
    [self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch {
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
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
    
    NSString *dateStr = [DateUtils dateToStr:date Format:NOTIFICATION_DATE_FORMAT];
    return [self.notificationsAdvanceDate containsObject:dateStr];
}

/**
 *  JTCanlendar回调函数；点击日历表中某日期时，响应处理
 *
 *  @param calendar 日历控件实例
 *  @param date     选择的日期
 */
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    
    NSString *selectDate = [DateUtils dateToStr:date Format:NOTIFICATION_DATE_FORMAT];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(occur_date == %@)", selectDate];
    NSLog(@"filter: %@", filter);
    
    NSArray *notificationAdvance = [self.notificationsAdvance filteredArrayUsingPredicate:filter];
    NSLog(@"filter: %@", notificationAdvance);
    NSString *notificationText = [[NSString alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for(dict in notificationAdvance) {
        notificationText = [notificationText stringByAppendingString:dict[@"title"]];
        notificationText = [notificationText stringByAppendingString:@"\n"];
        notificationText = [notificationText stringByAppendingString:dict[@"msg"]];
        notificationText = [notificationText stringByAppendingString:@"\n"];
    }
    NSLog(@"%@", notificationText);
    self.notificationZone.text = notificationText;
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
    return [self.notifications count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NSInteger cellIndex = indexPath.row;
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil] lastObject];
    }
    
    cell.selectedBackgroundView          = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *dict = [self.notifications objectAtIndex:cellIndex];
    cell.cellTitle.text = dict[@"title"];
    
    [cell.cellTitle setFont:[UIFont systemFontOfSize:NOTIFICATION_TITLE_FONT]];
    [cell.cellMsg setFont:[UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]];
    [cell.cellMsg setNumberOfLines: 2];
    [cell.cellCreatedDate setFont:[UIFont systemFontOfSize:NOTIFICATION_DATE_FONT]];
    [cell setIntroductionText:dict[@"msg"]];
    [cell setCreatedDate:dict[@"created_date"]];
    
    //UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
    //[cell addGestureRecognizer:gesture];
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
    NotificationCell *cell = (NotificationCell*)[self tableView:self.notificationView cellForRowAtIndexPath:indexPath];

    return cell.frame.size.height;
}


@end
