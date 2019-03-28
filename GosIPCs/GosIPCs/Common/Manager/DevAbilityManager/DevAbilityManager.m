//
//  DevAbilityManager.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/7.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "DevAbilityManager.h"
#import "GosDB.h"


#define OP_DEV_ABILITY_TIMEOUT  15   // 超时时间（单位：秒）


@interface DevAbilityManager()

@property (nonatomic, readwrite, copy) NSString *curAccount;    // 当前操作的账号
@property (nonatomic, readwrite, strong) dispatch_queue_t dbOperationQueue;  // 数据库操作对了（串行）
@property (nonatomic, readwrite, strong) GosReadWriteLock *rwLock;
@property (nonatomic, readwrite, strong) NSMutableArray<AbilityModel*> *abilityArray;

@end

@implementation DevAbilityManager

+ (instancetype)shareABManager
{
    static DevAbilityManager *abManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == abManager)
        {
            abManager = [[DevAbilityManager alloc] init];
        }
    });
    return abManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.dbOperationQueue    = dispatch_queue_create("GosDevAbilityDBOperationQueue", DISPATCH_QUEUE_SERIAL);
//        self.rwLock              = [[GosReadWriteLock alloc] init];
        self.rwLock.writeTimeout = OP_DEV_ABILITY_TIMEOUT;
        self.rwLock.readTimeout  = OP_DEV_ABILITY_TIMEOUT;
        _curAccount              = [GosLoggedInUserInfo account];
        [self addLoginSuccessNotify];
    }
    return self;
}

#pragma mark -- 添加设备能力集
+ (BOOL)addAbility:(AbilityModel *)abModel
{
    if (!abModel || IS_EMPTY_STRING(abModel.DeviceId))
    {
        GosLog(@"DevAbilityManager：无法添加设备（ID = %@）能力集！", abModel.DeviceId);
        return NO;
    }
   return [[self shareABManager] addAbility:abModel];
}

#pragma mark -- 删除设备能力集
+ (BOOL)rmvAbilityFromDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"DevAbilityManager：无法移除设备（ID = %@）能力集！", devId);
        return NO;
    }
    return [[self shareABManager] rmvAbilityFromDevice:devId];
}

#pragma mark -- 获取设备能力集
+ (AbilityModel *)abilityOfDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"DevAbilityManager：无法获取设备（ID = %@）能力集！", devId);
        return nil;
    }
    return [[self shareABManager] abilityOfDevice:devId];
}

#pragma mark -- 获取账号所有设备能力集列表
+ (NSArray<AbilityModel*>*)abilityList
{
    return [[self shareABManager] abilityList];
}


#pragma mark - Private
#pragma mark -- 添加设备能力集
- (BOOL)addAbility:(AbilityModel *)abModel
{
    if (!abModel || IS_EMPTY_STRING(abModel.DeviceId))
    {
        GosLog(@"DevAbilityManager：无法添加设备（ID = %@）能力集！", abModel.DeviceId);
        return NO;
    }
    [self.rwLock lockWrite];
    __block BOOL isExist = NO;
    [self.abilityArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(AbilityModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         if ([abModel.DeviceId isEqualToString:obj.DeviceId])
         {
             isExist = YES;
             *stop   = YES;
         }
     }];
    if (NO == isExist)
    {
        GosLog(@"DevAbilityManager：缓存设备（ID = %@）能力集成功！", abModel.DeviceId);
        [self.abilityArray addObject:abModel]; // 先缓存
        
        NSDictionary *notifyDict = @{@"DeviceID" : abModel.DeviceId};
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddAbilityNotify
                                                            object:notifyDict];
        [self addAbilityToDB:abModel]; // 再添加到数据库
    }
    else
    {
        GosLog(@"DevAbilityManager：设备（ID = %@）能力集已存在，无需添加！", abModel.DeviceId);
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 删除设备能力集
- (BOOL)rmvAbilityFromDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"DevAbilityManager：无法移除设备（ID = %@）能力集！", devId);
        return NO;
    }
    [self.rwLock lockWrite];
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    [self.abilityArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(AbilityModel * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop)
     {
         if ([devId isEqualToString:obj.DeviceId])
         {
             isExist = YES;
             index   = idx;
             *stop   = YES;
         }
     }];
    if (YES == isExist)
    {
        GosLog(@"DevAbilityManager：准备删除设备（ID = %@）能力集！", devId);
        [self delAbilityFromDB:self.abilityArray[index]];   // 先从数据库删除
        [self.abilityArray removeObjectAtIndex:index];    // 在从缓存删除
        
        NSDictionary *notifyDict = @{@"DeviceID" : devId};
        [[NSNotificationCenter defaultCenter] postNotificationName:kRmvAbilityNotify
                                                            object:notifyDict];
    }
    else
    {
        GosLog(@"DevAbilityManager：设备（ID = %@）能力集不存在，无需删除！", devId);
    }
    [self.rwLock unLockWrite];
    return YES;
}

#pragma mark -- 获取设备能力集
- (AbilityModel *)abilityOfDevice:(NSString *)devId
{
    if (IS_EMPTY_STRING(devId))
    {
        GosLog(@"DevAbilityManager：无法获取设备（ID = %@）能力集！", devId);
        return nil;
    }
    [self.rwLock lockRead];
    __block BOOL isExist     = NO;
    __block NSUInteger index = 0;
    [self.abilityArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                        usingBlock:^(AbilityModel * _Nonnull obj,
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
    AbilityModel *retABModel = nil;
    if (NO == isExist)
    {
        GosLog(@"DevAbilityManager：设备（ID = %@）不存在，无法获取能力集！", devId);
    }
    else
    {
        retABModel = self.abilityArray[index];
    }
    [self.rwLock unLockRead];
    return retABModel;
}

#pragma mark -- 获取能力集列表
- (NSArray<AbilityModel*>*)abilityList
{
    [self.rwLock lockRead];
    NSArray<AbilityModel*>*retAbList = [self.abilityArray mutableCopy];
    [self.rwLock unLockRead];
    return retAbList;
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
        GosLog(@"DevAbilityManager：账号变了！");
        [_rwLock lockWrite];
        [_abilityArray removeAllObjects];
        _abilityArray = nil;
        [_rwLock unLockWrite];
        _curAccount   = [curAccount copy];
    }
}

#pragma mark - 数据库操作中心
#pragma mark -- 插入数据库
- (void)addAbilityToDB:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"DevAbilityManager：无法添加设备（ID = %@）能力集到数据库！", ability.DeviceId);
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.dbOperationQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDB addDevAbility:ability];
    });
}


#pragma mark -- 删除
- (void)delAbilityFromDB:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"DevAbilityManager：无法添加设备（ID = %@）能力级集到数据库！", ability.DeviceId);
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(self.dbOperationQueue, ^{
        
        GOS_STRONG_SELF;
        [GosDB delDevAbility:ability];
    });
}

#pragma mark - 懒加载
- (NSMutableArray<AbilityModel *> *)abilityArray
{
    if (!_abilityArray)
    {
        _abilityArray = [NSMutableArray arrayWithArray:[GosDB abilityListOfAccount:self.curAccount]];
    }
    return _abilityArray;
}

@end
