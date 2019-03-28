//
//  GosDB.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/11/25.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "GosDB.h"
#import "FMDB.h"


/*
 ------------------------------------ t_GoscomUser (用户表) ------------------------------------
 ______________________________________________________________________
 |    序号    |   账号(邮箱、手机)    |   密码    |    QQ 号   |   微信号   |
 |-----------|---------------------|----------|------------|-----------|
 |  integer  |        string       |  string  |   string   |  string   |
 |-----------|---------------------|----------|------------|-----------|
 | SerialNum |        Account      | Password |     QQ     |   WeChat  |
 |-----------|---------------------|----------|------------|-----------|
 |    001    |   12345678@qq.com   |  123456  | 1234567890 | weixin001 |
 |-----------|---------------------|----------|------------|-----------|
 
 */


/*
 ------------------------------------ t_GoscomDevice (设备表) ------------------------------------
 ___________________________________________________________________________________________________________________________________________
 |     序号   | 账号(邮箱、手机)  |       设备ID       |  取流名称   |     取流密码     |     昵称    | 所属域id |   设备类型   |  拥有者标识  | 在线状态 |
 |-----------|-----------------|-------------------|------------|----------------|------------|---------|------------|------------|---------|
 |  integer  |      string     |       string      |   string   |      string    |   string   | string  |  integer   |  integer   | integer |
 |-----------|-----------------|-------------------|------------|----------------|------------|---------|------------|------------|---------|
 | SerialNum |     Account     |     DeviceId      | StreamUser | StreamPassword | DeviceName | AreaId  | DeviceType | DeviceOwer |  Status |
 |-----------|-----------------|-------------------|------------|----------------|------------|---------|------------|------------|---------|
 |    001    | 12345678@qq.com | T21B******AY4111A |   admin    |   goscam123    |  bedroom   |  10009  |      1     |     1      |    1    |
 |-----------|-----------------|-------------------|------------|----------------|------------|---------|------------|------------|---------|
 
 */


/*
 ------------------------------------ t_GoscomMessage (推送信息表) ------------------------------------
 ____________________________________________________________________________________________________________________________
 |    序号    | 账号(邮箱、手机)  | 服务器区域  |      设备ID       |      推送路径    |       推送时间        | 推送类型  |   已读标识  |
 |-----------|-----------------|-----------|-------------------|-----------------|---------------------|----------|-----------|
 |  integer  |      string     |  integer  |       string      |      string     |       string        | integer  |  integer  |
 |-----------|-----------------|-----------|-------------------|-----------------|---------------------|----------|-----------|
 | SerialNum |     Account     | SAreaType |     DeviceId      |      PushUrl    |      PushTime       | PMsgType | ReadState |
 |-----------|-----------------|-----------|-------------------|-----------------|---------------------|----------|-----------|
 |    001    | 12345678@qq.com |     0     | T21B******AY4111  | http://push.com | 2018-11-26 16:28:36 |    pir   |     0     |
 |-----------|-----------------|-----------|-------------------|-----------------|---------------------|----------|-----------|
 
 */


/*
 ------------------------------------ t_GoscomDevAbility (设备能力集信息表) ------------------------------------
 ___________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
 |    序号    |      设备ID       | 云台控制 |   扬声器     |  麦克风  |   麦克风开关   |    摄像头开关    |    状态指示灯   |     运动检测      |    声音侦测     | PIR 侦测 |    温度探测   |      夜视       |  照明灯  |     SD 卡槽    |   电量显示   | 中继器和路由之间信号 | 摄像头取流密码 | Alexa 功能 | 支持摇篮曲设备系列 | 支持IOT-传感器类型 |
 |-----------|------------------|---------|------------|---------|--------------|-----------------|---------------|-----------------|----------------|---------|--------------|----------------|---------|---------------|------------|------------------|--------------|-----------|
 |  integer  |      string      | integer |  integer   | integer |   integer    |     integer     |    integer    |     integer     |     integer    | integer |    integer   |     integer    | integer |    integer    |   integer  |       integer    |    integer   |  integer  | integer | integer |
 |-----------|------------------|---------|------------|---------|--------------|-----------------|---------------|-----------------|----------------|---------|--------------|----------------|---------|---------------|------------|------------------|--------------|-----------|
 | SerialNum |     DeviceId     |  hasPTZ | hasSpeaker |  hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect |  hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery |    hasNetSignal  | hasStreamPwd |  hasAlexa | lullabyDevType | iotSensorType |
 |-----------|------------------|---------|------------|---------|--------------|-----------------|---------------|-----------------|----------------|---------|--------------|----------------|---------|---------------|------------|------------------|--------------|-----------|
 |    001    | T21B******AY4111 |    1    |     1      |    1    |       1      |        1        |       1       |         1       |        1       |     1   |       1      |        1       |    1    |        1      |       1    |          1       |       1      |     1     |         1         | 30 |
 |-----------|------------------|---------|------------|---------|--------------|-----------------|---------------|-----------------|----------------|---------|--------------|----------------|---------|---------------|------------|------------------|--------------|-----------|
 
 */


@interface GosDB()
/** 用户表 */
@property (nonatomic, readwrite, copy) NSString *userTable;
/** 设备表 */
@property (nonatomic, readwrite, copy) NSString *deviceTable;
/** 信息表 */
@property (nonatomic, readwrite, copy) NSString *messageTable;
/** 能力集表 */
@property (nonatomic, readwrite, copy) NSString *abilityTable;
/** 数据库操作队列 */
@property (nonatomic, readwrite, strong) FMDatabaseQueue *databaseQueue;
@end

// 数据库
static NSString * const kGosDataBase  = @"GoscomData.sqlite";
// 用户表： | SerialNum | Account | Password | QQ | WeChat |
static NSString * const kUserTable    =  @"t_GoscomUser";
// 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
static NSString * const kDeviceTable  =  @"t_GoscomDevice";
// 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
static NSString * const kMessageTable =  @"t_GoscomMessage";
// 设备能力集表： | SerialNum | DeviceId | hasPTZ | hasSpeaker | hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect | hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery | hasNetSignal | hasStreamPwd | hasAlexa | lullabyDevType | iotSensorType |
static NSString * const kAbilityTable = @"t_GoscomDevAbility";


@implementation GosDB

+ (instancetype)sharedGosDB
{
    static GosDB *g_gosDB = nil;
    static dispatch_once_t onceToken;
    if(!g_gosDB)
    {
        dispatch_once(&onceToken,^{
            
            g_gosDB = [[GosDB alloc] init];
        });
    }
    return g_gosDB;
}

#pragma mark -- 关闭数据库
+ (void)closeDB
{
    [[self sharedGosDB] closeDB];
}

#pragma mark - Public Method
#pragma mark -- 设备管理：增
+ (BOOL)addDevice:(DevDataModel *)device
        toAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        return NO;
    }
    return [[GosDB sharedGosDB] addDevice:device toAccount:account];
}

#pragma mark -- 设备管理：删
+ (BOOL)delDevice:(DevDataModel *)device
      fromAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        return NO;
    }
    return [[GosDB sharedGosDB] delDevice:device fromAccount:account];
}

#pragma mark -- 设备管理：改
+ (BOOL)updateDevice:(DevDataModel *)device
           onAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        return NO;
    }
    return [[GosDB sharedGosDB] updateDevice:device onAccount:account];
}

#pragma mark -- 设备管理：查
+ (NSArray<DevDataModel *>*)deviceListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        return nil;
    }
    return [[GosDB sharedGosDB] deviceListOfAccount:account];
}


#pragma mark - 推送消息管理
#pragma mark -- 增
+ (BOOL)addPushMsg:(PushMessage *)pushMsg
         toAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法添加推送消息到数据库，pushMsg = nil or account = nil");
        return NO;
    }
    return [[GosDB sharedGosDB] addPushMsg:pushMsg toAccount:account];
}

#pragma mark -- 删
+ (BOOL)delPushMsg:(PushMessage *)pushMsg
       fromAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库删除送消息，pushMsg = nil or account = nil");
        return NO;
    }
    return [[GosDB sharedGosDB] delPushMsg:pushMsg fromAccount:account];
}

#pragma mark -- 删除指定设备所有推送消息
+ (BOOL)delAllPushMsgOfDevice:(NSString *)deviceId
                  fromAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(deviceId) || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库删除某一设备所有送消息，deviceId = nil or account = nil");
        return NO;
    }
    return [[GosDB sharedGosDB] delAllPushMsgOfDevice:deviceId
                                          fromAccount:account];
}

#pragma mark -- 修改推送消息数据
+ (BOOL)updatePushMsg:(PushMessage *)pushMsg
            onAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法修改数据库中推送消息，device = nil or account = nil");
        return NO;
    }
    return [[GosDB sharedGosDB] updatePushMsg:pushMsg
                                    onAccount:account];
}

#pragma mark -- 获取推送消息列表
+ (NSArray<PushMessage *>*)pushMsgListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库获取推送消息列表，account = nil");
        return nil;
    }
    return [[GosDB sharedGosDB] pushMsgListOfAccount:account];
}

#pragma mark -- 获取指定设备的推送消息列表
+ (NSArray<PushMessage *>*)pushMsgListWithDevice:(NSString *)deviceId
                                       ofAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(deviceId) || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库获取指定设备推送消息列表，deviceId = nil or account = nil");
        return nil;
    }
    return [[GosDB sharedGosDB] pushMsgListWithDevice:deviceId
                                            ofAccount:account];
}

#pragma mark - 能力集管理
#pragma mark -- 添加设备能力集
+ (BOOL)addDevAbility:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"无法添加设备（ID - %@）能力集（ability = %@）到数据库！", ability.DeviceId, ability);
        return NO;
    }
    return [[GosDB sharedGosDB] addDevAbility:ability];
}

#pragma mark --删除设备能力集
+ (BOOL)delDevAbility:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"无法从数据库删除设备（ID - %@）能力集（ability = %@）！", ability.DeviceId, ability);
        return NO;
    }
    return [[GosDB sharedGosDB] delDevAbility:ability];
}

#pragma mark --获取设备能力集
+ (AbilityModel *)abilityOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"无法从数据库获取指定设备（ID = %@）的能力集数据！", deviceId);
        return nil;
    }
    return [[GosDB sharedGosDB] abilityOfDevice:deviceId];
}

#pragma mark -- 获取账号所有设备能力集列表
+ (NSArray<AbilityModel*>*)abilityListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        GosLog(@"无法获取账号（account = %@）所有设备能力集列表！", account);
        return nil;
    }
    return [[GosDB sharedGosDB] abilityListOfAccount:account];
}


#pragma mark - Private Method
- (instancetype)init
{
    if (self = [super init])
    {
        self.userTable     = kUserTable;
        self.deviceTable   = kDeviceTable;
        self.messageTable  = kMessageTable;
        self.abilityTable  = kAbilityTable;
        NSString *docPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) lastObject];
        NSString *fileName = [docPath stringByAppendingPathComponent:kGosDataBase];
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:fileName];
        
        [self initUserTable];
        [self initDeviceTable];
        [self initMessageTable];
        [self initAbilityTable];
    }
    return self;
}


#pragma mark - 初始化表
#pragma mark -- 判断表是否存在
- (BOOL)isExistTable:(NSString *)tableName
{
    if (IS_EMPTY_STRING(tableName))
    {
        GosLog(@"无法查询表示法存在，tableName = nil");
        return NO;
    }
    NSString *checkExistTableSql = [NSString stringWithFormat:@"select count(*) as countNum from sqlite_master where type = 'table' and name = '%@'", tableName];
    __block BOOL isExist = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:checkExistTableSql];
        while ([resultSet next])
        {
            NSInteger count = [resultSet intForColumn:@"countNum"];
            if (0 == count)
            {
                isExist = NO;
            }
            else
            {
                isExist = YES;
            }
            [resultSet close];
            return ;
        }
    }];
    
    return isExist;
}


#pragma mark -- 创建表
- (BOOL)createTableWithSql:(NSString *)createTableSql
{
    if (IS_EMPTY_STRING(createTableSql))
    {
        GosLog(@"无法创建数据表，tableName = nil");
        return NO;
    }
    __block BOOL isCreateSuccess = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:createTableSql];
        if (YES == result)
        {
            GosLog(@"创建表成功!");
            isCreateSuccess = YES;
            return ;
        }
        GosLog(@"创建表失败！");
    }];
    return isCreateSuccess;
}


#pragma mark -- 初始化用户表
- (BOOL)initUserTable
{
    if (YES == [self isExistTable:self.userTable])
    {
        return YES;
    }
//    |  integer  |        string       |  string  |   string   |  string   |
//    |-----------|---------------------|----------|------------|-----------|
//    | SerialNum |        Account      | Password |     QQ     |   WeChat  |
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (SerialNum INTEGER PRIMARY KEY AUTOINCREMENT, Account TEXT NOT NULL, password TEXT NOT NULL, QQ TEXT, WeChat TEXT);", self.userTable];
    
    return [self createTableWithSql:createTableSql];
}


#pragma mark -- 初始化设备表
- (BOOL)initDeviceTable
{
    if (YES == [self isExistTable:self.deviceTable])
    {
        return YES;
    }
//    |  integer  |      string     |       string      |   string   |      string    |   string   | string  |  integer   |  integer   |  integer |
//    |-----------|-----------------|-------------------|------------|----------------|------------|---------|------------|------------|----------|
//    | SerialNum |     Account     |     DeviceId      | StreamUser | StreamPassword | DeviceName | AreaId  | DeviceType | DeviceOwer |  Status  |
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (SerialNum INTEGER PRIMARY KEY AUTOINCREMENT, Account TEXT NOT NULL, DeviceId TEXT NOT NULL, StreamUser TEXT, StreamPassword TEXT, DeviceName TEXT, AreaId TEXT, DeviceType INTEGER, DeviceOwer INTEGER, Status INTEGER);", self.deviceTable];
    
    return [self createTableWithSql:createTableSql];
}


#pragma mark -- 初始化推送信息表
- (BOOL)initMessageTable
{
    if (YES == [self isExistTable:self.messageTable])
    {
        return YES;
    }
//    |  integer  |      string     | integer  |       string      |      string     |       string        | integer  |  integer  |
//    |-----------|-----------------|----------|-------------------|-----------------|---------------------|----------|-----------|
//    | SerialNum |     Account     | SAreaType |     DeviceId      |      PushUrl    |      PushTime       | PMsgType | ReadState |
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (SerialNum INTEGER PRIMARY KEY AUTOINCREMENT, Account TEXT NOT NULL, SAreaType INTEGER, DeviceId TEXT NOT NULL, PushUrl TEXT, PushTime TEXT, PMsgType INTEGER, ReadState INTEGER);", self.messageTable];
    
    return [self createTableWithSql:createTableSql];
}

#pragma mark -- 初始化设备能力集表
- (BOOL)initAbilityTable
{
    if (YES == [self isExistTable:self.abilityTable])
    {
        return YES;
    }
//    |  integer  |      string      | integer |  integer   | integer |   integer    |     integer     |    integer    |     integer     |     integer    | integer |    integer   |     integer    | integer |    integer    |   integer  |       integer    |    integer   |  integer  | integer | integer |
//    |-----------|------------------|---------|------------|---------|--------------|-----------------|---------------|-----------------|----------------|---------|--------------|----------------|---------|---------------|------------|------------------|--------------|-----------|
//    | SerialNum |     DeviceId     |  hasPTZ | hasSpeaker |  hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect |  hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery |    hasNetSignal  | hasStreamPwd |  hasAlexa | lullabyDevType | iotSensorType |
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (SerialNum INTEGER PRIMARY KEY AUTOINCREMENT, DeviceId TEXT NOT NULL, hasPTZ INTEGER, hasSpeaker INTEGER, hasMic INTEGER, hasMicSwitch INTEGER, hasCameraSwitch INTEGER, hasStatusLamp INTEGER, hasMotionDetect INTEGER, hasVoiceDetect INTEGER, hasPIR INTEGER, hasTemDetect INTEGER, hasNightVision INTEGER, hasLamp INTEGER, hasSdCardSlot INTEGER, hasBattery INTEGER, hasNetSignal INTEGER, hasStreamPwd INTEGER, hasAlexa INTEGER, lullabyDevType INTEGER, iotSensorType INTEGER);", self.abilityTable];
    
    return [self createTableWithSql:createTableSql];
}

#pragma mark -- 关闭数据库
-(void)closeDB
{
    GosLog(@"关闭数据库！");
    if ([self.databaseQueue openFlags])
    {
        [self.databaseQueue close];
    }
}

#pragma mark - 用户管理


#pragma mark - 设备管理
- (BOOL)addDevice:(DevDataModel *)device
        toAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法添加设备到数据库，device = nil or account = nil");
        return NO;
    }
    __block BOOL isInsert = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevice WHERE Account = %@ AND DeviceId = %@", account, device.DeviceId];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (YES == isExist)
        {
            GosLog(@"数据库已存在该设备，deviceId = %@", device.DeviceId);
            isInsert = YES;
            return ;
        }
        BOOL successflag = [db executeUpdateWithFormat:@"INSERT INTO t_GoscomDevice (Account, DeviceId, StreamUser, StreamPassword, DeviceName,  AreaId, DeviceType, DeviceOwer, Status) VALUES (%@, %@, %@, %@, %@, %@, %ld, %ld, %ld)", account, device.DeviceId, device.StreamUser, device.StreamPassword, device.DeviceName, device.AreaId, (long)device.DeviceType, (long)device.DeviceOwner, (long)device.Status];
        if (NO == successflag)
        {
            GosLog(@"添加设备到数据库失败，deviceId = %@", device.DeviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"添加设备到数据库成功，deviceId = %@", device.DeviceId);
            isInsert = YES;
        }
    }];
    return isInsert;
}

- (BOOL)delDevice:(DevDataModel *)device
      fromAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库删除设备，device = nil or account = nil");
        return NO;
    }
    __block BOOL isDelete = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevice WHERE Account = %@ AND DeviceId = %@", account, device.DeviceId];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (NO == isExist)
        {
            isDelete = YES;
            return ;
        }
        BOOL successflag = [db executeUpdateWithFormat:@"DELETE FROM t_GoscomDevice WHERE Account = %@ AND DeviceId = %@", account, device.DeviceId];
        if (!successflag)
        {
            GosLog(@"从数据库删除设备失败，deviceId = %@", device.DeviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"从数据库删除设备成功，deviceId = %@", device.DeviceId);
            isDelete = YES;
        }
    }];
    return isDelete;
}

- (BOOL)updateDevice:(DevDataModel *)device
           onAccount:(NSString *)account
{
    if (!device || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法修改数据库中设备信息，device = nil");
        return NO;
    }
    __block BOOL isUpdate = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevice WHERE Account = %@ AND DeviceId = %@", account, device.DeviceId];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (YES == isExist)
        {
            BOOL successflag = [db executeUpdateWithFormat:@"UPDATE t_GoscomDevice SET StreamUser = %@, StreamPassword = %@, DeviceName = %@, AreaId = %@, DeviceType = %ld, DeviceOwer = %ld, Status = %ld WHERE Account = %@ AND DeviceId = %@", device.StreamUser, device.StreamPassword, device.DeviceName, device.AreaId, (long)device.DeviceType, (long)device.DeviceOwner, (long)device.Status, account, device.DeviceId];
            if (NO == successflag)
            {
                GosLog(@"修改数据库中设备信息失败，deviceId = %@", device.DeviceId);
                *rollback = YES;
            }
            else
            {
                GosLog(@"修改数据库中设备信息成功，deviceId = %@", device.DeviceId);
                isUpdate = YES;
            }
        }
        else
        {
            GosLog(@"数据库中不存在该设备，无法修改信息，deviceId = %@", device.DeviceId);
        }
    }];
    return isUpdate;
}


#pragma mark -- 获取设备列表
- (NSMutableArray<DevDataModel *>*)deviceListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库获取设备列表，account = nil");
        return nil;
    }
    __block NSMutableArray <DevDataModel *>*devArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevice WHERE Account = %@", account];
        while (resultSet.next)
        {
            DevDataModel *tempModel  = [[DevDataModel alloc] init];
            tempModel.DeviceId       = [resultSet stringForColumn:@"DeviceId"];
            tempModel.DeviceName     = [resultSet stringForColumn:@"DeviceName"];
            tempModel.StreamUser     = [resultSet stringForColumn:@"StreamUser"];
            tempModel.StreamPassword = [resultSet stringForColumn:@"StreamPassword"];
            tempModel.AreaId         = [resultSet stringForColumn:@"AreaId"];
            tempModel.DeviceType     = [resultSet intForColumn:@"DeviceType"];
            tempModel.DeviceOwner    = [resultSet intForColumn:@"DeviceOwer"];
            tempModel.Status         = [resultSet intForColumn:@"Status"];
            [devArray addObject:tempModel];
        }
        [resultSet close];
    }];
    return devArray;
}


#pragma mark - 推送消息管理
- (BOOL)addPushMsg:(PushMessage *)pushMsg
         toAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法添加推送消息到数据库，pushMsg = nil or account = nil");
        return NO;
    }
    __block BOOL isInsert = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        BOOL successflag = [db executeUpdateWithFormat:@"INSERT INTO t_GoscomMessage (Account, DeviceId, PushUrl, PushTime, PMsgType,  ReadState) VALUES (%@, %@, %@, %@, %ld, %d)", account, pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime, (long)pushMsg.pmsgType, pushMsg.hasReaded];
        if (NO == successflag)
        {
            GosLog(@"添加推送消息到数据库失败，deviceId = %@", pushMsg.deviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"添加推送消息到数据库成功，deviceId = %@，pushUrl = %@, pushTime = %@, pushType = %ld, hasReaded = %d", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime, (long)pushMsg.pmsgType, pushMsg.hasReaded);
            isInsert = YES;
        }
    }];
    return isInsert;
}

- (BOOL)delPushMsg:(PushMessage *)pushMsg
       fromAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库删除送消息，pushMsg = nil or account = nil");
        return NO;
    }
    __block BOOL isDelete = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomMessage WHERE Account = %@ AND DeviceId = %@ AND PushUrl = %@ AND PushTime = %@", account, pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (NO == isExist)
        {
            isDelete = YES;
            return ;
        }
        BOOL successflag = [db executeUpdateWithFormat:@"DELETE FROM t_GoscomMessage WHERE Account = %@ AND DeviceId = %@ AND PushUrl = %@ AND PushTime = %@", account, pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime];
        if (!successflag)
        {
            GosLog(@"从数据库删除推送消息失败，deviceId = %@, pushUrl = %@, pushTimer = %@", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime);
            *rollback = YES;
        }
        else
        {
            GosLog(@"从数据库删除推送消息成功，deviceId = %@, pushUrl = %@, pushTimer = %@", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime);
            isDelete = YES;
        }
    }];
    return isDelete;
}

- (BOOL)delAllPushMsgOfDevice:(NSString *)deviceId
                  fromAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(deviceId) || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库删除某一设备所有送消息，deviceId = nil or account = nil");
        return NO;
    }
    __block BOOL isDelete = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomMessage WHERE Account = %@ AND DeviceId = %@", account, deviceId];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (NO == isExist)
        {
            isDelete = YES;
            return ;
        }
        BOOL successflag = [db executeUpdateWithFormat:@"DELETE FROM t_GoscomMessage WHERE Account = %@ AND DeviceId = %@", account, deviceId];
        if (!successflag)
        {
            GosLog(@"从数据库删某一设备（ID = %@）所有除推送消息失败！", deviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"从数据库删某一设备（ID = %@）所有除推送消息成功！", deviceId);
            isDelete = YES;
        }
    }];
    return isDelete;
}

- (BOOL)updatePushMsg:(PushMessage *)pushMsg
            onAccount:(NSString *)account
{
    if (!pushMsg || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法修改数据库中推送消息，device = nil or account = nil");
        return NO;
    }
    __block BOOL isUpdate = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomMessage WHERE Account = %@ AND DeviceId = %@ AND PushUrl = %@ AND PushTime = %@", account, pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (YES == isExist)
        {
            BOOL successflag = [db executeUpdateWithFormat:@"UPDATE t_GoscomMessage SET ReadState = %d WHERE Account = %@ AND DeviceId = %@ AND PushUrl = %@ AND PushTime = %@", pushMsg.hasReaded, account, pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime];
            if (NO == successflag)
            {
                GosLog(@"修改数据库中推送消息失败，deviceId = %@, pushUrl = %@, pushTimer = %@", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime);
                *rollback = YES;
            }
            else
            {
                GosLog(@"修改数据库中推送消息成功，deviceId = %@, pushUrl = %@, pushTimer = %@", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime);
                isUpdate = YES;
            }
        }
        else
        {
            GosLog(@"数据库中不存在该推送消息，无法修改，deviceId = %@, pushUrl = %@, pushTimer = %@", pushMsg.deviceId, pushMsg.pushUrl, pushMsg.pushTime);
        }
    }];
    return isUpdate;
}

- (NSArray<PushMessage *>*)pushMsgListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库获取推送消息列表，account = nil");
        return nil;
    }
    __block NSMutableArray <PushMessage *>*pushMsgArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomMessage, t_GoscomDevice WHERE t_GoscomMessage.DeviceId = t_GoscomDevice.DeviceId AND t_GoscomMessage.Account = %@ ORDER BY PushTime DESC", account];    // 按时间逆序
        while (resultSet.next)
        {
            @autoreleasepool
            {
                PushMessage *tempModel = [[PushMessage alloc]init];
                tempModel.serialNum    = [resultSet intForColumn:@"serialNum"];
                tempModel.account      = [resultSet stringForColumn:@"Account"];
                tempModel.deviceId     = [resultSet stringForColumn:@"DeviceId"];
                tempModel.deviceName   = [resultSet stringForColumn:@"DeviceName"];
                tempModel.pushUrl      = [resultSet stringForColumn:@"PushUrl"];
                tempModel.pushTime     = [resultSet stringForColumn:@"PushTime"];
                tempModel.hasReaded    = [resultSet boolForColumn:@"ReadState"];
                tempModel.pmsgType     = [resultSet intForColumn:@"PMsgType"];
                [pushMsgArray addObject:tempModel];
            }
        }
        [resultSet close];
    }];
    return [pushMsgArray mutableCopy];
}

- (NSArray<PushMessage *>*)pushMsgListWithDevice:(NSString *)deviceId
                                       ofAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(deviceId) || IS_EMPTY_STRING(account))
    {
        GosLog(@"无法从数据库获取指定设备推送消息列表，deviceId = nil or account = nil");
        return nil;
    }
    __block NSMutableArray <PushMessage *>*pushMsgArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 推送消息表：| SerialNum | Account | SAreaType | DeviceId | PushUrl | PushTime | PMsgType | ReadState |
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomMessage, t_GoscomDevice WHERE t_GoscomMessage.DeviceId = t_GoscomDevice.DeviceId AND t_GoscomDevice.Account = %@ AND t_GoscomMessage.DeviceId = %@ ORDER BY PushTime DESC", account, deviceId];    // 按时间逆序
        while (resultSet.next)
        {
            @autoreleasepool
            {
                PushMessage *tempModel = [[PushMessage alloc] init];
                tempModel.serialNum    = [resultSet intForColumn:@"serialNum"];
                tempModel.account      = [resultSet stringForColumn:@"Account"];
                tempModel.deviceId     = [resultSet stringForColumn:@"DeviceId"];
                tempModel.deviceName   = [resultSet stringForColumn:@"DeviceName"];
                tempModel.pushUrl      = [resultSet stringForColumn:@"PushUrl"];
                tempModel.pushTime     = [resultSet stringForColumn:@"PushTime"];
                tempModel.hasReaded    = [resultSet boolForColumn:@"ReadState"];
                tempModel.pmsgType     = [resultSet intForColumn:@"PMsgType"];
                [pushMsgArray addObject:tempModel];
            }
        }
        [resultSet close];
    }];
    return [pushMsgArray mutableCopy];
}

#pragma mark - 能力集管理
#pragma mark -- 添加设备能力集
- (BOOL)addDevAbility:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"无法添加设备（ID - %@）能力集（ability = %@）到数据库！", ability.DeviceId, ability);
        return NO;
    }
    __block BOOL isInsert = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备能力集表： | SerialNum | DeviceId | hasPTZ | hasSpeaker | hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect | hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery | hasNetSignal | hasStreamPwd | hasAlexa | lullabyDevType | iotSensorType |
        BOOL successflag = [db executeUpdateWithFormat:@"INSERT INTO t_GoscomDevAbility (DeviceId, hasPTZ, hasSpeaker, hasMic, hasMicSwitch, hasCameraSwitch, hasStatusLamp, hasMotionDetect, hasVoiceDetect, hasPIR, hasTemDetect, hasNightVision, hasLamp, hasSdCardSlot, hasBattery, hasNetSignal, hasStreamPwd, hasAlexa, lullabyDevType, iotSensorType) VALUES (%@, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %ld, %ld)", ability.DeviceId, ability.hasPTZ, ability.hasSpeaker, ability.hasMic, ability.hasMicSwitch, ability.hasCameraSwitch, ability.hasStatusLamp, ability.hasMotionDetect, ability.hasVoiceDetect, ability.hasPIR, ability.hasTemDetect, ability.hasNightVision, ability.hasLamp, ability.hasSdCardSlot, ability.hasBattery, ability.hasNetSignal, ability.hasStreamPwd, ability.hasAlexa, (long)ability.lullabyDevType, (long)ability.iotSensorType];
        if (NO == successflag)
        {
            GosLog(@"添加设备（ID = %@）能力集到数据库失败！", ability.DeviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"添加设备（ID = %@）能力集到数据库成功！", ability.DeviceId);
            isInsert = YES;
        }
    }];
    return isInsert;
}

#pragma mark --删除设备能力集
- (BOOL)delDevAbility:(AbilityModel *)ability
{
    if (!ability || IS_EMPTY_STRING(ability.DeviceId))
    {
        GosLog(@"无法从数据库删除设备（ID - %@）能力集（ability = %@）！", ability.DeviceId, ability);
        return NO;
    }
    __block BOOL isDelete = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
        // 设备能力集表： | SerialNum | DeviceId | hasPTZ | hasSpeaker | hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect | hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery | hasNetSignal | hasStreamPwd | hasAlexa | lullabyDevType | iotSensorType |
        BOOL isExist = NO;
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevAbility WHERE DeviceId = %@", ability.DeviceId];
        while ([resultSet next])
        {
            isExist = YES;
            break;
        }
        [resultSet close];
        
        if (NO == isExist)
        {
            isDelete = YES;
            return ;
        }
        BOOL successflag = [db executeUpdateWithFormat:@"DELETE FROM t_GoscomDevAbility WHERE DeviceId = %@", ability.DeviceId];
        if (!successflag)
        {
            GosLog(@"从数据库删设备（ID = %@）能力集数据失败！", ability.DeviceId);
            *rollback = YES;
        }
        else
        {
            GosLog(@"从数据库删设备（ID = %@）能力集数据成功！", ability.DeviceId);
            isDelete = YES;
        }
    }];
    return isDelete;
}

#pragma mark --获取设备能力集
- (AbilityModel *)abilityOfDevice:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        GosLog(@"无法从数据库获取指定设备（ID = %@）的能力集数据！", deviceId);
        return nil;
    }
    __block AbilityModel *retAbility = [[AbilityModel alloc] init];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备能力集表： | SerialNum | DeviceId | hasPTZ | hasSpeaker | hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect | hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery | hasNetSignal | hasStreamPwd | hasAlexa | lullabyDevType | iotSensorType |
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevAbility WHERE DeviceId = %@", deviceId];
        while (resultSet.next)
        {
            retAbility.DeviceId         = [deviceId copy];
            retAbility.hasPTZ           = [resultSet boolForColumn:@"ReadState"];
            retAbility.hasSpeaker       = [resultSet boolForColumn:@"hasSpeaker"];
            retAbility.hasMic           = [resultSet boolForColumn:@"hasMic"];
            retAbility.hasMicSwitch     = [resultSet boolForColumn:@"hasMicSwitch"];
            retAbility.hasCameraSwitch  = [resultSet boolForColumn:@"hasCameraSwitch"];
            retAbility.hasStatusLamp    = [resultSet boolForColumn:@"hasStatusLamp"];
            retAbility.hasMotionDetect  = [resultSet boolForColumn:@"hasMotionDetect"];
            retAbility.hasVoiceDetect   = [resultSet boolForColumn:@"hasVoiceDetect"];
            retAbility.hasPIR           = [resultSet boolForColumn:@"hasPIR"];
            retAbility.hasTemDetect     = [resultSet boolForColumn:@"hasTemDetect"];
            retAbility.hasNightVision   = [resultSet boolForColumn:@"hasNightVision"];
            retAbility.hasLamp          = [resultSet boolForColumn:@"hasLamp"];
            retAbility.hasSdCardSlot    = [resultSet boolForColumn:@"hasSdCardSlot"];
            retAbility.hasBattery       = [resultSet boolForColumn:@"hasBattery"];
            retAbility.hasNetSignal     = [resultSet boolForColumn:@"hasNetSignal"];
            retAbility.hasStreamPwd     = [resultSet boolForColumn:@"hasStreamPwd"];
            retAbility.hasAlexa         = [resultSet boolForColumn:@"hasAlexa"];
            retAbility.lullabyDevType   = [resultSet longForColumn:@"lullabyDevType"];
            retAbility.iotSensorType    = [resultSet longForColumn:@"iotSensorType"];
        }
        [resultSet close];
    }];
    return retAbility;
}

#pragma mark -- 获取账号所有设备能力集
- (NSArray<AbilityModel*>*)abilityListOfAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        GosLog(@"无法获取账号（account = %@）所有设备能力集列表！", account);
        return nil;
    }
    __block NSMutableArray <AbilityModel *>*abilityArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 设备表：| SerialNum | Account | DeviceId | StreamUser | StreamPassword | DeviceName | AreaId | DeviceType | DeviceOwer | Status |
        // 设备能力集表： | SerialNum | DeviceId | hasPTZ | hasSpeaker | hasMic | hasMicSwitch | hasCameraSwitch | hasStatusLamp | hasMotionDetect | hasVoiceDetect | hasPIR | hasTemDetect | hasNightVision | hasLamp | hasSdCardSlot | hasBattery | hasNetSignal | hasStreamPwd | hasAlexa | lullabyDevType | iotSensorType |
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM t_GoscomDevAbility, t_GoscomDevice WHERE t_GoscomDevAbility.DeviceId = t_GoscomDevice.DeviceId AND t_GoscomDevice.Account = %@", account];
        while (resultSet.next)
        {
            @autoreleasepool
            {
                AbilityModel *abModel    = [[AbilityModel alloc] init];
                abModel.DeviceId         = [resultSet stringForColumn:@"DeviceId"];
                abModel.hasPTZ           = [resultSet boolForColumn:@"hasPTZ"];
                abModel.hasSpeaker       = [resultSet boolForColumn:@"hasSpeaker"];
                abModel.hasMic           = [resultSet boolForColumn:@"hasMic"];
                abModel.hasMicSwitch     = [resultSet boolForColumn:@"hasMicSwitch"];
                abModel.hasCameraSwitch  = [resultSet boolForColumn:@"hasCameraSwitch"];
                abModel.hasStatusLamp    = [resultSet boolForColumn:@"hasStatusLamp"];
                abModel.hasMotionDetect  = [resultSet boolForColumn:@"hasMotionDetect"];
                abModel.hasVoiceDetect   = [resultSet boolForColumn:@"hasVoiceDetect"];
                abModel.hasPIR           = [resultSet boolForColumn:@"hasPIR"];
                abModel.hasTemDetect     = [resultSet boolForColumn:@"hasTemDetect"];
                abModel.hasNightVision   = [resultSet boolForColumn:@"hasNightVision"];
                abModel.hasLamp          = [resultSet boolForColumn:@"hasLamp"];
                abModel.hasSdCardSlot    = [resultSet boolForColumn:@"hasSdCardSlot"];
                abModel.hasBattery       = [resultSet boolForColumn:@"hasBattery"];
                abModel.hasNetSignal     = [resultSet boolForColumn:@"hasNetSignal"];
                abModel.hasStreamPwd     = [resultSet boolForColumn:@"hasStreamPwd"];
                abModel.hasAlexa         = [resultSet boolForColumn:@"hasAlexa"];
                abModel.lullabyDevType   = [resultSet longForColumn:@"lullabyDevType"];
                abModel.iotSensorType    = [resultSet longForColumn:@"iotSensorType"];
                [abilityArray addObject:abModel];
            }
        }
        [resultSet close];
    }];
    return [abilityArray mutableCopy];
}

@end
