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
#import "DataHelper.h"
#import "ExtendNslogfunctionality.h"
#import "MainViewController.h"


@interface NotificationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOne;   // 通告列表图
@property (weak, nonatomic) IBOutlet UITableView *tableViewTwo;   // 预告列表图

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;  // 预告显示布局-按月/
@property (weak, nonatomic) IBOutlet UIView *viewCalendar;                // 全部显示时，会隐藏掉日历控件
@property (nonatomic, nonatomic) IBOutlet UIBarButtonItem *barItemTMP;
@property (strong, nonatomic) NSMutableDictionary *dataList; // 通告预告混合数据
@property (strong, nonatomic) NSMutableArray *dataListOne;   // 通告数据列表
@property (strong, nonatomic) NSMutableArray *dataListTwo;   // 预告数据列表
@property (strong, nonatomic) NSMutableArray *dataListTwoDate; // 预告列表日期去重，为日历控件加效果时使用
@property (strong, nonatomic) NSNumber *widthOne;
@property (strong, nonatomic) NSNumber *widthTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@end

@implementation NotificationViewController
@synthesize tableViewOne;
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
    self.widthOne = [[NSNumber alloc] init];
    self.widthTwo = [[NSNumber alloc] init];
    // 服务器取数据
    [self dealWithData];
    // 通知列表
    self.tableViewOne.delegate   = self;
    self.tableViewOne.dataSource = self;
    self.tableViewOne.tag = NotificationTableViewONE;
    self.tableViewTwo.delegate   = self;
    self.tableViewTwo.dataSource = self;
    self.tableViewTwo.tag = NotificationTableViewTWO;

    // 日历控件
    [self configCalendar];
    
    /**
     * 控件事件
     */
    [self.segmentControl addTarget:self action:@selector(actionSegmentControlClick:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *dict1 = @{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    NSDictionary *dict2 = @{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    [self.segmentControl  setTitleTextAttributes:dict1 forState:UIControlStateSelected];
    [self.segmentControl  setTitleTextAttributes:dict2 forState:UIControlStateNormal];
    
    // 导航栏标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 0, 144, 44)];
    titleLabel.text = @"公告通知";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 44)];
    [containerView addSubview:titleLabel];
    containerView.layer.masksToBounds = NO;
    UIBarButtonItem *leftTitleBI = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.leftBarButtonItem = leftTitleBI;
    
    // 临时放置
    self.barItemTMP = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"<<"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(toggleShowLeftBar:)];
    self.barItemTMP.possibleTitles = [NSSet setWithObjects:@"<<", @">>", nil];
//    self.navigationItem.rightBarButtonItem = self.barItemTMP;
}

/**
 *  界面每次出现时都会被触发，动态加载动作放在这里
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // Must be call in viewDidAppear
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.widthTwo = [NSNumber numberWithFloat:self.viewCalendar.bounds.size.width];
    self.widthOne = [NSNumber numberWithFloat:(self.view.bounds.size.width-self.viewCalendar.bounds.size.width)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _calendar = nil;
}

- (IBAction)toggleShowLeftBar:(id)sender {
    MainViewController *mainViewController = [self masterViewController];
    if([self.barItemTMP.title isEqualToString:@"<<"]) {
        [mainViewController hideLeftView];
        [self.barItemTMP setTitle:@">>"];
    } else {
        [mainViewController showLeftView];
        [self.barItemTMP setTitle:@"<<"];
        
    }
    
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
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%@/%ld", monthText, comps.year];
        };
        
    }
    self.calendar.calendarAppearance.weekDayTextColor = [UIColor blackColor];
    self.calendar.calendarAppearance.dayCircleRatio = 0.5;
    self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor colorWithRed:230/255.0 green:0 blue:18/255.0 alpha:1];
    self.calendar.calendarAppearance.dayCircleColorToday = [UIColor colorWithRed:230/255.0 green:0 blue:18/255.0 alpha:1];
    self.calendar.calendarAppearance.dayDotColor = [UIColor colorWithRed:0 green:160/255.0 blue:233/255.0 alpha:1];
    self.calendar.calendarAppearance.dayTextFont = [UIFont systemFontOfSize:16.0];
    self.calendar.calendarAppearance.weekDayTextFont = [UIFont systemFontOfSize:16.0];
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    [self.view bringSubviewToFront:self.viewCalendar];
    [self.view bringSubviewToFront:self.calendarMenuView];
    [self.view bringSubviewToFront:self.calendarContentView];
}

#pragma mark - IBAction
/**
 *  日历控件事件处理-按月/全部
 *
 *  @param sender <#sender description#>
 */
- (IBAction)actionSegmentControlClick:(id)sender {
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0: { // 按月
            self.calendarHeightConstraint.constant = 430;
            [UIView animateWithDuration:.5
                             animations:^{
                                 self.viewCalendar.alpha = 1;
                                 [self.view layoutIfNeeded];
                             }];
        }
            break;
        case 1: { // 全部
            self.dataListTwo = self.dataList[NOTIFICATION_FIELD_HDDATA];
            [self.tableViewTwo reloadData];
            self.calendarHeightConstraint.constant = 0;
            [UIView animateWithDuration:.5
                             animations:^{
                                 self.viewCalendar.alpha = 0;
                                 [self.view layoutIfNeeded];
                             }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Utils

- (void)dealWithData {
    NSMutableDictionary *notificationDatas = [DataHelper notifications];

    // 通告、预告的判断区别在于occur_date字段是否为空, 或NSNULL
    NSInteger toIndex = [DATE_SIMPLE_FORMAT length];
    self.dataList    = notificationDatas;
    self.dataListOne = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据
    self.dataListTwo = notificationDatas[NOTIFICATION_FIELD_HDDATA]; // 预告数据


    // 初始化时需要遍历日历控件所有日期，此操作会减少比较次数
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *occurDate;
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
    NSMutableArray *array = self.dataList[NOTIFICATION_FIELD_HDDATA];
    self.dataListTwo = [NSMutableArray arrayWithArray:[array filteredArrayUsingPredicate:filter]];
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
        //case NotificationTableViewTHREE:
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
    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc] init];
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil] lastObject];
    }
    
    switch ([tableView tag]) {
        case NotificationTableViewONE: {
            currentDict = [self.dataListOne objectAtIndex:cellIndex];
            [cell setCreatedDate:currentDict[NOTIFICATION_FIELD_CREATEDATE]];
        }
            break;
        case NotificationTableViewTWO:
        //case NotificationTableViewTHREE:
        {
            currentDict = [self.dataListTwo objectAtIndex:cellIndex];
            [cell setCreatedDate:currentDict[NOTIFICATION_FIELD_OCCURDATE]];
        }
            break;
        default:
            [currentDict setObject:@"unkown Title" forKey:NOTIFICATION_FIELD_TITLE];
            [currentDict setObject:@"unkown Message" forKey:NOTIFICATION_FIELD_TITLE];
            break;
    }
    [cell.labelTitle setFont:[UIFont systemFontOfSize:NOTIFICATION_TITLE_FONT]];
    [cell.labelMsg setFont:[UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]];
    [cell.labelDate setFont:[UIFont systemFontOfSize:NOTIFICATION_DATE_FONT]];
    cell.labelTitle.text = currentDict[NOTIFICATION_FIELD_TITLE];
    cell.labelMsg.text = currentDict[NOTIFICATION_FIELD_MSG];
    
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
    CGFloat width;
    switch([tableView tag]) {
        case NotificationTableViewONE: {
            currentDict = [self.dataListOne objectAtIndex:indexPath.row];
            width = [self.widthOne floatValue]-5.0f;
        }
            break;
        case NotificationTableViewTWO: {
            currentDict = [self.dataListTwo objectAtIndex:indexPath.row];
            width = [self.widthTwo floatValue]-5.0f;
        }
            break;

        default:
            NSLog(@"Warning Cannot find tableView#tag=%ld", [tableView tag]);
            break;
    }
    NSString *text = currentDict[NOTIFICATION_FIELD_MSG];
    CGSize size = [ViewUtils sizeForTableViewCell:text Width:width FontSize:NOTIFICATION_MSG_FONT];
    return size.height + 50.0f;
}


@end
