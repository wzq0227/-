//
//  PushStatusMananger.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/19.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "PushStatusMananger.h"


#define DPS_LIST_OP_MUTEX_TIMEOUT 15 // 推送状态操作超时时间


@interface PushStatusMananger()
@property (nonatomic, readwrite, strong) NSMutableArray<DevPushStatusModel*> *dpsList;
/** 设备推送状态列表访问 锁 */
@property (nonatomic, readwrite, strong) GosReadWriteLock *devPushStatusListLock;
@property (nonatomic, readwrite, assign) BOOL hasCheckedDPS;    // 是否已查询所有设备推送状态（只查一次）
@end

@implementation PushStatusMananger

+ (instancetype)shareManager
{
    static PushStatusMananger *g_psManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == g_psManager)
        {
            g_psManager = [[PushStatusMananger alloc] init];
        }
    });
    return g_psManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.hasCheckedDPS                      = NO;
//        self.devPushStatusListLock              = [[GosReadWriteLock alloc] init];
        self.devPushStatusListLock.readTimeout  = DPS_LIST_OP_MUTEX_TIMEOUT;
        self.devPushStatusListLock.writeTimeout = DPS_LIST_OP_MUTEX_TIMEOUT;
    }
    return self;
}

#pragma mark - Public
#pragma mark -- 添加设备推送状态 Model
+ (BOOL)addPushStatusModel:(DevPushStatusModel *)dpsModel
{
    if (!dpsModel || IS_EMPTY_STRING(dpsModel.DeviceId))
    {
        GosLog(@"PushStatusMananger：无法添加设备推送状态，dpsModel = nil");
        return NO;
    }
    return [[self shareManager] addPushStatusModel:dpsModel];
}

#pragma mark -- 移除设备推送状态 Model
+ (BOOL)rmvPushStatusWithDevId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"PushStatusMananger：无法移除设备推送状态，devId = nil");
        return NO;
    }
    return [[self shareManager] rmvPushStatusWithDevId:devId];
}

#pragma mark -- 获取设备推送状态 Model
+ (DevPushStatusModel *)pushModelOfDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"PushStatusMananger：无法获取设备推送状态，devId = nil");
        return nil;
    }
    return [[self shareManager] pushModelOfDevice:devId];
}

#pragma mark -- 获取所有设备推送状态列表
+ (NSArray<DevPushStatusModel*>*)pushStatusList
{
    return [[self shareManager] pushStatusList];
}

#pragma mark -- 更新设备推送状态
+ (BOOL)updatePushStatus:(DevPushStatusModel *)dpsModel
{
    if (!dpsModel || IS_EMPTY_STRING(dpsModel.DeviceId))
    {
        GosLog(@"PushStatusMananger：无法更新设备推送状态，devId = nil");
        return NO;
    }
    return [[self shareManager] updatePushStatus:dpsModel];
}

#pragma mark -- 清空管理器（账号注销时）
+ (BOOL)cleanMananger
{
    return [[self shareManager] cleanMananger];
}

#pragma mark -- 通知已查询完成
+ (void)notifyHasChecked
{
    [PushStatusMananger shareManager].hasCheckedDPS = YES;
}

#pragma mark -- 是否已查询所有设备推送状态
+ (BOOL)hasChecked
{
    return [PushStatusMananger shareManager].hasCheckedDPS;
}


#pragma mark - 懒加载
- (NSMutableArray<DevPushStatusModel *> *)dpsList
{
    if (!_dpsList)
    {
        _dpsList = [NSMutableArray arrayWithCapacity:0];
    }
    return _dpsList;
}


#pragma mark - Private
#pragma mark -- 添加设备推送状态 Model
- (BOOL)addPushStatusModel:(DevPushStatusModel *)dpsModel
{
    if (!dpsModel || IS_EMPTY_STRING(dpsModel.DeviceId))
    {
        GosLog(@"PushStatusMananger：无法添加设备推送状态，dpsModel = nil");
        return NO;
    }
    __block BOOL isExist = NO;
    [self.devPushStatusListLock lockWrite];
    [self.dpsList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
     {
         if ([obj.DeviceId isEqualToString:dpsModel.DeviceId])
         {
             isExist = YES;
             *stop   = YES;
         }
     }];
    if (NO == isExist)
    {
        [self.dpsList addObject:dpsModel];
    }
    [self.devPushStatusListLock unLockWrite];
    return YES;
}

#pragma mark -- 移除设备推送状态 Model
- (BOOL)rmvPushStatusWithDevId:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"PushStatusMananger：无法移除设备推送状态，devId = nil");
        return NO;
    }
    __block BOOL isExist = NO;
    __block NSUInteger index = 0;
    [self.devPushStatusListLock lockWrite];
    [self.dpsList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
    {
        if ([obj.DeviceId isEqualToString:devId])
        {
            isExist = YES;
            index   = idx;
            *stop   = YES;
        }
    }];
    if (YES == isExist)
    {
        [self.dpsList removeObjectAtIndex:index];
    }
    [self.devPushStatusListLock unLockWrite];
    return YES;
}

- (DevPushStatusModel *)pushModelOfDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"PushStatusMananger：无法获取设备推送状态，devId = nil");
        return nil;
    }
    __block DevPushStatusModel *retModel = nil;
    [self.devPushStatusListLock lockRead];
    [self.dpsList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
    {
        if ([obj.DeviceId isEqualToString:devId])
        {
            retModel = [obj copy];
            *stop    = YES;
        }
    }];
    [self.devPushStatusListLock unLockRead];
    return retModel;
}

#pragma mark -- 获取所有设备推送状态列表
- (NSArray<DevPushStatusModel*>*)pushStatusList
{
    NSArray<DevPushStatusModel*>*retArray = nil;
    [self.devPushStatusListLock lockRead];
    retArray = [NSArray arrayWithArray:self.dpsList];
    [self.devPushStatusListLock unLockRead];
    return retArray;
}

#pragma mark -- 更新设备推送状态
- (BOOL)updatePushStatus:(DevPushStatusModel *)dpsModel
{
    if (!dpsModel || IS_EMPTY_STRING(dpsModel.DeviceId))
    {
        GosLog(@"PushStatusMananger：无法更新设备推送状态，devId = nil");
        return NO;
    }
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    [self.devPushStatusListLock lockWrite];
    [self.dpsList enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(DevPushStatusModel * _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop)
     {
         if ([obj.DeviceId isEqualToString:dpsModel.DeviceId])
         {
             isExist = YES;
             index   = idx;
             *stop   = YES;
         }
     }];
    if (YES == isExist)
    {
        [self.dpsList replaceObjectAtIndex:index
                                withObject:dpsModel];
        GosLog(@"PushStatusManager：更新推送状态成功！");
    }
    [self.devPushStatusListLock unLockWrite];
    return YES;
}

#pragma mark -- 清空管理器（账号注销时）
- (BOOL)cleanMananger
{
    [self.devPushStatusListLock lockWrite];
    [self.dpsList removeAllObjects];
    self.hasCheckedDPS = NO;
    [self.devPushStatusListLock unLockWrite];
    return YES;
}

@end
