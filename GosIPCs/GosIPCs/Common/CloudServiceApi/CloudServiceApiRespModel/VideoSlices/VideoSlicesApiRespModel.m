//  VideoSlicesApiRespModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "VideoSlicesApiRespModel.h"
#import "ClousServiceApiRespHelper.h"

@interface VideoSlicesApiRespModel ()
/// 由alarmType转化而来
@property (nonatomic, readwrite, assign) VideoSlicesAlarmType videoSlicesAlarmType;

@end

@implementation VideoSlicesApiRespModel

- (id)copyWithZone:(NSZone *)zone {
    VideoSlicesApiRespModel *model = [[VideoSlicesApiRespModel allocWithZone:zone] init];
    model.alarmType = self.alarmType;
    model.bucket = [self.bucket copy];
    model.cycle = [model.cycle copy];
    model.dateLife = [self.dateLife copy];
    model.endTime = [self.endTime copy];
    model.startTime = [self.startTime copy];
    model.key = [self.key copy];
    return model;
}

- (void)setAlarmType:(NSString *)alarmType {
    _alarmType = alarmType;
    
    _videoSlicesAlarmType = [ClousServiceApiRespHelper convertAlarmTypeFromString:alarmType];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    
    VideoSlicesApiRespModel *model = object;
    
    if (![model.startTime isKindOfClass:[NSString class]]) return NO;
    
    return [model.startTime isEqualToString:self.startTime];
    
}

@end
