//  TFCardPlayViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/19.
//  Copyright © 2019年 goscam. All rights reserved.

#import "TFCardPlayViewController.h"
#import "iOSConfigSDK.h"
#import "NSDate+GosDateExtension.h"
#import "CloudPlaybackViewModel.h"
#import "TFCardPlayer.h"
#import "ClipViewController.h"
#import "GosThreadTimer.h"

@interface TFCardPlayViewController () <iOSConfigSDKDMDelegate, TFCardPlayerDelegate>
#pragma mark - 视图属性
@property (nonatomic, strong) TFCardPlayer *tf_player;

#pragma mark - sdk
/// 列表
@property (nonatomic, strong) iOSConfigSDK *configSDK;
/// 获取视频队列
@property (nonatomic, strong) dispatch_group_t videosFetchGroup;
/// 获取视频线程
@property (nonatomic, strong) dispatch_queue_t videosFetchQueue;

#pragma mark - 接收属性
/// 设备id
@property (nonatomic, copy) NSString *deviceId;
/// 接收到的 推送时间戳
@property (nonatomic, assign) NSTimeInterval receivedPushTimestamp;
/// 接收到的 普通视频数组模型
@property (nonatomic, copy) NSArray <SDAlarmDataModel *> *receivedNormalModelArray;
/// 接收到的 报警视频数组模型
@property (nonatomic, copy) NSArray <SDAlarmDataModel *> *receivedAlarmModelArray;


#pragma mark - 额外属性
/// 当前操作的日期
@property (nonatomic, copy) NSDate *currentDate;
/// viewModel
@property (nonatomic, strong) CloudPlaybackViewModel *pbViewModel;
/// 获取Video数据定时器
@property (nonatomic, strong) GosThreadTimer *fetchDataTimer;
/// 是否正在获取Video数据
@property (nonatomic, assign, getter=isFetchingData) __block BOOL fetchingData;
/// 是否能够获取Video数据
@property (nonatomic, assign, getter=isCouldFetchData) __block BOOL couldFetchData;
@end

@implementation TFCardPlayViewController
#pragma mark - initialization
- (instancetype)initWithDeviceId:(NSString *)deviceId {
    return [self initWithDeviceId:deviceId targetTimestamp:0];
}

- (instancetype)initWithDeviceId:(NSString *)deviceId
                 targetTimestamp:(NSTimeInterval)targetTimestamp {
    if (self = [super init]) {
        _deviceId = [deviceId copy];
        _receivedPushTimestamp = targetTimestamp;
    }
    return self;
}


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 绘制UI
    [self configUI];
    
    // 加载当月数据
    [self loadRequestMonthRecordList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 代理
    self.configSDK.dmDelegate = self;
    
    // 初始化播放器
    [self.tf_player tf_player_initialPlayer];
    // 创建定时器
    [self createFetchDataTimer];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [GosHUD dismiss];
    // 清除SDK
    [self cleanSDK];
    // 销毁播放器
    [self.tf_player tf_player_destoryPlayer];
    // 销毁定时器
    [self destoryFetchDataTimer];
}

- (void)dealloc {
    GosLog(@"---------- TFCardPlayViewController dealloc -----------");
}

#pragma mark - config method
- (void)configUI {
    
    [self configUIWithDeviceId:self.deviceId];
    
    [self.view addSubview:self.tf_player.tf_playerViewProxy];
    [self.view addSubview:self.tf_player.tf_maskViewProxy];
    [self.view addSubview:self.tf_player.tf_calenderViewProxy];
    [self.view addSubview:self.tf_player.tf_timeAxisViewProxy];
    [self.view addSubview:self.tf_player.tf_basicViewProxy];
    
    self.tf_player.tf_playerViewProxy.frame = CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_W*GOS_VIDEO_H_W_SCALE);
    self.tf_player.tf_calenderViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.tf_player.tf_playerViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_W*60.0/320.0);
    self.tf_player.tf_timeAxisViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.tf_player.tf_calenderViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_W*80.0/320.0);
    self.tf_player.tf_basicViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.tf_player.tf_timeAxisViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_H-CGRectGetMaxY(self.tf_player.tf_timeAxisViewProxy.frame));
    self.tf_player.tf_maskViewProxy.frame = self.tf_player.tf_playerViewProxy.frame;
}

- (void)configUIWithDeviceId:(NSString *)deviceId {
    // 标题 "设备名 - TF卡录像"
    self.title = [NSString stringWithFormat:@"%@ - %@", [self.pbViewModel fetchDeviceNameFromDeviceId:deviceId], DPLocalizedString(@"TFCRP_Title")];
    
}


#pragma mark - PlaybackPlayerDelegate
- (void)tf_player:(TFCardPlayer *)player calendarView:(UIView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame {
    // 日历弹出详细的信息
    *view = self.view;
    *frame = CGRectMake(calendarView.frame.origin.x, calendarView.frame.origin.y, calendarView.frame.size.width, GOS_SCREEN_H-CGRectGetMinY(calendarView.frame));
}

- (void)tf_player:(TFCardPlayer *)player calendarSelectedDateDidChanged:(NSDate *)date {
    // 日历选择日期改变需要重新获取数据
    self.currentDate = date;
    [GosHUD showProcessHUDForLoading];
    [self loadRequestVideosWithDeviceId:self.deviceId date:date forAppend:NO];
}

- (void)tf_player:(TFCardPlayer *)player clipDidClick:(UIButton *)sender deviceId:(NSString *)deviceId startTimestamp:(NSTimeInterval)startTimestamp duration:(NSUInteger)duration {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        // 跳转至剪切界面
        // TF卡流播限制最多30秒
        [strongSelf.navigationController pushViewController:[[ClipViewController alloc] initWithDeviceId:deviceId startTimestamp:startTimestamp duration:duration>30?30:duration] animated:YES];
    });
}


#pragma mark - iOSConfigSDKDMDelegate
- (void)reqMoth:(BOOL)isSuccess recordList:(NSArray<RecMonthDataModel *> *)dateList errorCode:(ReqRecListErrType)eType {
//    GosLog(@"daniel: 请求某月数据 %@ type:%zd", isSuccess?@"成功":@"失败", eType);
    switch (eType) {
        case ReqRecListErr_noFiles:
        case ReqRecListErr_no: {
            // 成功
            NSArray *eventArray = [self.pbViewModel convertRecMonthDataModelArrayToDateArray:dateList];
            // 更新日历事件
            [self.tf_player tf_player_updateCalenderWithEventsArray:eventArray];
            // 配置推送当前日期
            [self configCurrentDateForPushWithValidDateArray:eventArray];
            // 加载当前日期的视频数据
            [self loadRequestVideosWithDeviceId:_deviceId date:self.currentDate forAppend:NO];
            // 定时获取数据
            [self createFetchDataTimer];
            
            break;
        }
        case ReqRecListErr_noSDCard: {
            // 无卡
            [GosHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:DPLocalizedString(@"TFCR_NoTFCardTitle") preferredStyle:UIAlertControllerStyleAlert];
            GOS_WEAK_SELF
            [alert addAction:[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                GOS_STRONG_SELF
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                GOS_STRONG_SELF
                [strongSelf presentViewController:alert animated:YES completion:nil];
            });
            break;
        }
        default:
            // 失败
            [GosHUD showProcessHUDErrorWithStatus:@"GosComm_getData_fail"];
            break;
    }
}

- (void)reqSDRecList:(BOOL)isSuccess recordList:(NSArray<SDAlarmDataModel *> *)list forType:(SDRecListType)rType {
    GosLog(@"daniel: 请求某天数据：%@ - rType: %zd %@", isSuccess?@"成功":@"失败", rType, list);
    if (!isSuccess) {
        // 获取失败
        if (_videosFetchGroup) {
            dispatch_group_leave(_videosFetchGroup);
        }
        return ;
    }
    switch (rType) {
        case SDRecList_normal: {
            self.receivedNormalModelArray = [self.pbViewModel optimiseVideosModelArray:list];
            
            if (_videosFetchGroup) {
                dispatch_group_leave(_videosFetchGroup);
            } else {
                // 得到时间轴数据更新
                [self.tf_player tf_player_updateTimeAxisWithDataArray:[self.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:self.receivedNormalModelArray]];
            }
            break;
        }
        case SDRecList_alarm: {
            self.receivedAlarmModelArray = [self.pbViewModel optimiseVideosModelArray:list];
            
            if (_videosFetchGroup) {
                dispatch_group_leave(_videosFetchGroup);
            } else {
                // 得到时间轴数据更新
                [self.tf_player tf_player_updateTimeAxisWithDataArray:[self.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:self.receivedAlarmModelArray]];
            }
            break;
        }
        case SDRecList_unknow:
            // 未知类型，我能怎么办
            break;
        default:
            break;
    }
}

#pragma mark - request method
/// 获取当月录制数据列表
- (void)loadRequestMonthRecordList {
    [GosHUD showProcessHUDForLoading];
    [self loadRequestMonthRecordListWithDeviceId:_deviceId];
}

/// 获取当月录制数据列表
- (void)loadRequestMonthRecordListWithDeviceId:(NSString *)deviceId {
    [self.configSDK reqMothRecListWithDevId:deviceId];
}

/// 获取切片数据
- (void)loadRequestVideoNormalWithDeviceId:(NSString *)deviceId
                                 startTime:(NSTimeInterval)startTime
                                   endTime:(NSTimeInterval)endTime {
    [self.configSDK reqSDRecListWithdDevId:deviceId
                                 startTime:[@(startTime) stringValue]
                                   endTime:[@(endTime) stringValue]
                                   forType:SDRecList_normal];
}

/// 获取报警数据
- (void)loadRequestVideoAlarmWithDeviceId:(NSString *)deviceId
                                startTime:(NSTimeInterval)startTime
                                  endTime:(NSTimeInterval)endTime {
    [self.configSDK reqSDRecListWithdDevId:deviceId
                                 startTime:[@(startTime) stringValue]
                                   endTime:[@(endTime) stringValue]
                                   forType:SDRecList_alarm];
}

/// 获取两种视频数据
- (void)loadRequestVideosWithDeviceId:(NSString *)deviceId
                                 date:(NSDate *)date
                            forAppend:(BOOL)forAppend {
    if (self.isFetchingData) return ;
    // 标记正在获取数据
    _fetchingData = YES;
    
    NSTimeInterval start = 0, end = 0;
    // 获取当日的始终时间戳
    [date dayInBeginTimestamp:&start endTimeStamp:&end];
    
    if (!_videosFetchGroup) {
        _videosFetchGroup = dispatch_group_create();
    }
    if (!_videosFetchQueue) {
        _videosFetchQueue = dispatch_queue_create("videoFetchQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    
    dispatch_group_enter(_videosFetchGroup);
    GOS_WEAK_SELF
    // 获取切片数据
    dispatch_group_async(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        [strongSelf loadRequestVideoNormalWithDeviceId:deviceId
                                             startTime:start
                                               endTime:end];
    });
    // 等待第一个事件完成
    dispatch_group_wait(self.videosFetchGroup, DISPATCH_TIME_FOREVER);
    dispatch_group_enter(_videosFetchGroup);
    // 获取报警数据
    dispatch_group_async(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        [strongSelf loadRequestVideoAlarmWithDeviceId:deviceId
                                            startTime:start
                                              endTime:end];
    });
    
    dispatch_group_notify(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        // 结合两种数据并去重
        NSArray *result = [strongSelf.pbViewModel optimiseVideosModelArray:strongSelf.receivedNormalModelArray other:strongSelf.receivedAlarmModelArray];
        // 更新时间轴
//        if (forAppend) {
//            [strongSelf.tf_player tf_player_appendTimeAxisDataArray:[strongSelf.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:result]];
//        } else {
            [strongSelf.tf_player tf_player_updateTimeAxisWithDataArray:[strongSelf.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:result]];
//        }
        // 标记获取数据完毕
        strongSelf.fetchingData = NO;
        
        [GosHUD dismiss];
        
        // 推送播放
        [self configPlayForPush];
        
    });
}


#pragma mark - timer method
- (void)createFetchDataTimer {
    // 没有金刚钻别揽瓷器活
    if (self.isCouldFetchData) return ;
    // 活着就被搞事情
    if (_fetchDataTimer) return ;
    // 创建定时器
    _fetchDataTimer = [[GosThreadTimer alloc] initWithInterval:30 forAction:@selector(fetchDataTimerAction) forModl:NSDefaultRunLoopMode withName:@"FetchVideoData" onTarget:self];
    [_fetchDataTimer resume];
}

- (void)fetchDataTimerAction {
    [self loadRequestVideosWithDeviceId:_deviceId date:_currentDate forAppend:YES];
}

- (void)destoryFetchDataTimer {
    // 挂逼了就别再搞我
    if (!_fetchDataTimer) return ;
    // 干掉定时器
    [_fetchDataTimer destroy];
    _fetchDataTimer = nil;
    
    // 解决离开的点，刚好执行定时器内容，这是group已经enter
    if (self.isFetchingData) {
        dispatch_group_leave(_videosFetchGroup);
    }
}

#pragma mark - private method
- (void)cleanSDK {
    if (!_configSDK) return ;
    
    _configSDK.dmDelegate = nil;
    _configSDK = nil;
}

- (void)configCurrentDateForPushWithValidDateArray:(NSArray *)dateArray {
    if (_receivedPushTimestamp > 0) {
        // 查找日期数据知否存在推送时间戳
        NSDate *pushDate = [NSDate dateWithTimeIntervalSince1970:_receivedPushTimestamp];
        BOOL existSameDay = NO;
        for (NSDate *date in dateArray) {
            if ([date isTheSameDayAsDate:pushDate]) {
                existSameDay = YES;
                break;
            }
        }
        
        // 如果不存在同一天、就重置
        if (!existSameDay) {
            _receivedPushTimestamp = 0;
            return ;
        }
        
        // 存在同一天就将当前处理时间更新为推送时间
        self.currentDate = [NSDate dateWithTimeIntervalSince1970:_receivedPushTimestamp];
        // 更新界面
        [self.tf_player tf_player_updateWithCurrentTimestamp:_receivedPushTimestamp];
    }
}

- (void)configPlayForPush {
    if (_receivedPushTimestamp > 0) {
        // 开始播放
        [self.tf_player tf_player_startPlayWithStartTimestamp:_receivedPushTimestamp];
        // 执行完就重置推送
        _receivedPushTimestamp = 0;
    }
}


#pragma mark - getters and setters
- (iOSConfigSDK *)configSDK {
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
    }
    return _configSDK;
}

- (CloudPlaybackViewModel *)pbViewModel {
    if (!_pbViewModel) {
        _pbViewModel = [[CloudPlaybackViewModel alloc] init];
    }
    return _pbViewModel;
}

- (TFCardPlayer *)tf_player {
    if (!_tf_player) {
        _tf_player = [[TFCardPlayer alloc] initWithDeviceId:_deviceId];
        _tf_player.delegate = self;
    }
    return _tf_player;
}

- (NSDate *)currentDate {
    if (!_currentDate) {
        _currentDate = [NSDate date];
    }
    return _currentDate;
}

@end
