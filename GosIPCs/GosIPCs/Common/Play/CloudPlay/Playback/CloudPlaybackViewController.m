//  CloudPlaybackViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudPlaybackViewController.h"
#import "PlaybackPlayer.h"
#import "CloudPlaybackViewModel.h"
#import "PackageValidTimeApiManager.h"
#import "TokenCheckApiManager.h"
#import "CloudDownloadFileApiManager.h"
#import "VideoSlicesApiManager.h"
#import "TokenCheckApiRespModel.h"
#import "VideoSlicesApiRespModel.h"
#import "CloudServiceVC.h"
#import "NSDate+GosDateExtension.h"
#import "ClipViewController.h"
#import "GosThreadTimer.h"

@interface CloudPlaybackViewController () <GosApiManagerCallBackDelegate, PlaybackPlayerDelegate>
#pragma mark - 视图属性
@property (nonatomic, strong) PlaybackPlayer *pb_player;

#pragma mark - Api属性
/// 获取云存储套餐时长 Api
@property (nonatomic, strong) PackageValidTimeApiManager *packageValidTimeApiManager;
/// 普通视频数据 Api
@property (nonatomic, strong) VideoSlicesApiManager *normalVideosApiManager;
/// 报警视频数据 Api
@property (nonatomic, strong) VideoSlicesApiManager *alarmVideosApiManager;
/// 获取视频队列
@property (nonatomic, strong) dispatch_group_t videosFetchGroup;
/// 获取视频线程
@property (nonatomic, strong) dispatch_queue_t videosFetchQueue;

#pragma mark - 接收属性
/// 外部赋值的设备id
@property (nonatomic, copy) NSString *deviceId;
/// 接收到的 推送时间戳
@property (nonatomic, assign) NSTimeInterval receivedPushTimestamp;
/// 接收到的 切片视频数组模型
@property (nonatomic, copy) NSArray <VideoSlicesApiRespModel *> *receivedNormalModelArray;
/// 接收到的 报警数组模型
@property (nonatomic, copy) NSArray <VideoSlicesApiRespModel *> *receivedAlarmModelArray;

#pragma mark - 标记属性
/// 云服务是否有效，根据是否能获取云存储套餐时长决定
@property (nonatomic, assign, getter=isCloudValid) __block BOOL cloudValid;

#pragma mark - 额外属性
/// 当前操作的日期
@property (nonatomic, copy) NSDate *currentDate;
/// viewModel
@property (nonatomic, strong) CloudPlaybackViewModel *pbViewModel;
/// 获取数据定时器
@property (nonatomic, strong) GosThreadTimer *fetchDataTimer;
/// 是否正在获取Video数据
@property (nonatomic, assign, getter=isFetchingData) __block BOOL fetchingData;
/// 是否能够获取Video数据
@property (nonatomic, assign, getter=isCouldFetchData) __block BOOL couldFetchData;
@end

@implementation CloudPlaybackViewController

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
    // 配置UI
    [self configUI];
    
    // 云存储 获取数据
    [self cloudValidValidation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 创建定时器
    [self createFetchDataTimer];
    // 初始化播放器
    [self.pb_player pb_player_initialPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    GosLog(@"daniel: %s", __PRETTY_FUNCTION__);
    [GosHUD dismiss];
    // 销毁定时器
    [self destoryFetchDataTimer];
    // 销毁播放器
    [self.pb_player pb_player_destoryPlayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    GosLog(@"daniel: %s", __PRETTY_FUNCTION__);
}
- (void)dealloc {
    GosLog(@"---------- CloudPlaybackViewController dealloc -----------");
}


#pragma mark - config method
- (void)configUI {
    
    [self configUIWithDeviceId:self.deviceId];
    
    [self.view addSubview:self.pb_player.pb_playerViewProxy];
    [self.view addSubview:self.pb_player.pb_maskViewProxy];
    [self.view addSubview:self.pb_player.pb_calenderViewProxy];
    [self.view addSubview:self.pb_player.pb_timeAxisViewProxy];
    [self.view addSubview:self.pb_player.pb_basicViewProxy];
    
    self.pb_player.pb_playerViewProxy.frame = CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_W*9.0/16.0);
    self.pb_player.pb_calenderViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.pb_player.pb_playerViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_W*60.0/320.0);
    self.pb_player.pb_timeAxisViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.pb_player.pb_calenderViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_W*80.0/320.0);
    self.pb_player.pb_basicViewProxy.frame = CGRectMake(0, CGRectGetMaxY(self.pb_player.pb_timeAxisViewProxy.frame), GOS_SCREEN_W, GOS_SCREEN_H-CGRectGetMaxY(self.pb_player.pb_timeAxisViewProxy.frame));
    self.pb_player.pb_maskViewProxy.frame = self.pb_player.pb_playerViewProxy.frame;
}

- (void)configUIWithDeviceId:(NSString *)deviceId {
    // 标题 "设备名 - 云存储录像"
    self.title = [NSString stringWithFormat:@"%@ - %@", [self.pbViewModel fetchDeviceNameFromDeviceId:deviceId], DPLocalizedString(@"Mine_CloudPlayback")];
    
}


#pragma mark - PlaybackPlayerDelegate
- (void)pb_player:(PlaybackPlayer *)player calendarView:(UIView *)calendarView displayDetailViewInView:(UIView *__autoreleasing *)view frame:(CGRect *)frame {
    // 日历弹出详细的信息
    *view = self.view;
    *frame = CGRectMake(calendarView.frame.origin.x, calendarView.frame.origin.y, calendarView.frame.size.width, GOS_SCREEN_H-CGRectGetMinY(calendarView.frame));
}

- (void)pb_player:(PlaybackPlayer *)player calendarSelectedDateDidChanged:(NSDate *)date {
    // 日历选择日期改变需要重新获取数据
    self.currentDate = date;
    [GosHUD showProcessHUDForLoading];
    [self loadRequestVideosWithDeviceId:self.deviceId date:date forAppend:NO];
}

- (void)pb_player:(PlaybackPlayer *)player clipDidClick:(UIButton *)sender deviceId:(NSString *)deviceId videos:(NSArray<VideoSlicesApiRespModel *> *)videos startTimestamp:(NSTimeInterval)startTimestamp startTime:(NSUInteger)startTime duration:(NSUInteger)duration {
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        [strongSelf.navigationController pushViewController:[[ClipViewController alloc] initWithDeviceId:deviceId  videos:videos startTimestamp:startTimestamp startTime:startTime duration:duration] animated:YES];
    });
}

#pragma mark - GosApiManagerCallBackDelegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *)manager {
    if (manager == self.packageValidTimeApiManager) {
        id result = [manager fetchDataWithReformer:self.packageValidTimeApiManager];
        if (result) {
            NSArray *eventArray = [self.pbViewModel convertPackageValidTimeApiRespModelToDateArray:result];
            // 更新日历事件
            [self.pb_player pb_player_updateCalenderWithEventsArray:eventArray];
            // 配置推送当前日期
            [self configCurrentDateForPushWithValidDateArray:eventArray];
            // 加载今日视频数据
            [self loadRequestVideosWithDeviceId:self.deviceId date:self.currentDate forAppend:NO];
            
            // 定时获取数据
            [self createFetchDataTimer];
        }
        
        self.cloudValid = result?YES:NO;
        
    } else if (manager == self.normalVideosApiManager) {
        if (!_videosFetchGroup) { [GosHUD dismiss]; }
        
        NSArray *result = [manager fetchDataWithReformer:self.normalVideosApiManager];
        
        // 非同一天不处理
        if (![self.pbViewModel validateVideoSlicesRespModel:[result firstObject] isBelongToDate:self.currentDate]) {
            _receivedNormalModelArray = nil;
            
            if (_videosFetchGroup) { dispatch_group_leave(_videosFetchGroup); }
            else { [self.pb_player pb_player_updateTimeAxisWithDataArray:@[]]; }
            
            return ;
        }
        
        self.receivedNormalModelArray = [self.pbViewModel optimiseVideosModelArray:result];
        
        if (_videosFetchGroup) {
            dispatch_group_leave(_videosFetchGroup);
        } else {
            // 得到时间轴数据更新
            [self.pb_player pb_player_updateTimeAxisWithDataArray:[self.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:self.receivedNormalModelArray]];
        }
        
        
    } else if (manager == self.alarmVideosApiManager) {
        if (!_videosFetchGroup) { [GosHUD dismiss]; }
        
        NSArray *result = [manager fetchDataWithReformer:self.alarmVideosApiManager];
        // 非同一天不处理
        if (![self.pbViewModel validateVideoSlicesRespModel:[result firstObject] isBelongToDate:self.currentDate]) {
            _receivedAlarmModelArray = nil;
            
            if (_videosFetchGroup) { dispatch_group_leave(_videosFetchGroup); }
            else { [self.pb_player pb_player_updateTimeAxisWithDataArray:@[]]; }
            return ;
        }
        self.receivedAlarmModelArray = [self.pbViewModel optimiseVideosModelArray:result];
        
        // 得到时间轴数据更新
        if (_videosFetchGroup) {
            dispatch_group_leave(_videosFetchGroup);
        } else {
            // 得到时间轴数据更新
            [self.pb_player pb_player_updateTimeAxisWithDataArray:[self.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:self.receivedAlarmModelArray]];
        }
    }
}

- (void)managerCallApiDidFailed:(GosApiBaseManager *)manager {
    GosLog(@"%s error: %@", __PRETTY_FUNCTION__, manager.errorMessage);
    [GosHUD dismiss];
    if (manager == self.packageValidTimeApiManager) {
        self.cloudValid = NO;
    } else if (manager == self.normalVideosApiManager) {
        if (_videosFetchGroup) {
            // 完成组
            dispatch_group_leave(_videosFetchGroup);
        } else {
            [GosHUD dismiss];
        }
    } else if (manager == self.alarmVideosApiManager) {
        if (_videosFetchGroup) {
            // 完成组
            dispatch_group_leave(_videosFetchGroup);
        } else {
            [GosHUD dismiss];
        }
    }
}


#pragma mark - cloud method
- (void)cloudValidValidation {
    if (!self.isCloudValid) {
        [GosHUD showProcessHUDForLoading];
        [self loadRequestPackageValidTimeWithDeviceId:self.deviceId];
    }
}

- (void)setCloudValid:(BOOL)cloudValid {
    _cloudValid = cloudValid;
    GosLog(@"-------%d", cloudValid);
    if (!cloudValid) {
        // 未开通云存储处理
        GOS_WEAK_SELF
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:DPLocalizedString(@"Mine_DeviceNotPurchaseCloud") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            GOS_STRONG_SELF
            // cancel 退出当前页
            [strongSelf.navigationController popViewControllerAnimated:YES];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:DPLocalizedString(@"Mine_OrderNow") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            GOS_STRONG_SELF
            // 跳转到
            // 支持云存储则跳转到套餐列表
            CloudServiceVC *packageListVC = [[CloudServiceVC alloc] init];
            packageListVC.dataModel = [strongSelf.pbViewModel fetchDeviceDataModelWithDeviceId:strongSelf.deviceId];
            
            [strongSelf.navigationController pushViewController:packageListVC animated:YES];
        }]];
        [GosHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF
            [strongSelf presentViewController:alert animated:YES completion:nil];
        });
    }
}

#pragma mark - request method
/// 请求套餐时长
- (void)loadRequestPackageValidTimeWithDeviceId:(NSString *)deviceId {
    [self.packageValidTimeApiManager loadDataWithDeviceId:deviceId];
}

/// 获取切片数据
- (void)loadRequestNormalVideosWithDeviceId:(NSString *)deviceId
                                startTime:(NSTimeInterval)startTime
                                  endTime:(NSTimeInterval)endTime {
    [self.normalVideosApiManager loadDataWithDeviceId:deviceId
                                           startTime:startTime
                                             endTime:endTime];
}

/// 获取报警数据
- (void)loadRequestAlarmVideosWithDeviceId:(NSString *)deviceId
                                startTime:(NSTimeInterval)startTime
                                  endTime:(NSTimeInterval)endTime {
    [self.alarmVideosApiManager loadDataWithDeviceId:deviceId
                                           startTime:startTime
                                             endTime:endTime];
}

/// 获取两种视频数据
- (void)loadRequestVideosWithDeviceId:(NSString *)deviceId
                                 date:(NSDate *)date
                            forAppend:(BOOL)forAppend {
    if (self.isFetchingData) return ;
    
    NSTimeInterval start = 0, end = 0;
    // 获取当日的始终时间戳
    [date dayInBeginTimestamp:&start endTimeStamp:&end];
    
    if (!_videosFetchGroup) {
        _videosFetchGroup = dispatch_group_create();
    }
    if (!_videosFetchQueue) {
        _videosFetchQueue = dispatch_queue_create("videoFetchQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    dispatch_group_enter(_videosFetchGroup);
    dispatch_group_enter(_videosFetchGroup);
    // 标记正在获取数据
    _fetchingData = YES;
    
    GOS_WEAK_SELF
    // 获取切片数据
    dispatch_group_async(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        [strongSelf loadRequestNormalVideosWithDeviceId:deviceId
                                              startTime:start
                                                endTime:end];
    });
    
    // 获取报警数据
    dispatch_group_async(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        [strongSelf loadRequestAlarmVideosWithDeviceId:deviceId
                                             startTime:start
                                               endTime:end];
    });
    
    dispatch_group_notify(self.videosFetchGroup, self.videosFetchQueue, ^{
        GOS_STRONG_SELF
        // 结合两种数据并去重
        NSArray *result = [strongSelf.pbViewModel optimiseVideosModelArray:strongSelf.receivedNormalModelArray other:strongSelf.receivedAlarmModelArray];
        // 更新时间轴
//        if (forAppend) {
//            [strongSelf.pb_player pb_player_appendTimeAxisDataArray:[strongSelf.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:result]];
//        } else {
            [strongSelf.pb_player pb_player_updateTimeAxisWithDataArray:[strongSelf.pbViewModel convertVideosModelArrayToTimeAxisDataModelArray:result]];
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
    GosLog(@"创建获取数据定时器");
    _fetchDataTimer = [[GosThreadTimer alloc] initWithInterval:30 forAction:@selector(fetchDataTimerAction) forModl:NSDefaultRunLoopMode withName:@"FetchData" onTarget:self];
    [_fetchDataTimer resume];
}

- (void)fetchDataTimerAction {
    [self loadRequestVideosWithDeviceId:_deviceId date:_currentDate forAppend:YES];
}

- (void)destoryFetchDataTimer {
    if (!_fetchDataTimer) return ;
    GosLog(@"摧毁获取数据定时器");
    [_fetchDataTimer destroy];
    _fetchDataTimer = nil;
    
    if (self.isFetchingData) {
        dispatch_group_leave(_videosFetchGroup);
        dispatch_group_leave(_videosFetchGroup);
    }
}


#pragma mark - private method
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
        [self.pb_player pb_player_updateWithCurrentTimestamp:_receivedPushTimestamp];
    }
}

- (void)configPlayForPush {
    if (_receivedPushTimestamp > 0) {
        // 开始播放
        [self.pb_player pb_player_startPlayWithStartTimestamp:_receivedPushTimestamp];
        // 执行完就重置推送
        _receivedPushTimestamp = 0;
    }
}


#pragma mark - getters and setters
- (PackageValidTimeApiManager *)packageValidTimeApiManager {
    if (!_packageValidTimeApiManager) {
        _packageValidTimeApiManager = [[PackageValidTimeApiManager alloc] init];
        _packageValidTimeApiManager.delegate = self;
    }
    return _packageValidTimeApiManager;
}

- (VideoSlicesApiManager *)normalVideosApiManager {
    if (!_normalVideosApiManager) {
        _normalVideosApiManager = [[VideoSlicesApiManager alloc] initWithApiMethodType:VideoSlicesApiManagerMethodTypeNormal];
        _normalVideosApiManager.delegate = self;
    }
    return _normalVideosApiManager;
}

- (VideoSlicesApiManager *)alarmVideosApiManager {
    if (!_alarmVideosApiManager) {
        _alarmVideosApiManager = [[VideoSlicesApiManager alloc] initWithApiMethodType:VideoSlicesApiManagerMethodTypeAlarm];
        _alarmVideosApiManager.delegate = self;
    }
    return _alarmVideosApiManager;
}

- (CloudPlaybackViewModel *)pbViewModel {
    if (!_pbViewModel) {
        _pbViewModel = [[CloudPlaybackViewModel alloc] init];
    }
    return _pbViewModel;
}

- (NSDate *)currentDate {
    if (!_currentDate) {
        _currentDate = [NSDate date];
    }
    return _currentDate;
}

- (PlaybackPlayer *)pb_player {
    if (!_pb_player) {
        _pb_player = [[PlaybackPlayer alloc] initWithDeviceId:self.deviceId];
        _pb_player.delegate = self;
    }
    return _pb_player;
}

@end

