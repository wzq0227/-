//  AddSensorTypeModel.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/8.
//  Copyright © 2019 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
@class IotSensorModel;

NS_ASSUME_NONNULL_BEGIN

@interface AddSensorTypeModel : NSObject
// 添加传感器类型
@property (nonatomic, assign) GosIOTType gosIOTType;
/// 组别字符串
@property (nonatomic, strong) NSString * sectionStr;
///
@property (nonatomic, strong) NSMutableArray <IotSensorModel *> * sectionArr;
@end

NS_ASSUME_NONNULL_END
