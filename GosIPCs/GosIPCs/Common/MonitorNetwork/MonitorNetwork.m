//
//  MonitorNetwork.m
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/12.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "MonitorNetwork.h"
#import "YYReachability.h"

@interface MonitorNetwork()

@property (nonatomic, readwrite, strong) YYReachability *reachAbility;
@property (nonatomic, readwrite, assign, getter=hasStart) BOOL start;
@end

@implementation MonitorNetwork

+ (instancetype)shareMonitor
{
    static MonitorNetwork *s_monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == s_monitor)
        {
            s_monitor = [[MonitorNetwork alloc] init];
        }
    });
    return s_monitor;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.start = NO;
    }
    return self;
}

#pragma mark - Public
#pragma mark -- 开启网络监控
+ (void)startMonitor
{
    return [[self shareMonitor] startMonitor];
}

#pragma mark -- 获取当前网络状态
+ (CurNetworkStatus)currentStatus
{
    return [[self shareMonitor] currentStatus];
}

#pragma mark - Private
#pragma mark -- 开启网络监控
- (void)startMonitor
{
    if (YES == self.hasStart)
    {
        GosLog(@"已经开启了网络监控，无需再次开启！");
        return;
    }
    self.start        = YES;
    self.reachAbility = [YYReachability reachability];
    self.reachAbility.notifyBlock = ^(YYReachability * _Nonnull reachability)
    {
        CurNetworkStatus curStatus = CurNetwork_unknow;
        switch (reachability.status)
        {
            case YYReachabilityStatusNone:
            {
                GosLog(@"监测到当前网络状态为：未知");
                curStatus = CurNetwork_unknow;
            }
                break;
                
            case YYReachabilityStatusWiFi:
            {
                GosLog(@"监测到当前网络状态为：WiFi 连接");
                curStatus = CurNetwork_wifi;
            }
                break;
                
            case YYReachabilityStatusWWAN:
            {
                switch (reachability.wwanStatus)
                {
                    case YYReachabilityWWANStatusNone:
                    {
                        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 未知");
                        curStatus = CurNetwork_unknow;
                    }
                        break;
                        
                    case YYReachabilityWWANStatus2G:
                    {
                        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 2G");
                        curStatus = CurNetwork_2G;
                    }
                        break;
                        
                    case YYReachabilityWWANStatus3G:
                    {
                        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 3G");
                        curStatus = CurNetwork_3G;
                    }
                        break;
                        
                    case YYReachabilityWWANStatus4G:
                    {
                        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 4G");
                        curStatus = CurNetwork_4G;
                    }
                        break;
                }
            }
                break;
        }
        NSDictionary *dict = @{
                               @"CurNetworkStatus" : @(curStatus)
                               };
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurNetworkChangeNotify
                                                            object:dict];
    };
}

#pragma mark -- 获取当前网络状态
- (CurNetworkStatus)currentStatus
{
    CurNetworkStatus curStatus = CurNetwork_unknow;
    switch (self.reachAbility.status)
    {
        case YYReachabilityStatusNone:
        {
            GosLog(@"当前网络状态为：未知");
            curStatus = CurNetwork_unknow;
        }
            break;
            
        case YYReachabilityStatusWiFi:
        {
            GosLog(@"当前网络状态为：WiFi 连接");
            curStatus = CurNetwork_wifi;
        }
            break;
            
        case YYReachabilityStatusWWAN:
        {
            switch (self.reachAbility.wwanStatus)
            {
                case YYReachabilityWWANStatusNone:
                {
                    GosLog(@"当前网络状态为：蜂窝数据连接 - 未知");
                    curStatus = CurNetwork_unknow;
                }
                    break;
                    
                case YYReachabilityWWANStatus2G:
                {
                    GosLog(@"当前网络状态为：蜂窝数据连接 - 2G");
                    curStatus = CurNetwork_2G;
                }
                    break;
                    
                case YYReachabilityWWANStatus3G:
                {
                    GosLog(@"当前网络状态为：蜂窝数据连接 - 3G");
                    curStatus = CurNetwork_3G;
                }
                    break;
                    
                case YYReachabilityWWANStatus4G:
                {
                    GosLog(@"当前网络状态为：蜂窝数据连接 - 4G");
                    curStatus = CurNetwork_4G;
                }
                    break;
            }
        }
            break;
    }
    return curStatus;
}

@end
