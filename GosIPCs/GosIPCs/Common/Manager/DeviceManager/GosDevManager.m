//
//  GosDevManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/24.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "GosDevManager.h"
#import "GosDB.h"

#define DEV_MANA_SEMAPHORE_TIMEOUT   15  // 信号量超时时间（单位：秒）


static NSString * const kDeviceIdKey  = @"GosDeviceID";
static NSString * const kConnStateKey = @"GosDevConnState";

@interface GosDevManager()
{
    dispatch_queue_t m_devManagerQueue;   // 设备管理队列（串行）
    dispatch_queue_t m_dbOperationQueue;  // 数据库操作对了（串行）
}

@property (nonatomic, readwrite, copy) NSString *curAccount;    // 当前操作的账号
@property (nonatomic, readwrite, strong) NSMutableArray<DevDataModel *> *devListArray;
@property (nonatomic, readwrite, strong) GosReadWriteLock *rwLock;
@property (nonatomic, readwrite, strong) NSMutableSet<NSDictionary*>*connStateSet;

@end

@implementation GosDevManager

#pragma mark - Public Method
#pragma mark -- 添加设备数据模型
+ (BOOL)addDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法添加设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    return [[self sharedManager] addDevice:device];
}

#pragma mark -- 移除设备数据模型
+ (BOOL)delDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法删除设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    return [[self sharedManager] delDevice:device];
}

#pragma mark -- 更新设备数据模型
+ (BOOL)updateDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法更新设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    return [[self sharedManager] updateDevice:device];
}

#pragma mark -- 根据设备 ID 获取设备数据模型
+ (DevDataModel *)devcieWithId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"GosDevManager：无法获取设备（ID = %@）数据模型！", deviceId)
        return nil;
    }
    return [[self sharedManager] devcieWithId:deviceId];
}

#pragma mark -- 获取设备列表数据模型数组
+ (NSArray <DevDataModel *> *)deviceList
{
    return [[self sharedManager] deviceList];
}

#pragma mark -- 同步设备列表数据（在设备列表界面获取时，用于数据库同步）
+ (BOOL)synchDeviceList:(NSArray<DevDataModel*>*)devList
{
    if (!devList)
    {
        GosLog(@"GosDevManager：设备列表数（devList = %@)据无法同步！", devList);
        return NO;
    }
    return [[self sharedManager] synchDeviceList:devList];
}

#pragma mark -- 更新设备连接状态
+ (void)updateDevice:(NSString *)deviceId
         toConnState:(DeviceConnState)connState
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return;
    }
    [[self sharedManager] updateDevice:deviceId
                           toConnState:connState];
}

#pragma mark -- 获取设备连接状态
+ (DeviceConnState)connStateOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return DeviceConnUnConn;
    }
    return [[self sharedManager] connStateOfDevice:deviceId];
}

#pragma mark - Private Method
+ (instancetype)sharedManager
{
    static GosDevManager *g_devManager = nil;
    static dispatch_once_t token;
    if (!g_devManager)
    {
        dispatch_once(&token,^{
            g_devManager = [[GosDevManager alloc] init];
        });
    }
    return g_devManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        m_dbOperationQueue       = dispatch_queue_create("GosDevDBOperationQueue", DISPATCH_QUEUE_SERIAL);
        m_devManagerQueue        = dispatch_queue_create("GosDevManagerQueue", DISPATCH_QUEUE_SERIAL);
//        self.rwLock              = [[GosReadWriteLock alloc] init];
        self.rwLock.writeTimeout = DEV_MANA_SEMAPHORE_TIMEOUT;
        self.rwLock.readTimeout  = DEV_MANA_SEMAPHORE_TIMEOUT;
        _curAccount              = [GosLoggedInUserInfo account];
        [self addLoginSuccessNotify];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- GosDevManager dealloc ----------");
}

#pragma mark -- 添加设备
- (BOOL)addDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法添加设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    [self.rwLock lockWrite];
    __block BOOL isExist = NO;
    @autoreleasepool
    {
        
        [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                            usingBlock:^(DevDataModel * _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop)
        {
            if ([device.DeviceId isEqualToString:obj.DeviceId])
            {
                GosLog(@"GosDevManager：设备（ID = %@）已存在，无需再添加！", obj.DeviceId);
                isExist = YES;
                *stop   = YES;
            }
        }];
    }

    if (NO == isExist)
    {
        [self.devListArray addObject:device];
        [self addDeviceToDB:device];   // 加入数据库
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 删除设备
- (BOOL)delDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法添加设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    [self.rwLock lockWrite];
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    @autoreleasepool
    {
        [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                            usingBlock:^(DevDataModel * _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop)
        {
            if ([device.DeviceId isEqualToString:obj.DeviceId])
            {
                isExist = YES;
                index   = idx;
                *stop   = YES;
            }
        }];
    }
    if (YES == isExist)
    {
        [self.devListArray removeObjectAtIndex:index];
        [self delDeviceFromDB:device];     // 移除数据库数据
    }
    else
    {
        GosLog(@"GosDevManager：设备（ID = %@）不存在，无需删除！", device.DeviceId);
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 更新设备数据模型
- (BOOL)updateDevice:(DevDataModel *)device
{
    if (!device || IS_EMPTY_STRING(device.DeviceId))
    {
        GosLog(@"GosDevManager：无法更新设备（ID = %@）数据模型！", device.DeviceId)
        return NO;
    }
    [self.rwLock lockWrite];
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    @autoreleasepool
    {
        [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                            usingBlock:^(DevDataModel * _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop)
         {
             if ([device.DeviceId isEqualToString:obj.DeviceId])
             {
                 isExist = YES;
                 index   = idx;
                 *stop   = YES;
             }
         }];
    }
    if (YES == isExist)
    {
        [self.devListArray replaceObjectAtIndex:index
                                     withObject:device];
        [self updateDeviceToDB:device];   // 更新数据库
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 获取设备数据模型
- (DevDataModel *)devcieWithId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"GosDevManager：无法获取设备（ID = %@）数据模型！", deviceId)
        return nil;
    }
    [self.rwLock lockRead];
    DevDataModel *retDev     = nil;
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    @autoreleasepool
    {
        [self.devListArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                            usingBlock:^(DevDataModel * _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop)
        {
            if ([deviceId isEqualToString:obj.DeviceId])
            {
                index   = idx;
                isExist = YES;
                *stop   = YES;
            }
        }];
    }
    if (YES == isExist)
    {
        retDev = self.devListArray[index];
    }
    [self.rwLock unLockRead];
    return retDev;
}

#pragma mark -- 获取设备列表
- (NSArray<DevDataModel *>*)deviceList
{
    return [self.devListArray mutableCopy];
}

#pragma mark -- 同步设备列表到数据库
- (BOOL)synchDeviceList:(NSArray<DevDataModel *>*)devList
{
    if (!devList)
    {
        GosLog(@"GosDevManager：设备列表数（devList = %@)据无法同步！", devList);
        return NO;
    }
    NSArray<DevDataModel*>*tempList = [devList mutableCopy];
    [self.rwLock lockWrite];
    @autoreleasepool
    {
        GOS_WEAK_SELF;
        NSMutableSet<DevDataModel*> *dbSet1  = [NSMutableSet setWithArray:self.devListArray];
        NSMutableSet<DevDataModel*> *dbSet2  = [NSMutableSet setWithArray:self.devListArray];
        NSMutableSet<DevDataModel*> *curSet1 = [NSMutableSet setWithArray:tempList];
        NSMutableSet<DevDataModel*> *curSet2 = [NSMutableSet setWithArray:tempList];
        [dbSet1 minusSet:curSet1];    // 旧设备，需删除
        [dbSet1 enumerateObjectsWithOptions:NSEnumerationConcurrent
                                 usingBlock:^(DevDataModel*  _Nonnull obj, BOOL * _Nonnull stop) {
                                     
                                     GOS_STRONG_SELF;
                                     GosLog(@"GosDevManager：旧设备，需删除！");
                                     [strongSelf.devListArray removeObject:obj];
                                     [strongSelf delDeviceFromDB:obj];
                                 }];;
        [curSet1 minusSet:dbSet2];    // 新设备，需添加
        [curSet1 enumerateObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(DevDataModel*  _Nonnull obj, BOOL * _Nonnull stop) {
                                    
                                     GOS_STRONG_SELF;
                                     GosLog(@"GosDevManager：新设备，需添加！");
                                     [strongSelf.devListArray addObject:obj];
                                     [strongSelf addDeviceToDB:obj];
                                 }];
        [curSet2 minusSet:curSet1]; // 已有设备，更新缓存即可，数据库不需要更新（如需更新数据库，使用：'updateDevice:'）
        for (int i = 0; i < self.devListArray.count; i++)
        {
            [curSet2 enumerateObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(DevDataModel * _Nonnull obj,
                                                   BOOL * _Nonnull stop)
            {
                GOS_STRONG_SELF;
                if ([obj isEqual:self.devListArray[i]])
                {
                    GosLog(@"GosDevManager：更新已存在设备（ID = %@）数据！", obj.DeviceId);
                    [strongSelf.devListArray replaceObjectAtIndex:i
                                                       withObject:obj];
                    *stop = YES;
                }
            }];
        }
        [dbSet1 removeAllObjects];
        [dbSet2 removeAllObjects];
        [curSet1 removeAllObjects];
        [curSet2 removeAllObjects];
        dbSet1  = nil;
        dbSet2  = nil;
        curSet1 = nil;
        curSet2 = nil;
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 更新设备连接状态
- (void)updateDevice:(NSString *)deviceId
         toConnState:(DeviceConnState)connState
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return;
    }
    __block NSDictionary *oldDirc = nil;
    __block BOOL isExist          = NO;
    NSDictionary *newDict         = @{kDeviceIdKey : deviceId,
                                      kConnStateKey : @(connState)};
    [self.connStateSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(NSDictionary * _Nonnull obj,
                                                     BOOL * _Nonnull stop)
     {
         if (YES == [[obj allKeys] containsObject:kDeviceIdKey]
             && YES == [[obj allKeys] containsObject:kConnStateKey])
         {
             if ([deviceId isEqualToString:obj[kDeviceIdKey]])
             {
                 oldDirc = obj;
                 isExist = YES;
                 *stop   = YES;
             }
         }
     }];
    if (NO == isExist)
    {
        [self.connStateSet addObject:newDict];
    }
    else
    {
        DeviceConnState oldConnState = [oldDirc[kConnStateKey] integerValue];
        if (oldConnState != connState)  // 更新旧值
        {
            [self.connStateSet removeObject:oldDirc];
            [self.connStateSet addObject:newDict];
        }
    }
}

#pragma mark -- 获取设备连接状态
- (DeviceConnState)connStateOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return DeviceConnUnConn;
    }
    __block DeviceConnState connState = DeviceConnUnConn;
    __block BOOL isExist              = NO;
    [self.connStateSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(NSDictionary * _Nonnull obj,
                                                     BOOL * _Nonnull stop)
     {
         if (YES == [[obj allKeys] containsObject:kDeviceIdKey]
             && YES == [[obj allKeys] containsObject:kConnStateKey])
         {
             if ([deviceId isEqualToString:obj[kDeviceIdKey]])
             {
                 connState = [obj[kConnStateKey] integerValue];
                 isExist   = YES;
                 *stop     = YES;
             }
         }
     }];
    return connState;
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
    if (!curAccount)
    {
        return;
    }
    if (NO == [_curAccount isEqualToString:curAccount]) // 账号改变了
    {
        GosLog(@"GosDevManager：账号变了！");
        [_devListArray removeAllObjects];
        _devListArray = nil;
        _curAccount   = [curAccount copy];
    }
}

#pragma mark - 懒加载
- (NSMutableArray<DevDataModel *> *)devListArray
{
    if (!_devListArray)
    {
        _devListArray = [NSMutableArray arrayWithArray:[GosDB deviceListOfAccount:self.curAccount]];
    }
    return _devListArray;
}

- (NSMutableSet<NSDictionary *> *)connStateSet
{
    if (!_connStateSet)
    {
        _connStateSet = [NSMutableSet setWithCapacity:0];
    }
    return _connStateSet;
}

#pragma mark - 数据库操作中心
#pragma mark -- 插入数据库
- (void)addDeviceToDB:(DevDataModel *)device
{
    if (!device)
    {
        GosLog(@"GosDevManager：无法添加新设备，device = nil ");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(m_dbOperationQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDB addDevice:device toAccount:strongSelf.curAccount];
    });
}


#pragma mark -- 删除
- (void)delDeviceFromDB:(DevDataModel *)device
{
    if (!device)
    {
        GosLog(@"GosDevManager：无法删除设备，device = nil ");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(m_dbOperationQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDB delDevice:device fromAccount:strongSelf.curAccount];
    });
}


#pragma mark -- 修改
- (void)updateDeviceToDB:(DevDataModel *)device
{
    if (!device)
    {
        GosLog(@"GosDevManager：无法更新新设备，device = nil ");
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(m_dbOperationQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDB updateDevice:device onAccount:strongSelf.curAccount];
    });
}

@end
