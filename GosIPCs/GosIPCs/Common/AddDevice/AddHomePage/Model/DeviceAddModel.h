//
//  DeviceAddModel.h
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSmartDefine.h"
#import "iOSConfigSDKDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceAddModel : NSObject

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, strong) NSString *devName;

@property (nonatomic, strong) NSArray<NSNumber *> *addStyleList;

@property (nonatomic, assign) DeviceType devType;

@property (nonatomic, assign) DevBindStatus bStatus;

@property (nonatomic, strong) NSString *account;

@property (nonatomic, strong) NSString *wifiName;

@property (nonatomic, strong) NSString *wifiPWD;

@property (nonatomic, assign) BOOL isHaveForceBind; //是否支持硬解绑

@end

NS_ASSUME_NONNULL_END
