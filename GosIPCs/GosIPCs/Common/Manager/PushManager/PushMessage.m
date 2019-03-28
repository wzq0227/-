//
//  PushMessage.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/11.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "PushMessage.h"
#import <objc/runtime.h>

@implementation PushMessage

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[self class]])
    {
        return NO;
    }
    if (self == object)
    {
        return YES;
    }
    return [self isEqualToMsg:object];
}

- (BOOL)isEqualToMsg:(PushMessage *)pushMsg
{
    if (!pushMsg)
    {
        return NO;
    }
    // 特殊情况：如果两个设备 deviceId、pushUrl、pushTime 相同，则认为两个设备模型相等
    NSString *deviceId1 = [self valueForKey:@"deviceId"];
    NSString *deviceId2 = [pushMsg valueForKey:@"deviceId"];
    BOOL hasEqualId     = (!deviceId1 && !deviceId2) || [deviceId1 isEqualToString:deviceId2];
    
    NSString *pushUrl1 = [self valueForKey:@"pushUrl"];
    NSString *pushUrl2 = [pushMsg valueForKey:@"pushUrl"];
    BOOL hasEqualUrl   = (!pushUrl1 && !pushUrl2) || [pushUrl1 isEqualToString:pushUrl2];
    
    NSString *pushTime1 = [self valueForKey:@"pushTime"];
    NSString *pushTime2 = [pushMsg valueForKey:@"pushTime"];
    BOOL hasEqualTime   = (!pushTime1 && !pushTime2) || [pushTime1 isEqualToString:pushTime2];
    if (NO == hasEqualId || NO == hasEqualUrl || NO == hasEqualTime)
    {
        return NO;
    }
    
    /*
    // 一般情况：匹配所有的属性相同才认为相等
    unsigned int pCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &pCount);
    if (properties)
    {
        for (int i = 0; i < pCount; i++)
        {
            NSString *pName = @(property_getName(properties[i]));
            id value1       = [self valueForKey:pName];
            id value2       = [device valueForKey:pName];
            BOOL hasEqual   = (!value1 && !value2) || [value1 isEqual:value2];
            if (NO == hasEqual)
            {
                GosLog(@"DevDataModel.%@ is not equal", pName);
                return NO;
            }
        }
        free(properties);
    }*/
    return YES;
}

- (NSUInteger)hash
{
    return [self.deviceId hash] ^ [self.pushUrl hash] ^ [self.pushTime hash];
}

#pragma mark -- NSCoding：编码
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    GOS_RUNTIME_ENCODE(aCoder);
}

#pragma mark -- NSCoding：解码
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        GOS_RUNTIME_DECODE(aDecoder);
    }
    return self;
}

#pragma mark -- NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    id copyObj = [[[self class] allocWithZone:zone] init];
    if (copyObj)
    {
        GOS_RUNTIME_COPY(copyObj);
    }
    return copyObj;
}

#pragma mark -- NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone
{
    id muCopyObj = [[[self class] allocWithZone:zone] init];
    if (muCopyObj)
    {
        GOS_RUNTIME_MUCOPY(muCopyObj);
    }
    return muCopyObj;
}

@end
