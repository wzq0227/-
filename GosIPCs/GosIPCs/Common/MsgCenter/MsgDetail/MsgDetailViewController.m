//
//  MsgDetailViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MsgDetailViewController.h"
#import "UIView+GosGradient.h"
#import "PushMsgManager.h"
#import "PushImageManager.h"
#import "IPCPlayViewController.h"
#import "GosDevManager.h"
#import "NSObject+CurrentVC.h"
#import "DevAbilityManager.h"
#import "GosTransition.h"
#import "iOSConfigSDK.h"
#import "CloudPlaybackViewController.h"
#import "NSString+GosFormatDate.h"

#define CHANGE_ANIMAT_DURATION 0.5f     // 切换消息动画时长（单位：秒）
#define OP_PUSH_LIST_TIMEOUT    10      // 操作消息列表超时时间（单位：秒）


@interface MsgDetailViewController ()<iOSConfigSDKIOTDelegate>
{
    BOOL m_isConfigGradient;
    BOOL m_hasAddImgDownloadFinishNotify;   // 是否已添加通知
    BOOL m_isIotSensorMsg;  // 是否是 IOT-传感器 推送消息
    BOOL m_hasCloseIOT;     //  是否已经关闭IOT警报（目前只有声光报警器）
}
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarViewHeight;
@property (weak, nonatomic) IBOutlet UIView *msgDetailView;

@property (weak, nonatomic) IBOutlet UIImageView *pushImgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *pushMsgTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushMsgTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushDevNameLabel;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *closeBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *openBtn;
@property (weak, nonatomic) IBOutlet UIImageView *iOTIconImg;   //  右上角IOT的图标，目前为声光报警器
@property (weak, nonatomic) IBOutlet EnlargeClickButton *iOTCloseBtn;     //  右上角的IOT关闭图标，目前为关闭声光报警器声音

/** 当前显示的推送消息的设备 ID */
@property (nonatomic, readwrite, copy) NSString *curDevId;
/** 推送消息图片 */
@property (nonatomic, readwrite, strong) UIImage *pushImg;
/** 推送消息图片文件名 */
@property (nonatomic, readwrite, copy) NSString *pushImgName;
/** 是否已经左右滑动切换 */
@property (nonatomic, readwrite, assign) BOOL hasSwiped;
/** 当前消息下标 */
@property (nonatomic, readwrite, assign) NSUInteger curMsgIndex;
/** 左滑手势 */
@property (nonatomic, readwrite, strong) UISwipeGestureRecognizer *swipToLeft;
/** 右滑手势 */
@property (nonatomic, readwrite, strong) UISwipeGestureRecognizer *swipToRight;
/** 缓存推送消息列表（用于左右滑动切换消息） */
@property (nonatomic, readwrite, strong) NSMutableArray<PushMessage*>*pushMsgList;
/** 消息列表访问 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *pushMsgListLock;
/** 下条消息切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *nextMsgAnimation;
/** 上条消息切换动画 */
@property (nonatomic, readwrite, strong) GosTransition *preMsgAnimation;

/// IOT 默认图片
@property (nonatomic, strong) UIImage * iOTCoverDefaultImg;
/// IOT 门磁图片
@property (nonatomic, strong) UIImage * iOTCoverMagneticImg;
/// IOT 红外感应图片
@property (nonatomic, strong) UIImage * iOTCoverInfraredImg;
/// IOT 声光报警器图片
@property (nonatomic, strong) UIImage * iOTCoverSosAlarmImg;
/// IOT SOS图片
@property (nonatomic, strong) UIImage * iOTCoverSosImg;

/// SDK
@property (nonatomic, strong) iOSConfigSDK * iosConfigSDK;
@end

@implementation MsgDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    [self addClickMsgNotify];
    [self addSaveSuccessMsgNotify];
    [self configUI];
    [self loadPushMsgList];
    [self handlePushMsg];
    [self loadPushImage];
    [self.msgDetailView addGestureRecognizer:self.swipToRight];
    [self.msgDetailView addGestureRecognizer:self.swipToLeft];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetParam];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    if (NO == m_isConfigGradient)
    {
        m_isConfigGradient = YES;
        
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf.statusBarView gradientStartColor:GOSCOM_THEME_START_COLOR
                                                endColor:GOSCOM_THEME_END_COLOR
                                            cornerRadius:0
                                               direction:GosGradientLeftToRight];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- MsgDetailViewController dealloc ----------");
}
#pragma mark -- 查询IOT开关状态
-(void) checkIOTStatus{
    [self.iosConfigSDK checkStrobeSirenStatusOfDevice:self.pushMsg.deviceId];
}

#pragma mark - 查询声光报警器-开关状态结果回调
- (void)checkStrobeSiren:(BOOL)isSuccess
                  status:(BOOL)isOpen
                deviceId:(NSString *)devId
               errorCode:(int)eCode{
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iOTCloseBtn.enabled = isOpen;
        });
    }
}

- (void)initParam
{
    m_isConfigGradient                = NO;
    m_hasAddImgDownloadFinishNotify   = NO;
    m_isIotSensorMsg                  = [self isIotSensorMsg:self.pushMsg];
    self.curDevId                     = self.pushMsg.deviceId;
    self.hasSwiped                    = NO;
    self.curMsgIndex                  = 0;
//    self.pushMsgListLock              = [[GosReadWriteLock alloc] init];
    self.pushMsgListLock.readTimeout  = OP_PUSH_LIST_TIMEOUT;
    self.pushMsgListLock.writeTimeout = OP_PUSH_LIST_TIMEOUT;
    self.nextMsgAnimation             = [[GosTransition alloc] initWithType:GosTranAnimat_pageCurl
                                                                    subType:kCATransitionFromRight
                                                                   duration:CHANGE_ANIMAT_DURATION];
    self.preMsgAnimation              = [[GosTransition alloc] initWithType:GosTranAnimat_pageUnCurl
                                                                    subType:kCATransitionFromRight
                                                                   duration:CHANGE_ANIMAT_DURATION];
}

- (void)resetParam
{
    m_isIotSensorMsg = [self isIotSensorMsg:self.pushMsg];
    self.pushImgName = [self.pushMsg.pushUrl lastPathComponent];
    if (YES == m_isIotSensorMsg) {
//        [self checkIOTStatus];  //  查询IOT 开关状态
//        [self testShow];
    }
    [self resetUI];
}

- (void)configUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
        self.statusBarViewHeight.constant    = statusRect.size.height;
        self.pushImgView.layer.cornerRadius  = 6.0f;
        self.pushImgView.layer.masksToBounds = YES;
        
    });
}

- (void)resetUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 默认右上角两个图标隐藏
        self.iOTIconImg.hidden  = !m_isIotSensorMsg;
        self.iOTCloseBtn.hidden = !m_isIotSensorMsg;
        // NOTE: 当声光报警器声音按钮显示，那么就可点击，当点击后就不可再点击，理论上点进来就查询当前报警是否为关闭，如果是关闭，就直接显示为灰色，但当前查询IOT是否关闭有点问题
        self.iOTCloseBtn.enabled = m_isIotSensorMsg;
    });
}

#pragma mark -- 是否是 IOT-传感器 推送消息
- (BOOL)isIotSensorMsg:(PushMessage *)pushMsg
{
    if (!pushMsg)
    {
        return NO;
    }
    BOOL ret = NO;
    if (PushMsg_iotSensorLowBattery   == pushMsg.pmsgType
        || PushMsg_iotSensorDoorOpen  == pushMsg.pmsgType
        || PushMsg_iotSensorDoorClose == pushMsg.pmsgType
        || PushMsg_iotSensorDoorBreak == pushMsg.pmsgType
        || PushMsg_iotSensorPirAlarm  == pushMsg.pmsgType
        || PushMsg_iotSensorSosAlarm  == pushMsg.pmsgType)
    {
        ret = YES;
    }
    else
    {
        ret = NO;
    }
    return ret;
}

#pragma mark - 数据加载
#pragma mark -- 加载推送消息列表
- (void)loadPushMsgList
{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.pushMsgListLock lockWrite];
        [strongSelf.pushMsgList removeAllObjects];
        if (NO == strongSelf.isOnlyShowOnDevMsg)
        {
            strongSelf.pushMsgList = [[PushMsgManager pushMsgList] mutableCopy];
        }
        else
        {
            strongSelf.pushMsgList = [[PushMsgManager pushMsgListOfDevice:strongSelf.curDevId] mutableCopy];
        }
        __block BOOL isExist     = NO;
        __block NSUInteger index = 0;
        [strongSelf.pushMsgList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                                 usingBlock:^(PushMessage * _Nonnull obj,
                                                              NSUInteger idx,
                                                              BOOL * _Nonnull stop)
        {
            GOS_STRONG_SELF;
            if ([obj.deviceId isEqualToString:strongSelf.pushMsg.deviceId]
                && [obj.pushTime isEqualToString:strongSelf.pushMsg.pushTime])
            {
                isExist = YES;
                index   = idx;
                *stop   = YES;
            }
        }];
        if (YES == isExist)
        {
            strongSelf.curMsgIndex = index;
        }
        [strongSelf.pushMsgListLock unLockWrite];
    });
}

#pragma mark -- 加载推送图片
- (void)loadPushImage
{
    BOOL isExist = NO;
    if (NO == m_isIotSensorMsg)
    {
        self.pushImg = [PushImageManager imgOfPushMsg:self.pushMsg
                                                exist:&isExist];
    }
    else
    {
        self.pushImg = [self imgOfIotMsg:self.pushMsg];
        isExist = YES;
    }
    if (NO == isExist)
    {
        [self configDownloadIndicatorAnimat:YES];
        if (NO == [PushImageManager isDownloadingOfMsg:self.pushMsg])
        {
            GosLog(@"推送图片还未下载，请求重新下载！");
            [PushImageManager downloadImageWithMsg:self.pushMsg];
        }
        else
        {
            GosLog(@"推送图片正在下载中，先用封面预展示！");
        }
        GosLog(@"添加下载结果通知！");
        [self addPushImgDownloadResultNotify];
    }
    else
    {
        [self configDownloadIndicatorAnimat:NO];
        GosLog(@"推送图片已下载，直接显示！");
    }
    [self refreshImgView];
}

- (UIImage *)imgOfIotMsg:(PushMessage *)pushMsg
{
    if (!pushMsg)
    {
        return nil;
    }
    UIImage *retImg = nil;
    switch (pushMsg.pmsgType)
    {
        case PushMsg_iotSensorLowBattery:   // IOT 设备低电报警
            break;
        case PushMsg_iotSensorDoorBreak:{   // IOT 设备防拆报警
            retImg = [self iOTCoverDefaultImg];
        }break;
        case PushMsg_iotSensorDoorOpen:{    // IOT 设备开门报警
            retImg = [self iOTCoverMagneticImg];
        }break;
        case PushMsg_iotSensorDoorClose:{   // IOT 设备关门报警
            retImg = [self iOTCoverMagneticImg];
        }break;
        case PushMsg_iotSensorPirAlarm:{    // IOT 设备 PIR 报警
            retImg = [self iOTCoverInfraredImg];
        }break;
        case PushMsg_iotSensorSosAlarm:{    // IOT 设备 SOS 报警
            retImg = [self iOTCoverSosAlarmImg];
        }break;
        default:
            break;
    }
    return retImg;
}

#pragma mark -- 刷新推送图片
- (void)refreshImgView
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.pushImgView.image = self.pushImg;
    });
}

#pragma mark - 通知处理
#pragma mark -- 添加推送图片现在完成通知
- (void)addPushImgDownloadResultNotify
{
    if (YES == m_hasAddImgDownloadFinishNotify)
    {
        return;
    }
    m_hasAddImgDownloadFinishNotify = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushImgDownloadResult:)
                                                 name:PUSH_IMG_DOWNLOAD_RESULT_NOTIFY
                                               object:nil];
}

#pragma mark -- 推送图片现在完成通知
- (void)pushImgDownloadResult:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict
        || NO == [[recvDict allKeys] containsObject:@"DeviceId"]
        || NO == [[recvDict allKeys] containsObject:@"PushImgName"]
        || NO == [[recvDict allKeys] containsObject:@"DownloadResult"])
    {
        return;
    }
    NSString *deviceId  = recvDict[@"DeviceId"];
    NSString *imgName   = recvDict[@"PushImgName"];
    BOOL downloadResult = [recvDict[@"DownloadResult"] boolValue];
    
    if (NO == [deviceId isEqualToString:self.curDevId]
        || NO == [imgName isEqualToString:self.pushImgName])
    {
        return;
    }
    [self configDownloadIndicatorAnimat:NO];
    if (NO == downloadResult)   // 下载失败
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"PushMsg_ImageDownloadFailure")];
    }
    else    // 下载成功
    {
        [self loadPushImage];
    }
}

#pragma mark -- 添加新推送消息解析并成功保存至数据库通知
- (void)addSaveSuccessMsgNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCurPushMsg:)
                                                 name:kPushMsgSaveSuccessNotify
                                               object:nil];
}

#pragma mark -- 添加点击 iOS 消息中心解析推送消息通知
- (void)addClickMsgNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCurPushMsg:)
                                                 name:kClickPushMsgNotify
                                               object:nil];
}

#pragma mark -- 显示最新(或者是点击的)推送消息
- (void)showCurPushMsg:(NSNotification *)notifyData
{
    if (!notifyData)
    {
        return;
    }
    PushMessage *curPushMsg = (PushMessage *)notifyData.object;
    if (!curPushMsg)
    {
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.pushMsgListLock lockWrite];
        if (YES == strongSelf.hasSwiped)
        {
            strongSelf.curMsgIndex++;
        }
        [strongSelf.pushMsgList insertObject:curPushMsg atIndex:0];
        [strongSelf.pushMsgListLock unLockWrite];
        
        if (NO == strongSelf.hasSwiped)  // 没有滑动过，直接显示
        {
            GosLog(@"没有左右滑动切换过，推送消息直接显示！");
            strongSelf.pushMsg  = curPushMsg;
            strongSelf.curDevId = curPushMsg.deviceId;
            [strongSelf resetParam];
            [strongSelf loadPushImage];
            [strongSelf handlePushMsg];
        }
        else    // 已经左右滑动，不更新
        {
            GosLog(@"已经左右滑动，不更新");
        }
    });
}

#pragma mark -- 处理推送消息
- (void)handlePushMsg
{
    NSString *infoStr = [self adaptTypeString];
    NSString *fromStr = DPLocalizedString(@"PushMsgFrom");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.pushMsgTitleLabel.text = infoStr;
        self.pushDevNameLabel.text  = [NSString stringWithFormat:@"%@%@", fromStr, self.pushMsg.deviceName];
        self.pushMsgTimeLabel.text  = self.pushMsg.pushTime;
    });
    
    if (NO == self.pushMsg.hasReaded)
    {
        GosLog(@"更新当前推送消息为已读！");
        self.pushMsg.hasReaded = YES;
        [PushMsgManager modifyushMsg:self.pushMsg];
        if (self.updateHasRead)
        {
            self.updateHasRead(self.curMsgIndex);
        }
        else    // 不是由消息列表 push 的
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushMsgHasReadedNotify
                                                                object:@{@"PushMsgIndex":@(self.curMsgIndex)}];
        }
    }
}

#pragma mark - 停止声光报警器
- (IBAction)actionCancelAlarm:(UIButton *)sender {
    [self.iosConfigSDK stopStrobeSirenOfDevice:self.pushMsg.deviceId];
}
#pragma mark - 停止声光报警器报警结果回调
- (void)stopStrobeSiren:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.iOTCloseBtn setImage:[UIImage imageNamed:@"icon_iot_sound_off"] forState:UIControlStateNormal];
            self.iOTCloseBtn.enabled = NO;
        });
        GosLog(@"停止声光报警器成功");
    }else{
        GosLog(@"停止声光报警器失败");
    }
}

#pragma mark -- 处理消息详情
- (NSString *)adaptTypeString
{
    NSString *infoStr;
    switch (self.pushMsg.pmsgType)
    {
        case PushMsg_unknown: break;
        case PushMsg_move:                infoStr = DPLocalizedString(@"PushMsgMoveEvent");          break; // 移动侦测
        case PushMsg_guard:               infoStr = DPLocalizedString(@"PushMsgMoveEvent");          break;
        case PushMsg_pir:                 infoStr = DPLocalizedString(@"PushMsgPirEvent");           break; // PIR
        case PushMsg_tempUpperLimit:      infoStr = DPLocalizedString(@"PushMsgTemUpLimitEvent");    break; // 温度上限报警
        case PushMsg_tempLowerLimit:      infoStr = DPLocalizedString(@"PushMsgTemLowLimitEvent");   break; // 温度下限报警
        case PushMsg_voice:               infoStr = DPLocalizedString(@"PushMsgVoiceEvent");         break; // 声音报警
        case PushMsg_bellRing:            infoStr = DPLocalizedString(@"PushMsgBellRingEvent");      break; // 按铃报警
        case PushMsg_lowBattery:          infoStr = DPLocalizedString(@"PushMsgLowBatteryEvent");    break; // 低电报警
        case PushMsg_iotSensorLowBattery: infoStr = DPLocalizedString(@"PushMsgIotLowBatteryEvent"); break; // Sensor 低电
        case PushMsg_iotSensorDoorOpen:   infoStr = DPLocalizedString(@"PushMsgIotDoorOpenEvent");   break; // 开门
        case PushMsg_iotSensorDoorClose:  infoStr = DPLocalizedString(@"PushMsgIotDoorCloseEvent");  break; // 关门
        case PushMsg_iotSensorDoorBreak:  infoStr = DPLocalizedString(@"PushMsgIotDoorBreakEvent");  break; // 防拆
        case PushMsg_iotSensorPirAlarm:   infoStr = DPLocalizedString(@"PushMsgIotPriEvent");        break; // PIR 报警
        case PushMsg_iotSensorSosAlarm:   infoStr = DPLocalizedString(@"PushMsgIotSosEvent");        break; // SOS 报警
        default:                                                                                     break;
    }
    return infoStr;
}

#pragma mark -- 查询设备是否已连接（点击推送启动 APP 进入该页面时需要查询）
- (BOOL)hasConnectedOfDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        return NO;
    }
    NSData *setData = GOS_GET_OBJ(GOS_HAS_CONN_SET_KEY);
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:setData];
    if (!set)
    {
        return NO;
    }
    else
    {
        if ([set containsObject:devId])
        {
            GosLog(@"设备（ID = %@）已创建连接！", devId);
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

#pragma mark -- 设置下载提示器是否显示动画
- (void)configDownloadIndicatorAnimat:(BOOL)isAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isAnimating)
        {
            [self.downloadingIndicator stopAnimating];
            self.downloadingIndicator.hidden = YES;
        }
        else
        {
            self.downloadingIndicator.hidden = NO;
            [self.downloadingIndicator startAnimating];
        }
    });
}

#pragma mark - 懒加载
- (UISwipeGestureRecognizer *)swipToLeft
{
    if (!_swipToLeft)
    {
        _swipToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(nextMessage)];
        _swipToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _swipToLeft;
}

- (UISwipeGestureRecognizer *)swipToRight
{
    if (!_swipToRight)
    {
        _swipToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(preMessage)];
        _swipToRight.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _swipToRight;
}

- (NSMutableArray<PushMessage *> *)pushMsgList
{
    if (!_pushMsgList)
    {
        _pushMsgList = [NSMutableArray arrayWithCapacity:0];
    }
    return _pushMsgList;
}

- (void)setCurDevId:(NSString *)curDevId
{
    if ([_curDevId isEqualToString:curDevId])
    {
        return;
    }
    _curDevId = [curDevId copy];
    GosLog(@"推送消息设备 ID 已改变，将当下列表更新为当前设备 ID 消息列表！");
    [self loadPushMsgList];
}

- (void)setHasSwiped:(BOOL)hasSwiped
{
    if (_hasSwiped == hasSwiped)
    {
        return;
    }
    _hasSwiped = hasSwiped;
    if (self.hasSwipBlock)
    {
        self.hasSwipBlock(_hasSwiped);
    }
}


#pragma mark - 按钮事件中心
#pragma mark -- ‘关闭’按钮事件
- (IBAction)closeBtnAction:(id)sender
{
    GosLog(@"推送消息详情页 - ‘关闭’按钮事件");
    if (self.vcDismissBlock)
    {
        self.vcDismissBlock(YES, self.curMsgIndex);
    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark -- ‘打开’按钮事件
- (IBAction)openBtnAction:(id)sender
{
    GosLog(@"推送消息详情页 - ‘打开’按钮事件");
    NSArray<DevDataModel*>*devList = [GosDevManager deviceList];
    __block BOOL isExist           = NO;
    __block NSUInteger index       = 0;
    @autoreleasepool
    {
        [devList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(DevDataModel * _Nonnull obj,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop)
         {
             if ([obj.DeviceId isEqualToString:self.pushMsg.deviceId])
             {
                 isExist = YES;
                 index   = idx;
                 *stop   = YES;
             }
         }];
    }
    if (YES == isExist)
    {
        DevDataModel *dev = devList[index];
        // 设备支持云存储
        if (StreamStoreCloud == dev.devCapacity.streamStoreType
            || StreamStoreOnlyCloud == dev.devCapacity.streamStoreType)
        {
            // TODO：还需获取是否开通云存储套餐
            GosLog(@"MsgDetailViewController：转至云存储回放页面！");
            NSDate *pushDate = [NSString dateFromString:self.pushMsg.pushTime
                                                 format:secondLevelDateFormatString];
            NSTimeInterval ts = [pushDate timeIntervalSince1970];
            CloudPlaybackViewController *cloudPBVC = [[CloudPlaybackViewController alloc] initWithDeviceId:dev.DeviceId
                                                                                           targetTimestamp:ts];
            [[self getCurNavigationVC] pushViewController:cloudPBVC
                                                 animated:YES];
        }
        else    // 设备不支持云存储
        {
            GosLog(@"MsgDetailViewController：转至实时预览页面！");
            IPCPlayViewController *ipcPlayVC = [[IPCPlayViewController alloc] init];
            ipcPlayVC.devModel               = dev;
            ipcPlayVC.abModel                = [DevAbilityManager abilityOfDevice:dev.DeviceId];
            ipcPlayVC.hasConnected           = [self hasConnectedOfDevice:dev.DeviceId];
            [[self getCurNavigationVC] pushViewController:ipcPlayVC
                                                 animated:YES];
        }
    }
    if (self.vcDismissBlock)
    {
        self.vcDismissBlock(YES, self.curMsgIndex);
    }
    [self dismissViewControllerAnimated:NO
                             completion:nil];
}


#pragma mark -- 上一条消息
- (void)preMessage
{
    if (0 == self.curMsgIndex)
    {
        GosLog(@"已经是最新一条推送消息了！");
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"PushMsg_IsLatestMsg")
                              forDuration:0.5f];
        self.hasSwiped = NO;
        return;
    }
    self.hasSwiped = YES;
    if (self.pushMsgList.count <= self.curMsgIndex - 1)
    {
        return;
    }
    [SVProgressHUD dismiss];
    [self.pushMsgListLock lockRead];
    self.curMsgIndex--;
    self.pushMsg = [self.pushMsgList objectAtIndex:self.curMsgIndex];
    [self.pushMsgListLock unLockRead];
    [self resetParam];
    [self loadPushImage];
    [self handlePushMsg];
    // 执行动画
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.msgDetailView.layer addAnimation:self.preMsgAnimation
                                        forKey:@"animation"];
    });
}

#pragma mark -- 下一条消息
- (void)nextMessage
{
    if (self.pushMsgList.count - 1 <= self.curMsgIndex)
    {
        GosLog(@"已经是最后一条推送消息了！");
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"PushMsg_IsLastMsg")
                              forDuration:0.5f];
        return;
    }
    self.hasSwiped = YES;
    if (self.pushMsgList.count <= self.curMsgIndex + 1)
    {
        return;
    }
    [SVProgressHUD dismiss];
    [self.pushMsgListLock lockRead];
    self.curMsgIndex++;
    self.pushMsg = [self.pushMsgList objectAtIndex:self.curMsgIndex];
    [self.pushMsgListLock unLockRead];
    [self resetParam];
    [self loadPushImage];
    [self handlePushMsg];
    // 执行动画
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.msgDetailView.layer addAnimation:self.nextMsgAnimation
                                        forKey:@"animation"];
    });
}
#pragma mark - lazy
-(iOSConfigSDK *)iosConfigSDK{
    if (!_iosConfigSDK) {
        _iosConfigSDK = [iOSConfigSDK shareCofigSdk];
        _iosConfigSDK.iotDelegate = self;
    }
    return _iosConfigSDK;
}
-(void) testShow{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d",self.pushMsg.pmsgType]
                                                             message:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:nil, nil];
        [alertView show];
    });
}
-(UIImage *)iOTCoverDefaultImg{
    if (!_iOTCoverDefaultImg) {
        _iOTCoverDefaultImg = [UIImage imageNamed:@"SensorApnsMsgSosAlarm"];
    }
    return _iOTCoverDefaultImg;
}
-(UIImage *)iOTCoverMagneticImg{
    if (!_iOTCoverMagneticImg) {
        _iOTCoverMagneticImg = [UIImage imageNamed:@"SensorApnsMsgMagnetic"];
    }
    return _iOTCoverMagneticImg;
}
-(UIImage *)iOTCoverInfraredImg{
    if (!_iOTCoverInfraredImg) {
        _iOTCoverInfraredImg = [UIImage imageNamed:@"SensorApnsMsgInfrared"];
    }
    return _iOTCoverInfraredImg;
}
-(UIImage *)iOTCoverSosAlarmImg{
    if (!_iOTCoverSosAlarmImg) {
        _iOTCoverSosAlarmImg = [UIImage imageNamed:@"SensorApnsMsgSosAlarm"];
    }
    return _iOTCoverSosAlarmImg;
}
-(UIImage *)iOTCoverSosImg{
    if (!_iOTCoverSosImg) {
        _iOTCoverSosImg = [UIImage imageNamed:@"SensorApnsMsgSos"];
    }
    return _iOTCoverSosImg;
}
@end
