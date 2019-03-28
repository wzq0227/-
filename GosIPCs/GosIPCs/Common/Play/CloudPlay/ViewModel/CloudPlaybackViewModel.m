//  CloudPlaybackViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/4.
//  Copyright © 2019年 goscam. All rights reserved.

#import "CloudPlaybackViewModel.h"
#import "GosDevManager.h"
#import "VideoSlicesApiRespModel.h"
#import "GosTimeAxisData.h"
#import "NSDate+GosDateExtension.h"
#import "NSString+GosFormatDate.h"
#import "PackageValidTimeApiRespModel.h"
#import "iOSConfigSDKModel.h"
#import "ClousServiceApiRespHelper.h"

@implementation CloudPlaybackViewModel

- (NSArray *)optimiseVideosModelArray:(NSArray *)videosModelArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:videosModelArray.count];
    
    [videosModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![result containsObject:obj]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray *)optimiseVideosModelArray:(NSArray *)videosModelArray other:(NSArray *)other {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:(videosModelArray.count+other.count)];
    
    [videosModelArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![result containsObject:obj]) {
            [result addObject:obj];
        }
    }];
    
    [other enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![result containsObject:obj]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}


/// 判断模型数据是否属于date为当天
- (BOOL)validateVideoSlicesRespModel:(VideoSlicesApiRespModel *)respModel
                      isBelongToDate:(NSDate *)date {
    // 非VideoSlicesApiRespModel模型数据无法比较，则反馈NO
    if (![respModel isKindOfClass:[VideoSlicesApiRespModel class]]) return NO;
    // 判断起始时间戳是否属于date当天
    return [date validateTimestampIsBelongToToday:respModel.startTime.doubleValue];
}

/// PackageValidTimeApiRespModel => NSDate模型数组
- (NSArray <NSDate *> *)convertPackageValidTimeApiRespModelToDateArray:(PackageValidTimeApiRespModel *)respModel {
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[respModel.startTime doubleValue]];
    
    NSInteger count = [respModel.serviceLife integerValue];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [result addObject:[startTime dateByAppendingDay:i]];
    }
    
    return [result copy];
}

/// RecMonthDataModel模型数组 => NSDate模型数组
- (NSArray <NSDate *> *)convertRecMonthDataModelArrayToDateArray:(NSArray <RecMonthDataModel *> *)respModelArray {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[respModelArray count]];
    
    for (RecMonthDataModel *respModel in respModelArray) {
        // dateStr 数据格式：2018/8/8
        [result addObject:[NSString dateFromString:respModel.dateStr format:slashDateFormatString]];
    }
    
    return [result copy];
}

/// 网络模型数组 => GosTimeAxisData模型数组
- (NSArray <GosTimeAxisData *> *)convertVideosModelArrayToTimeAxisDataModelArray:(NSArray *)videosModelArray {
    GosLineLog(@"daniel: count: %zd", videosModelArray.count);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:videosModelArray.count];
    
    id firstObject = [videosModelArray firstObject];
    
    if ([firstObject isKindOfClass:[VideoSlicesApiRespModel class]]) {
        for (id videoModel in videosModelArray) {
            [temp addObject:[self convertVideoSlicesRespModelToTimeAxisDataModel:videoModel]];
        }
    } else if ([firstObject isKindOfClass:[SDAlarmDataModel class]]) {
        for (id videoModel in videosModelArray) {
            [temp addObject:[self convertSDAlarmDataModelToTimeAxisDataModel:videoModel]];
        }
    }
    
    return [temp copy];
}

/// VideoSlicesApiRespModel -> GosTimeAxisData
- (GosTimeAxisData *)convertVideoSlicesRespModelToTimeAxisDataModel:(VideoSlicesApiRespModel *)respModel {
    GosTimeAxisData *model = [[GosTimeAxisData alloc] init];
    
    model.startTimeInterval = [respModel.startTime doubleValue];
    model.endTimeInterval = [respModel.endTime doubleValue];
    // 默认为gray
    model.attributeStyle = GosTimeAxisDataAttributeStylePurple;
    switch (respModel.videoSlicesAlarmType) {
        case VideoSlicesAlarmTypeUnknow:
            model.attributeStyle = GosTimeAxisDataAttributeStylePurple;
            break;
        case VideoSlicesAlarmTypeMotionDetection:
            model.attributeStyle = GosTimeAxisDataAttributeStyleOrange;
            break;
        case VideoSlicesAlarmTypeVoiceDetection:
            model.attributeStyle = GosTimeAxisDataAttributeStylePinkPinkPink;
            break;
        case VideoSlicesAlarmTypeTemperture:
            model.attributeStyle = GosTimeAxisDataAttributeStyleTurquoise;
            break;
        default:
            break;
    }
    model.extraData = respModel;
    return model;
}

/// SDAlarmDataModel -> GosTimeAxisData
- (GosTimeAxisData *)convertSDAlarmDataModelToTimeAxisDataModel:(SDAlarmDataModel *)respModel {
    GosTimeAxisData *model = [[GosTimeAxisData alloc] init];
    
    model.startTimeInterval = (NSTimeInterval)respModel.S;
    model.endTimeInterval = (NSTimeInterval)respModel.E;
    // 默认为gray
    model.attributeStyle = GosTimeAxisDataAttributeStylePurple;
    VideoSlicesAlarmType type = [ClousServiceApiRespHelper convertAlarmTypeFromString:[@(respModel.AT) stringValue]];
    switch (type) {
        case VideoSlicesAlarmTypeUnknow:
            model.attributeStyle = GosTimeAxisDataAttributeStylePurple;
            break;
        case VideoSlicesAlarmTypeMotionDetection:
            model.attributeStyle = GosTimeAxisDataAttributeStyleOrange;
            break;
        case VideoSlicesAlarmTypeVoiceDetection:
            model.attributeStyle = GosTimeAxisDataAttributeStylePinkPinkPink;
            break;
        case VideoSlicesAlarmTypeTemperture:
            model.attributeStyle = GosTimeAxisDataAttributeStyleTurquoise;
            break;
        default:
            break;
    }
    model.extraData = respModel;
    return model;
}



/// 根据设备id 获取 设备名
- (NSString *_Nullable)fetchDeviceNameFromDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId].DeviceName;
}

/// 通过设备id 获取设备模型
- (DevDataModel *)fetchDeviceDataModelWithDeviceId:(NSString *)deviceId {
    return [GosDevManager devcieWithId:deviceId];
}
@end
