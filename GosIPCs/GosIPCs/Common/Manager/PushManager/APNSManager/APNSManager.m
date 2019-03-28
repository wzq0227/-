//
//  APNSManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/12.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "APNSManager.h"
#import "PushMsgManager.h"
#import "GosDevManager.h"
#import "NSString+GosCheck.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSObject+CurrentVC.h"
#import "MessageListViewController.h"
#import "MsgDetailViewController.h"
#import "NSObject+CurrentVC.h"
#import "MsgDetailViewController.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


// TUTK 推送标志
#if DEBUG
#define TUTK_DEV    1
#else
#define TUTK_DEV    0
#endif

#define TUTK_HTTP_REQ_TIMEOUT               5       // TUTK（HTTP）请求超时时间
#define TUTK_HTTP_STATUS_CODE_SUCCESS       200     // TUTK（HTTP）请求成功状态码
#define TUTK_HTTP_ERR_CODE_NO_WHITE_LIST    @"422"  // TUTK（HTTP）请求错误码：‘推送非白名单’


static NSString * const kTutkPushUrl                = @"http://push.iotcplatform.com/";     // TUTK 注册 iOS 设备推送 URL
static NSString * const kPushMsgMove1               = @"VIDEO MOTION";                      // 移动监测推送1
static NSString * const kPushMsgMove2               = @"Monitor Motion Alert";              // 移动监测推送2
static NSString * const kPushMsgPir                 = @"PIR MOTION";                        // PIR推送
static NSString * const kPushMsgVoice1              = @"AUDIO MOTION";                      // 声音告警1
static NSString * const kPushMsgVoice2              = @"Monitor Audio Alert";               // 声音报警2
static NSString * const kPushMsgTempUpLimit         = @"HIGH TEMPERATURE ALARM";            // 温度上限推送
static NSString * const kPushMsgTempLowLimit        = @"LOW TEMPERATURE ALARM";             // 温度下限推送
static NSString * const kPushMsgLowBattery          = @"LOW BATTERY";                       // 低电量
static NSString * const kPushMsgBellRing            = @"BELL RING";                         // 按铃
static NSString * const kPushMsgIotSensorLowBattery = @"IOT SENSOR LOW BATTERY";            // 低电
static NSString * const kPushMsgIotSensorDoorOpen   = @"IOT SENSOR DOOR OPEN";              // 开门
static NSString * const kPushMsgIotSensorDoorClose  = @"IOT SENSOR DOOR CLOSE";             // 关门
static NSString * const kPushMsgIotSensorDoorBreak  = @"IOT SENSOR DOOR BREAK";             // 防拆
static NSString * const kPushMsgIotSensorPir        = @"IOT SENSOR PIR ALARM";              // PIR 报警
static NSString * const kPushMsgIotSensorSos        = @"IOT SENSOR SOS ALARM";              // SOS 报警


@interface APNSManager() <
                            UNUserNotificationCenterDelegate,
                            iOSConfigSDKPushDelegate
                         >
{
    BOOL m_hasSendTokenToServer;        // 是否已发送 token 到服务器
    BOOL m_hasInitAllDevsPushStatus;    // 是否已初始化所有设备推送（按理说不需要，但是目前的推送状态并没有跟 账号-手机 绑定，所有会出现同一账号，不同手机登录时，推送有的有有的没有，所有这里默认第一次获取推送状态时，立即设置对于的权限
}
@property (nonatomic, readwrite, strong) NSData *tokenData;
/** TUTk 平台推送处理队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t tutkPushQueue;
/** GOS 平台推送处理队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t gosPushQueue;
/** 处理'Remote'推送通知处理队列（串行） */
@property (nonatomic, readwrite, strong) dispatch_queue_t handleRemoteNotificationQueue;
/** 推送通知时间串格式‘yyyy-MM-dd HH:mm:ss’*/
@property (nonatomic, readwrite, strong) NSDateFormatter *formatter;
@property (nonatomic, readwrite, strong) iOSConfigSDK *configSdk;
/** 当前操作的账号 */
@property (nonatomic, readwrite, copy) NSString *curAccount;
@property (nonatomic, readwrite, copy) QueryPushResultBlock queryPSRusltBlock;

@end



@implementation APNSManager

+ (instancetype)shareManager
{
    static APNSManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == s_manager)
        {
            s_manager = [[APNSManager alloc] init];
        }
    });
    return s_manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        m_hasSendTokenToServer             = NO;
        m_hasInitAllDevsPushStatus         = NO;
        dispatch_queue_attr_t attr         = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                     QOS_CLASS_BACKGROUND, 0);
        self.tutkPushQueue                 = dispatch_queue_create("TutkPushOperationQueue", attr);
        self.gosPushQueue                  = dispatch_queue_create("GosPushOperationQueue", attr);
        self.handleRemoteNotificationQueue = dispatch_queue_create("GosHandleRemoteNotificationQueue", attr);
        _curAccount                        = [GosLoggedInUserInfo account];
        [self addLoginSuccessNotify];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- APNSManager dealloc ----------");
}

#pragma mark -- 向 APNS 服务器注册 Remote-Push
+ (void)registiOSRemoteApns
{
    [[self shareManager] registiOSRemoteApns];
}

#pragma mark -- 保存 APNS-Remote token
+ (void)saveiOSToken:(NSData *)devToken
{
    if (!devToken || 0 >= devToken.length)
    {
        GosLog(@"APNSManager：无法保存 APNS-Remote Token!");
        return;
    }
    GosLog(@"APNSManager：保存 APNS-Remote Token!");
    [APNSManager shareManager].tokenData = [NSData dataWithData:devToken];
}

#pragma mark -- ‘打开’设备推送功能
+ (void)openPushWithDevId:(NSString *)devId
                   result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘打开’设备（ID = %@）推送功能！", devId);
        return;
    }
    [[self shareManager] openPushWithDevId:devId
                                    result:resultBlock];
}

#pragma mark -- 关闭设备推送功能
+ (void)closePushWithDevId:(NSString *)devId
                    result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘关闭’设备（ID = %@）推送功能！", devId);
        return;
    }
    [[self shareManager] closePushWithDevId:devId
                                     result:resultBlock];
}

#pragma mark -- 查询所有设备推送状态
+ (void)queryAllDevPushStatus:(QueryPushResultBlock)resultBlock
{
    [[self shareManager] queryAllDevPushStatus:resultBlock];
}

#pragma mark -- 处理‘Remote’推送通知
+ (void)handleRemoteNotification:(NSDictionary *)userInfo
                         isClick:(BOOL)isClick
{
    if (!userInfo)
    {
        GosLog(@"APNSManager：无法处理‘Remote’推送通知，userInfo = nil");
        return;
    }
    [[self shareManager] handleRemoteNotification:userInfo
                                          isClick:isClick];
}


#pragma makr - Private
#pragma mark -- 注册 iOS 设备 APNS ‘Remote’推送通知
- (void)registiOSRemoteApns
{
    if (NSFoundationVersionNumber_iOS_8_0 > NSFoundationVersionNumber)    // iOS 8.0 以前
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
#endif
    }
    else if (NSFoundationVersionNumber_iOS_8_0 <= NSFoundationVersionNumber
             && NSFoundationVersionNumber_iOS_9_x_Max >= NSFoundationVersionNumber) // iOS 8.0 ~ iOS 10.0
    {
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:[NSSet setWithObject:categorys]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        if (@available(iOS 10.0, *))
        {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self; // 必须写代理，不然无法监听通知的接收与点击
            UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
            [center requestAuthorizationWithOptions:options
                                  completionHandler:^(BOOL granted, NSError * _Nullable error)
             {
                 if (NO == granted)
                 {
                     GosLog(@"APNSManager：iOS 10.0 APNS-Remote 注册失败：%@", error.localizedDescription);
                 }
                 else
                 {
                     GosLog(@"APNSManager：iOS 10.0 APNS-Remote 注册成功！");
                     [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                         
                         GosLog(@"APNSManager：iOS 10.0 APNS-Remote settings: %@", settings);
                     }];
                 }
             }];
        }
    }
    // 执行注册 APNS-Remote（注册回调结果：didRegisterForRemoteNotificationsWithDeviceToken or didFailToRegisterForRemoteNotificationsWithError）
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark -- 发送 APNS-Remote Token 给服务器
- (void)registPushWithToken:(NSString *)pushToken
{
    if (IS_EMPTY_STRING(pushToken))
    {
        GosLog(@"APNSManager：无法发送 APNS-Push-Token 给服务器！");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.tutkPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf registTutkPushWithToken:pushToken];
    });
    dispatch_async(self.gosPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf registGosPushWithToken:pushToken];
    });
}

#pragma mark -- ‘打开’设备推送功能
- (void)openPushWithDevId:(NSString *)devId
                   result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘打开’设备（ID = %@）推送功能！", devId);
        return;
    }
    // 这里 TUTK、GOS 两个平台同时打开（因为要兼容所有设备，有的设备是 TUTK 平台推送，有的设备是 GOS 平台推送）
    /*
     可能存在问题：由于要兼容两个平台的设备，应该区分不同平台设置推送的结果回调，用于 UI 展示；
     问题：如果某一平台设置失败，而其走的是另一平台，则其结果是错误的。
     原因：目前暂时无法区分设备具体是走哪个平台的推送
     */
    GOS_WEAK_SELF;
    dispatch_async(self.tutkPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf openTutkPushWithDevId:devId
                                   result:resultBlock];
    });
    dispatch_async(self.gosPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf openGosPushWithDevId:devId
                                  result:resultBlock];
    });
}

#pragma mark -- 关闭设备推送功能
- (void)closePushWithDevId:(NSString *)devId
                    result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘关闭’设备（ID = %@）推送功能！", devId);
        return;
    }
    // 这里 TUTK、GOS 两个平台同时关闭（因为要兼容所有设备，有的设备是 TUTK 平台推送，有的设备是 GOS 平台推送）
    /*
     可能存在问题：由于要兼容两个平台的设备，应该区分不同平台设置推送的结果回调，用于 UI 展示；
     问题：如果某一平台设置失败，而其走的是另一平台，则其结果是错误的。
     原因：目前暂时无法区分设备具体是走哪个平台的推送
     */
    GOS_WEAK_SELF;
    dispatch_async(self.tutkPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf closeTutkPushWithDevId:devId
                                    result:resultBlock];
    });
    dispatch_async(self.gosPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf closeGosPushWithDevId:devId
                                   result:resultBlock];
    });
}

#pragma mark -- 查询所有设备推送状态
- (void)queryAllDevPushStatus:(QueryPushResultBlock)resultBlock
{
    if (IS_EMPTY_STRING(self.curAccount))
    {
        GosLog(@"APNSManager：无法查询账号（Account = %@）所有设备推送状态！", self.curAccount);
        if (resultBlock)
        {
            resultBlock(NO, nil);
        }
        return;
    }
    // 这里只查询 GOS 平台（因为要无论是 TUTK 平台推送还是 GOS 平台推送，其状态都保留在 GOS 平台）
    self.queryPSRusltBlock = resultBlock;
    GOS_WEAK_SELF;
    dispatch_async(self.gosPushQueue, ^{
        
        GOS_STRONG_SELF;
        [strongSelf queryGosAllDevPushStatus];
    });
}

#pragma mark -- 初始化所有设备推送状态
- (void)initAllDevPushStatus:(NSArray<DevPushStatusModel*>*)sList
{
    if (!sList || 0 == sList.count)
    {
        return;
    }
    if (YES == m_hasInitAllDevsPushStatus)
    {
        GosLog(@"APNSManager：该账户的所有设备推送已经初始化，无需再次初始化！");
        return;
    }
    GosLog(@"APNSManager：开始账户的所有设备推送。。。");
    m_hasInitAllDevsPushStatus = YES;
    GOS_WEAK_SELF;
    [sList enumerateObjectsWithOptions:NSEnumerationConcurrent
                            usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                         NSUInteger idx,
                                         BOOL * _Nonnull stop)
    {
        GOS_STRONG_SELF;
        if (NO == obj.PushFlag) // 关闭设备推送
        {
            [strongSelf closePushWithDevId:obj.DeviceId
                                    result:^(BOOL isSuccess)
             {
                 GosLog(@"APNSManager：初始化设备（ID = %@）关闭推送结果：%d", obj.DeviceId, isSuccess);
             }];
        }
        else    // 打开设备推送
        {
            [strongSelf openPushWithDevId:obj.DeviceId
                                   result:^(BOOL isSuccess)
             {
                 GosLog(@"APNSManager：初始化设备（ID = %@）打开推送结果：%d", obj.DeviceId, isSuccess);
             }];
        }
    }];
}

#pragma mark - TUTK
#pragma mark -- 向 TUTK 平台发送 APNS-Remote Token
- (void)registTutkPushWithToken:(NSString *)pushToken
{
    if (IS_EMPTY_STRING(pushToken))
    {
        GosLog(@"APNSManager：无法发送 APNS-Push-Token 给 TUTK 服务器！");
    }
    NSString *token   = [NSString stringWithFormat:@"&token=%@",pushToken];
    NSString *postUrl = [NSString stringWithFormat:@"tpns?cmd=client&os=ios%@%@%@%@&ucid=&dev=%d",[self getAppId], token,[self getUdid], [self getLanguage], TUTK_DEV];
    NSString *urlresp = [NSString stringWithFormat:@"%@%@",kTutkPushUrl, postUrl];
    NSString *urlStr  = [urlresp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];   // 将 URL 转码
    GosLog(@"APNSManager：准备向 TUTK 平台发送 APNS-Remote-Token，URL = %@", urlStr);
    GOS_WEAK_SELF;
    [self httpReqWithUrl:urlStr
            finishHandle:^(NSData * _Nullable data,
                           NSURLResponse * _Nullable response,
                           NSError * _Nullable error)
    {
        GOS_STRONG_SELF;
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)response;
        if (!error && TUTK_HTTP_STATUS_CODE_SUCCESS == httpResp.statusCode)
        {
            GosLog(@"APNSManager：TUTK-APNS-Remote 注册成功！");
        }
        else
        {
            GosLog(@"APNSManager：TUTK-APNS-Remote 注册失败，errorCode = %d （%@）", (int)error.code, error.localizedDescription);
        }
    }];
}

- (void)openTutkPushWithDevId:(NSString *)devId
                       result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘打开’设备（ID = %@）（TUTK 平台）推送功能！", devId);
        return;
    }
    NSString *tutkDevId = devId;
    if (20 == devId.length)
    {
        tutkDevId = devId;
    }
    else if (28 == devId.length)
    {
        tutkDevId = [devId substringFromIndex:8];
    }
    else
    {
        tutkDevId = devId;
    }
    NSString *uid      = [NSString stringWithFormat:@"&uid=%@",tutkDevId];
    NSString *interavl = [NSString stringWithFormat:@"&interval=%d",0];
    NSString *postStr  = [NSString stringWithFormat:@"tpns?cmd=mapping&os=ios%@%@%@%@", [self getAppId], uid, [self getUdid], interavl];
    NSString *urlStr   = [NSString stringWithFormat:@"%@%@", kTutkPushUrl, postStr];
    urlStr             = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    GosLog(@"APNSManager：准备向 TUTK 平台‘打开’设备（ID = %@）推送功能，URL = %@", devId, urlStr);
    GOS_WEAK_SELF;
    [self httpReqWithUrl:urlStr
            finishHandle:^(NSData * _Nullable data,
                           NSURLResponse * _Nullable response,
                           NSError * _Nullable error)
    {
        GOS_STRONG_SELF;
        NSString *str = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)response;
        if (!error && TUTK_HTTP_STATUS_CODE_SUCCESS == httpResp.statusCode)
        {
            GosLog(@"APNSManager：‘打开’设备（ID = %@）TUTK 平台推送功能成功！", devId);
            // 注意：错误码（422）是不在 TUTK 平台的白名单（这是由于是 ID 是 TUTK 平台的，但是推送走自己平台）,也认为是成功的
            if ([str containsString:TUTK_HTTP_ERR_CODE_NO_WHITE_LIST])
            {
                [strongSelf saveTutkNoWhiteDevId:devId];
            }
            if (resultBlock)
            {
                resultBlock(YES);
            }
        }
        else
        {
            GosLog(@"APNSManager：‘打开’设备（ID = %@）TUTK 平台推送功能成失败，errorCode = %d（%@）", devId, (int)error.code, error.localizedDescription);
            if (resultBlock)
            {
                resultBlock(NO);
            }
        }
    }];
}

- (void)closeTutkPushWithDevId:(NSString *)devId
                        result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘关闭’设备（ID = %@）（TUTK 平台）推送功能！", devId);
        return;
    }
    NSString *tutkDevId = devId;
    if (20 == devId.length)
    {
        tutkDevId = devId;
    }
    else if (28 == devId.length)
    {
        tutkDevId = [devId substringFromIndex:8];
    }
    else
    {
        tutkDevId = devId;
    }
    NSString *uid     = [NSString stringWithFormat:@"&uid=%@",tutkDevId];
    NSString *postStr = [NSString stringWithFormat:@"tpns?cmd=rm_mapping&os=ios%@%@%@", [self getAppId], uid, [self getUdid]];
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@", kTutkPushUrl, postStr];
    urlStr            = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GosLog(@"APNSManager：准备向 TUTK 平台‘关闭’设备（ID = %@）推送功能，URL = %@", devId, urlStr);
    GOS_WEAK_SELF;
    [self httpReqWithUrl:urlStr
            finishHandle:^(NSData * _Nullable data,
                           NSURLResponse * _Nullable response,
                           NSError * _Nullable error)
    {
        GOS_STRONG_SELF;
        NSString *str = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)response;
        if (!error && TUTK_HTTP_STATUS_CODE_SUCCESS == httpResp.statusCode)
        {
            GosLog(@"APNSManager：‘关闭’设备（ID = %@）TUTK 平台推送功能成功！", devId);
            // 注意：错误码（422）是不在 TUTK 平台的白名单（这是由于是 ID 是 TUTK 平台的，但是推送走自己平台）,也认为是成功的
            if ([str containsString:TUTK_HTTP_ERR_CODE_NO_WHITE_LIST])
            {
                [strongSelf saveTutkNoWhiteDevId:devId];
            }
            if (resultBlock)
            {
                resultBlock(YES);
            }
        }
        else
        {
            GosLog(@"APNSManager：‘关闭’设备（ID = %@）TUTK 平台推送功能成失败，errorCode = %d（%@）", devId, (int)error.code, error.localizedDescription);
            if (YES == [strongSelf isTutkNoWhiteWithDevId:devId])  // TUTK 非白名单情况
            {
                GosLog(@"APNSManager：‘关闭’设备（ID = %@）TUTK 平台推送功能成功 - 非白名单情况！", devId);
                resultBlock(YES);
                return;
            }
            if (resultBlock)
            {
                resultBlock(NO);
            }
        }
    }];
}

#pragma mark - GOS
#pragma mark -- 向 3.5 平台发送 APNS-Remote Token
- (void)registGosPushWithToken:(NSString *)pushToken
{
    if (IS_EMPTY_STRING(pushToken))
    {
        GosLog(@"APNSManager：无法发送 APNS-Push-Token 给 TUTK 服务器！");
    }
    GosLog(@"APNSManager：准备向 GOS 平台发送 APNS-Remote-Token");
    [self.configSdk registPushWithToken:pushToken
                              onAccount:[GosLoggedInUserInfo account]
                                  appId:[self appId]
                                iOSUUID:[self uuid]];
}

- (void)openGosPushWithDevId:(NSString *)devId
                      result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘打开’设备（ID = %@）（GOS 平台）推送功能！", devId);
        return;
    }
    GosLog(@"APNSManager：准备向 GOS 平台‘打开’设备（ID = %@）推送功能！", devId);
    [self.configSdk openPushOfDevice:devId
                           onAccount:[GosLoggedInUserInfo account]
                               appId:[self appId]
                             iOSUUID:[self uuid]];
}

- (void)closeGosPushWithDevId:(NSString *)devId
                       result:(void (^) (BOOL isSuccess))resultBlock
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"APNSManager：无法‘关闭’设备（ID = %@）（GOS 平台）推送功能！", devId);
        return;
    }
    GosLog(@"APNSManager：准备向 GOS 平台‘关闭’设备（ID = %@）推送功能！", devId);
    [self.configSdk closePushOfDevice:devId
                            onAccount:[GosLoggedInUserInfo account]
                                appId:[self appId]
                              iOSUUID:[self uuid]];
}

- (void)queryGosAllDevPushStatus
{
    [self.configSdk queryPushStatusOnAccount:self.curAccount
                                       appId:[self appId]
                                     iOSUUID:[self uuid]];
}


#pragma mark -
#pragma mark -- 添加登录成功通知
- (void)addLoginSuccessNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginSuccess:)
                                                 name:kLoginSuccessNotify
                                               object:nil];
}

- (void)LoginSuccess:(NSNotification *)notifyData
{
    [self setCurAccount:[GosLoggedInUserInfo account]]; // 先更新账号信息
    
    if (YES == m_hasSendTokenToServer)
    {
        GosLog(@"APNSManager：APNS-Remote-Token 已发送到服务器，无需再发送！");
        return;
    }
    m_hasSendTokenToServer = YES;
    GOS_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        GosLog(@"APNSManager：准备发送 APNS-Remote-Token 到服务器！");
        [self registPushWithToken:[self extractTokenWithData:self.tokenData]];
    });
}

#pragma mark -- 提取成功注册 APNS-Remote 返回的 token 数据
- (NSString *)extractTokenWithData:(NSData *)tokenData
{
    NSString *tokenString = [NSString stringWithFormat:@"%@",tokenData];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" "
                                                         withString:@""];
    return tokenString;
}

#pragma mark -- 获取 APPID
- (NSString *)getAppId
{
    NSString *appidStr = [NSString stringWithFormat:@"&appid=%@", [self appId]];
    return appidStr;
}

- (NSString *)appId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

#pragma mark -- 获取 iOS 设备 UDID
// （注意：系统 API 获取 UDID 在卸载 APP 后重装会变化）
- (NSString *)uuid
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)getUdid
{
    NSString *udidStr = [NSString stringWithFormat:@"&udid=%@", [self uuid]];
    return udidStr;
}

#pragma mark -- 获取语言
- (NSString *)getLanguage
{
    NSString *language = [NSString stringWithFormat:@"&lang=enUS"];
    return language;
}

#pragma mark -- 保存 TUTK-推送 ‘非白名单’ 设备ID
- (void)saveTutkNoWhiteDevId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        return;
    }
    NSData *setData   = GOS_GET_OBJ(TUTK_PUSH_NO_WHITE_KEY);
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:setData];
    if (!set)
    {
        set = [NSMutableSet setWithCapacity:0];
    }
    [set addObject:devId];
    GosLog(@"APNSManager：添加设备（ID = %@）到 TUTK-推送 非白名单！", devId);
    setData = [NSKeyedArchiver archivedDataWithRootObject:set];
    GOS_SAVE_OBJ(setData, TUTK_PUSH_NO_WHITE_KEY);
}

#pragma mark -- 检查设备ID 是否在 TUTK-推送 非白名单中
- (BOOL)isTutkNoWhiteWithDevId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        return NO;
    }
    NSData *setData = GOS_GET_OBJ(TUTK_PUSH_NO_WHITE_KEY);
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:setData];
    if (!set)
    {
        return NO;
    }
    else
    {
        if ([set containsObject:devId])
        {
            GosLog(@"APNSManager：设备（ID = %@）是 TUTK-推送 非白名单！", devId);
            return YES;
        }
        else
        {
            return NO;
        }
    }
}


#pragma mark - 推送通知处理中心
#pragma mark -- 安全访问 JSON 数据
- (BOOL)hasValueOnJson:(NSDictionary *)jsonDict
                forKey:(NSString *)key
{
    if (!jsonDict || IS_EMPTY_STRING(key))
    {
        return NO;
    }
    if (NO == [[jsonDict allKeys] containsObject:key]
        || [[NSNull null] isEqual:jsonDict[key]])
    {
        return NO;
    }
    return YES;
}

#pragma mark -- 检验 pushUrl 是否合法
- (BOOL)isLegalUrl:(NSString *)pushUrl
{
    if (IS_EMPTY_STRING(pushUrl))
    {
        GosLog(@"APNSManager：无法检验 pushUrl 是否合法， pushUrl = nil");
        return NO;
    }
    if (NO == [pushUrl hasPrefix:@"h"]
        || NO == [pushUrl hasSuffix:@".jpg"])
    {
        return NO;
    }
    return YES;
}

#pragma mark -- 获取系统当前时间串
- (NSString *)curTimeString
{
    NSDate *date         = [NSDate date];
    NSString *curTimeStr = [self.formatter stringFromDate:date];
    return curTimeStr;
}

#pragma mark -- 格式化推送通知时间
- (NSString *)formatFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *timeStr          = [self.formatter stringFromDate:date];
    return timeStr;
}

#pragma mark -- 从推送 URL 中提取推送通知时间串 ‘yyyy-MM-dd HH:mm:ss’
- (NSString *)extractTimeWithPushUrl:(NSString *)pushUrl
{
    if (IS_EMPTY_STRING(pushUrl))
    {
        GosLog(@"APNSManager：无法提取推送通知时间，使用本地时间代替，pushUrl = nil");
        
        return [self curTimeString];
    }
    NSArray *strArray = [pushUrl componentsSeparatedByString:@"/"];
    if (0 >= strArray.count)
    {
        GosLog(@"APNSManager：提取推送通知时间失败，使用本地时间代替！");
        return [self curTimeString];
    }
    NSString *timeStr = strArray[strArray.count - 1];
    if (14 >= timeStr.length)
    {
        GosLog(@"APNSManager：提取推送通知时间失败，使用本地时间代替！");
        return [self curTimeString];
    }
    NSString *realTimeStr   = [timeStr substringToIndex:14];
    NSString *yearStr       = [realTimeStr substringToIndex:4];
    NSString *monthStr      = [realTimeStr substringWithRange:NSMakeRange(4, 2)];
    NSString *dayStr        = [realTimeStr substringWithRange:NSMakeRange(6, 2)];
    NSString *hourStr       = [realTimeStr substringWithRange:NSMakeRange(8, 2)];
    NSString *minuteStr     = [realTimeStr substringWithRange:NSMakeRange(10,2)];
    NSString *secondStr     = [realTimeStr substringWithRange:NSMakeRange(12,2)];
    NSString *formatTimeStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", yearStr, monthStr, dayStr, hourStr, minuteStr, secondStr];
    
    return formatTimeStr;
}

#pragma mark -- 格式化推送通知时间串
// 仅适用于‘IOT’通知消息，因为 IOT 设备没有抓拍功能，所以没有 pushUrl
- (NSString *)formatIotpushTime:(NSString *)timeStr
{
    if (IS_EMPTY_STRING(timeStr)
        || 14 > timeStr.length)
    {
        GosLog(@"APNSManager：格式化推送通知时间串失败，使用本地时间代替！");
        return [self curTimeString];
    }
    NSString *realTimeStr   = [timeStr substringToIndex:14];
    NSString *yearStr       = [realTimeStr substringToIndex:4];
    NSString *monthStr      = [realTimeStr substringWithRange:NSMakeRange(4, 2)];
    NSString *dayStr        = [realTimeStr substringWithRange:NSMakeRange(6, 2)];
    NSString *hourStr       = [realTimeStr substringWithRange:NSMakeRange(8, 2)];
    NSString *minuteStr     = [realTimeStr substringWithRange:NSMakeRange(10,2)];
    NSString *secondStr     = [realTimeStr substringWithRange:NSMakeRange(12,2)];
    NSString *formatTimeStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", yearStr, monthStr, dayStr, hourStr, minuteStr, secondStr];
    
    return formatTimeStr;
}

#pragma mark -- ‘Remote’推送通知处理
- (void)handleRemoteNotification:(NSDictionary *)userInfo
                         isClick:(BOOL)isClick
{
    if (!userInfo)
    {
        GosLog(@"APNSManager：无法处理‘Remote’推送通知，userInfo = nil");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.handleRemoteNotificationQueue, ^{
        
        GOS_STRONG_SELF;
        if (NO == [self hasValueOnJson:userInfo forKey:@"aps"]
            || NO == [self hasValueOnJson:userInfo[@"aps"] forKey:@"alert"]
            || NO == [self hasValueOnJson:userInfo forKey:@"uid"]
            || NO == [self hasValueOnJson:userInfo forKey:@"event_time"])
        {
            GosLog(@"APNSManager：无法处理‘Remote’推送通知，缺少必要的 JSON-key");
            return;
        }
        NSString *pushType = userInfo[@"aps"][@"alert"];
        pushType           = [pushType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *deviceId = userInfo[@"uid"];
        NSString *pushUrl  = userInfo[@"event_time"];
        NSString *recvTime = userInfo[@"received_at"];
        NSString *loginAcc = [GosLoggedInUserInfo account];
        NSArray<DevDataModel*> *devArray = [GosDevManager deviceList];
        __block BOOL isExist           = NO;
        __block NSString *existDevId   = nil;
        __block NSString *existDevName = nil;
        [devArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevDataModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
         {
             if ([obj.DeviceId containsString:deviceId])
             {
                 isExist      = YES;
                 existDevId   = [obj.DeviceId copy];
                 existDevName = [obj.DeviceName copy];
                 *stop        = YES;
             }
         }];
        if (NO == isExist)
        {
            GosLog(@"APNSManager：不处理当前收到的推送消息，因为设备（ID = %@）不在已登录账（Account = %@）号中！", deviceId, loginAcc);
            return;
        }
        GosLog(@"APNSManager：开始解析设备（ID = %@）当前收到的推送消息！", existDevId);
        [strongSelf parseMsgWithDeviceId:existDevId
                              deviceName:existDevName
                                pushType:pushType
                                 pushUrl:pushUrl
                            receivedTime:recvTime
                               isClicked:isClick];
    });
}

#pragma mark -- 解析推送消息
- (void)parseMsgWithDeviceId:(NSString *)deviceId
                  deviceName:(NSString *)devName
                    pushType:(NSString *)pushType
                     pushUrl:(NSString *)pushUrl
                receivedTime:(NSString *)recvTime
                   isClicked:(BOOL)isClicked;
{
    if (IS_EMPTY_STRING(deviceId)
        || IS_EMPTY_STRING(pushType)
        /*|| IS_EMPTY_STRING(pushUrl)*/)
    {
        GosLog(@"APNSManager：参数为空，无法解析推送消息！");
        return;
    }
    NSString *pushTime = @"";
    if (NO == [self isLegalUrl:pushUrl])
    {
        NSTimeInterval timeInterval = recvTime.doubleValue;
        pushTime = [self formatFromTimeInterval:timeInterval];
    }
    else
    {
        pushTime = [self extractTimeWithPushUrl:pushUrl];
    }
    
    PushMsgType pushMsgType = [self pushTypeOfMsgStr:pushType];
    
    if (PushMsg_iotSensorLowBattery == pushMsgType
        || PushMsg_iotSensorDoorOpen == pushMsgType
        || PushMsg_iotSensorDoorClose == pushMsgType
        || PushMsg_iotSensorDoorBreak == pushMsgType
        || PushMsg_iotSensorPirAlarm == pushMsgType
        || PushMsg_iotSensorSosAlarm == pushMsgType)
    {
        pushTime = [self formatIotpushTime:pushUrl];
    }
    
    PushMessage *pushMsg = [[PushMessage alloc] init];
    pushMsg.account      = [GosLoggedInUserInfo account];
    pushMsg.deviceId     = deviceId;
    pushMsg.deviceName   = devName;
    pushMsg.pushUrl      = pushUrl;
    pushMsg.pushTime     = pushTime;
    pushMsg.hasReaded    = isClicked;
    pushMsg.pmsgType     = pushMsgType;
    
    BOOL ret = [PushMsgManager addPushMsg:pushMsg];
    if (YES == ret)
    {
        GosLog(@"APNSManager：推送消息已解析并成功保存到数据库！");
        if (YES == isClicked)   // 点击推送消息逻辑处理
        {
            GosLog(@"APNSManager：点击推送处理：跳转至推送消息详情页面！");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIViewController *curTopVC = [self getCurrentVC];
                if ([curTopVC isKindOfClass:[MsgDetailViewController class]])   // 已经展示该页面，只需更新内容
                {
                    GosLog(@"APNSManager：推送消息详情页面已展示，只需更新内容即可！");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kClickPushMsgNotify
                                                                        object:pushMsg];
                }
                else
                {
                    MsgDetailViewController  *msgDetailVC = [[MsgDetailViewController alloc] init];
                    msgDetailVC.pushMsg                   = pushMsg;
                    msgDetailVC.isOnlyShowOnDevMsg        = YES;
                    [curTopVC presentViewController:msgDetailVC
                                           animated:YES
                                         completion:nil];
                }
                // 同样也更新列表页
                GosLog(@"APNSManager：消息列表页，发送通知看是否需要更新！");
                [[NSNotificationCenter defaultCenter] postNotificationName:kClickPushMsgToUpdateListNotify
                                                                    object:pushMsg];
            });
        }
        else    // 没有点击推送，直接发送通知
        {
            GosLog(@"APNSManager：没有点击推送，直接发送通知！");
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushMsgSaveSuccessNotify
                                                                object:pushMsg];
        }
    }
    else
    {
        GosLog(@"APNSManager：推送消息解析失败！");
    }
}

#pragma mark -- 推送通知类型检查
- (PushMsgType)pushTypeOfMsgStr:(NSString *)msgStr
{
    if (IS_EMPTY_STRING(msgStr))
    {
        return PushMsg_unknown;
    }
    PushMsgType pushType = PushMsg_unknown;
    
    if ([msgStr isCaseInsensitiveEqualToString:kPushMsgMove1]
        || [msgStr isCaseInsensitiveEqualToString:kPushMsgMove2])
    {
        pushType = PushMsg_move;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgPir])
    {
        pushType = PushMsg_pir;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgTempUpLimit])
    {
        pushType = PushMsg_tempUpperLimit;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgTempLowLimit])
    {
        pushType = PushMsg_tempLowerLimit;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgVoice1]
            || [msgStr isCaseInsensitiveEqualToString:kPushMsgVoice2])
    {
        pushType = PushMsg_voice;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgLowBattery])
    {
        pushType = PushMsg_lowBattery;
    }
    else if([msgStr isCaseInsensitiveEqualToString:kPushMsgBellRing])
    {
        pushType = PushMsg_bellRing;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorLowBattery])
    {
        pushType = PushMsg_iotSensorLowBattery;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorDoorOpen])
    {
        pushType = PushMsg_iotSensorDoorOpen;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorDoorClose])
    {
        pushType = PushMsg_iotSensorDoorClose;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorDoorBreak])
    {
        pushType = PushMsg_iotSensorDoorBreak;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorPir])
    {
        pushType = PushMsg_iotSensorPirAlarm;
    }
    else if ([msgStr isCaseInsensitiveEqualToString:kPushMsgIotSensorSos])
    {
        pushType = PushMsg_iotSensorSosAlarm;
    }
    else
    {
        pushType = PushMsg_unknown;
    }
    return pushType;
}

#pragma mark - 懒加载
- (NSDateFormatter *)formatter
{
    if (!_formatter)
    {
        _formatter            = [[NSDateFormatter alloc] init];
        _formatter.dateStyle  = NSDateFormatterMediumStyle;
        _formatter.timeStyle  = NSDateFormatterShortStyle;
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _formatter.timeZone   = [NSTimeZone systemTimeZone];
    }
    return _formatter;
}
- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.pushDelegate = self;
    }
    return _configSdk;
}

- (void)setCurAccount:(NSString *)curAccount
{
    if (!curAccount)
    {
        return;
    }
    m_hasInitAllDevsPushStatus = NO;    // 即使账号没变，也要初始化
    if (NO == [_curAccount isEqualToString:curAccount]) // 账号改变了
    {
        GosLog(@"APNSManager：账号变了！");
        m_hasSendTokenToServer     = NO;
        _curAccount = [curAccount copy];
    }
}


#pragma mark -
#pragma mark -- HTTP 请求
- (void)httpReqWithUrl:(NSString *)urlStr
          finishHandle:(void (^)(NSData * _Nullable data,
                                 NSURLResponse * _Nullable response,
                                 NSError * _Nullable error))finishHandle
{
    if (IS_EMPTY_STRING(urlStr))
    {
        GosLog(@"APNSManager：无法发送 HTTP 请求，ulrStr = nil");
        return;
    }
    NSURL *url                   = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval      = TUTK_HTTP_REQ_TIMEOUT;
    NSURLSession *session        = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable response,
                                                            NSError * _Nullable error)
    {
        if (finishHandle)
        {
            finishHandle(data, response, error);
        }
    }];
    [task resume];
}


#pragma mark - iOSConfigSDKPushDelegate
- (void)registPushToken:(BOOL)isSuccess
             errorCode:(int)eCode
{
    if (NO == isSuccess)
    {
        GosLog(@"APNSManager：GOS-APNS-Remote 注册失败，errorCode = %d",eCode);
    }
    else
    {
        GosLog(@"APNSManager：GOS-APNS-Remote 注册成功！");
    }
}

- (void)openPush:(BOOL)isSuccess
        deviceId:(NSString *)devId
       errorCode:(int)eCode
{
    if (NO == isSuccess)
    {
        GosLog(@"APNSManager：‘打开’设备（ID = %@t）GOS 平台推送功能失败，errorCode = %d", devId, eCode);
    }
    else
    {
        GosLog(@"APNSManager：‘打开’设备（ID = %@）GOS 平台推送功能成功！", devId);
    }
}

- (void)closePush:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode
{
    if (NO == isSuccess)
    {
        GosLog(@"APNSManager：‘关闭’设备（ID = %@t）GOS 平台推送功能失败，errorCode = %d", devId, eCode);
    }
    else
    {
        GosLog(@"APNSManager：‘关闭’设备（ID = %@）GOS 平台推送功能成功！", devId);
    }
}

- (void)queryPushStatus:(BOOL)isSuccess
             statusList:(NSArray<DevPushStatusModel *> *)sList
              errorCode:(int)eCode
{
    if (NO == isSuccess)
    {
        GosLog(@"APNSManager：‘查询所有设备推送状态失败，errorCode = %d", eCode);
    }
    else
    {
        GosLog(@"APNSManager：APNSManager：查询所有设备推送状态成功！");
        GOS_WEAK_SELF;
        dispatch_async([QueueManager bgQueue], ^{
            
            GOS_STRONG_SELF;
            [strongSelf initAllDevPushStatus:[sList mutableCopy]];
        });
    }
    GOS_WEAK_SELF;
    dispatch_async([QueueManager bgQueue], ^{
       
        GOS_STRONG_SELF;
        if (strongSelf.queryPSRusltBlock)
        {
            strongSelf.queryPSRusltBlock(isSuccess, sList);
        }
    });
}

#pragma mark -- ‘长连接’推送消息回调
// 不用处理，这是 GOS 平台发送推送消息给 APNS 的请求
- (void)recvOfDevice:(NSString *)devId
                time:(long)pushTime
                type:(int)pushType
                 url:(NSString *)pushUrl
{
    GosLog(@"APNSManager：接收到‘长连接’设备（ID = %@）推送消息（pushType = %d， pushTime = %ld，pushUrl = %@）", devId, pushType, pushTime, pushUrl);
}


#pragma mark - UNUserNotificationCenterDelegate
// 应用处于前台时（iOS 10.0 以后）
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0))
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    GosLog(@"APNSManager：willPresentNotification - 接收到推送通知：%@", userInfo);
    
    // 音效控制
    if ([[self getCurrentVC] isKindOfClass:[MessageListViewController class]])   // 正在显示消息列表页面
    {
        // 非编辑模式（编辑模式下回缓存消息，不更新列表）
        if (NO == [GOS_GET_OBJ(GOS_PUSHMSG_LIST_IS_EDITING) boolValue])
        {
            [PushMsgManager playInserMsgSound];
        }
    }
    else if ([[self getCurrentVC] isKindOfClass:[MsgDetailViewController class]])    // 正在显示消息详情页面
    {
        [PushMsgManager playInserMsgSound];
    }
    else    // 其他页面
    {
        AudioServicesPlayAlertSoundWithCompletion(1007, ^{
            
        });
    }
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) // Remote Notification
    {
        GosLog(@"APNSManager：willPresentNotification - 接收到‘Remote’推送通知！");
        [self handleRemoteNotification:userInfo isClick:NO];
    }
    else    // Local Notification
    {
        GosLog(@"APNSManager：willPresentNotification - 接收到‘Local’推送通知！");
    }
}

// 点击推送打开 APP 时（iOS 10.0 以后）
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0))
{
    NSDictionary * userInfo = response.notification.request.content.userInfo;    // 推送通知
    GosLog(@"APNSManager：didReceiveNotificationResponse - 接收到推送通知：%@", userInfo);
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) // Remote Notification
    {
        GosLog(@"APNSManager：didReceiveNotificationResponse - 接收到‘Remote’推送通知！");
        [self handleRemoteNotification:userInfo isClick:YES];
    }
    else    // Local Notification
    {
        GosLog(@"APNSManager：didReceiveNotificationResponse - 接收到‘Local’推送通知！");
    }
    completionHandler();  // 系统要求执行这个方法
}

@end
