//
//  ExtractDevIdInfo.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "ExtractDevIdInfo.h"

@implementation ExtractDevIdInfo

+ (GosPIDAreaType)areaTypeOfDevId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return GosPIDArea_unknown;
    }
    NSString *areaStr = [deviceId substringWithRange:NSMakeRange(0, 1)];
    
    GosPIDAreaType areaType = [self convertToIntWithString:areaStr];
    
    return areaType;
}

+ (GosPIDAgentType)agentTypeOfDevId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return GosPIDAgent_unknown;
    }
    NSString *agentStr = [deviceId substringWithRange:NSMakeRange(1, 2)];
    
    GosPIDAgentType agentType = [self convertToIntWithString:agentStr];
    
    return agentType;
}

+ (GosPIDDevType)deviceTypeOfDevId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return GosDEV_unknown;
    }
    NSString *devTypeStr = [deviceId substringWithRange:NSMakeRange(3, 2)];
    
    GosPIDDevType deviceType = [self convertToIntWithString:devTypeStr];
    
    return deviceType;
}

+ (GosPIDMediaServerType)mediaServerTypeOfDevId:(NSString *)deviceId
{
    if (IS_EMPTY_STRING(deviceId))
    {
        return GosPIDMediaS_unknown;
    }
    NSString *mediaServerStr = [deviceId substringWithRange:NSMakeRange(5, 1)];
    
    GosPIDMediaServerType mediaServerType = [self convertToIntWithString:mediaServerStr];
    
    return mediaServerType;
}

#pragma mark -- 字符串转 ASCII 码
+ (NSInteger)convertToIntWithString:(NSString *)string
{
    if(!string || 0 == string.length)
    {
        return 0;
    }
    char *p_ch       = (char *)string.UTF8String;
    NSInteger result = 0;;
    int i            = 0;
    while(*p_ch)
    {
        result = (result << (i * 8)) + (int)*p_ch;
        i++;
        p_ch++;
    }
    return result;
}

@end
