//
//  PushMsgManager.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/11.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "PushMsgManager.h"
#import "GosDB.h"
#import "PushImageManager.h"
#import "GosSoundEffectPlayer.h"


#define PUSMSG_MANA_SEMAPHORE_TIMEOUT   15  // 信号量超时时间（单位：秒）

@interface PushMsgManager()
{
    dispatch_queue_t m_dbOperationQueue;  // 数据库操作对了（串行）
    dispatch_queue_t m_playSoundQueue;  // 播放插入消息音效队列（串行）
}
@property (nonatomic, readwrite, copy) NSString *curAccount;    // 当前操作的账号
/** 插入推送消息音效 播放器 */
@property (nonatomic, readwrite, strong) GosSoundEffectPlayer *insertMsgPlayer;
@end

@implementation PushMsgManager

+ (instancetype)shareManager
{
    static PushMsgManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == s_manager)
        {
            s_manager = [[PushMsgManager alloc] init];
        }
    });
    return s_manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        m_dbOperationQueue = dispatch_queue_create("GosPushDBOperationQueue", DISPATCH_QUEUE_SERIAL);
        m_playSoundQueue   = dispatch_queue_create("GosPlayInserPushMsgSoundQueue", DISPATCH_QUEUE_SERIAL);
        NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"InsertMessage"
                                                                  ofType:@"wav"];
        NSError *error = nil;
        self.insertMsgPlayer = [[GosSoundEffectPlayer alloc] initWithFilePath:audioFilePath
                                                                        error:&error];
        if (error)
        {
            GosLog(@"插入推送消息音效播放器初始化失败：%@", error.localizedDescription);
        }
        _curAccount = [GosLoggedInUserInfo account];
        [self addLoginSuccessNotify];
    }
    return self;
}

- (void)dealloc
{
    if (_insertMsgPlayer)
    {
        [_insertMsgPlayer stop];
        _insertMsgPlayer = nil;
    }
    GosLog(@"---------- PushMsgManager dealloc ----------");
}

#pragma mark -- 添加推送消息
+ (BOOL)addPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法添加推送消息！");
        return NO;
    }
    return [[self shareManager] addPushMsg:pushMsg];
}

#pragma mark -- 删除推送消息
+ (BOOL)rmvPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法删除推送消息！");
        return NO;
    }
    return [[self shareManager] rmvPushMsg:pushMsg];
}

#pragma mark --  删除指定设备 ID 的所有推送消息
+ (void)rmvPushMsgOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"PushMsgManager：无法删除设备（ID = %@）的所有推送消息！", deviceId);
        return;
    }
    return[[self shareManager] rmvPushMsgOfDevice:deviceId];
}

#pragma mark --  修改推送消息
+ (BOOL)modifyushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法修改推送消息！");
        return NO;
    }
    return [[self shareManager] modifyushMsg:pushMsg];
}

#pragma mark -- 获取指定账号下的所有推送消息
+ (NSArray<PushMessage *>*)pushMsgList
{
    return [[self shareManager] pushMsgList];
}

#pragma mark -- 根据指定设备 ID 的所有推送
+ (NSArray <PushMessage *>*)pushMsgListOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"PushMsgManager：无法获取设备（ID = %@）的推送消息列表！", deviceId);
        return nil;
    }
    return [[self shareManager] pushMsgListOfDevice:deviceId];
}

#pragma mark -- 播放‘插入消息’音效
+ (void)playInserMsgSound
{
    [[PushMsgManager shareManager] playInserMsgSound];
}


#pragma mark - Private
- (BOOL)addPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法添加推送消息！");
        return NO;
    }
    BOOL ret = [GosDB addPushMsg:pushMsg toAccount:self.curAccount];
    if (YES == ret)
    {
        if (PushMsg_iotSensorLowBattery   == pushMsg.pmsgType
            || PushMsg_iotSensorDoorOpen  == pushMsg.pmsgType
            || PushMsg_iotSensorDoorClose == pushMsg.pmsgType
            || PushMsg_iotSensorDoorBreak == pushMsg.pmsgType
            || PushMsg_iotSensorPirAlarm  == pushMsg.pmsgType
            || PushMsg_iotSensorSosAlarm  == pushMsg.pmsgType)
        {
			GosLog(@"该推送消息是 IOT-传感器 消息，无需下载图片！");
            return ret;
        }
		GosLog(@"PushMsgManager：设备（ID = %@）推送消息成功保存到数据库，开始下图片（URL = %@）", pushMsg.deviceId, pushMsg.pushUrl);
        [PushImageManager downloadImageWithMsg:pushMsg];
    }
    return ret;
}

- (BOOL)rmvPushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法删除推送消息！");
        return NO;
    }
   BOOL ret = [GosDB delPushMsg:pushMsg fromAccount:self.curAccount];
    return ret;
}

- (void)rmvPushMsgOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"PushMsgManager：无法删除设备（ID = %@）所有推送消息！", deviceId);
        return;
    }
    [GosDB delAllPushMsgOfDevice:deviceId fromAccount:self.curAccount];
}

- (BOOL)modifyushMsg:(PushMessage *)pushMsg
{
    if (!pushMsg || IS_EMPTY_STRING(pushMsg.deviceId)
//        || IS_EMPTY_STRING(pushMsg.pushUrl)
        || IS_EMPTY_STRING(pushMsg.pushTime))
    {
        GosLog(@"PushMsgManager：无法修改推送消息！");
        return NO;
    }
    BOOL ret = [GosDB updatePushMsg:pushMsg onAccount:self.curAccount];
    return ret;
}

- (NSArray<PushMessage *>*)pushMsgList
{
    NSArray<PushMessage*>*pushMstList = [GosDB pushMsgListOfAccount:self.curAccount];
    return pushMstList;
}

- (NSArray <PushMessage *>*)pushMsgListOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"PushMsgManager：无法获取设备（ID = %@）的推送消息列表！", deviceId);
        return nil;
    }
    NSArray<PushMessage*>*pushList = [GosDB pushMsgListWithDevice:deviceId
                                                        ofAccount:self.curAccount];
    return pushList;
}

#pragma mark -- 播放‘插入消息’音效
- (void)playInserMsgSound
{
    GOS_WEAK_SELF;
    dispatch_async(m_playSoundQueue, ^{
    
        GOS_STRONG_SELF;
        [NSThread sleepForTimeInterval:0.08];
        [strongSelf.insertMsgPlayer playOnceWithVibrate];
    });
}

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
    [self setCurAccount:[GosLoggedInUserInfo account]];
}

- (void)setCurAccount:(NSString *)curAccount
{
    if (NO == [_curAccount isEqualToString:curAccount]) // 账号改变了
    {
        GosLog(@"PushMsgManager：账号变了！");
        _curAccount = [curAccount copy];
    }
}
@end
