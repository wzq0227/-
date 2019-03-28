//  SceneTaskModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SceneTaskModel : IotSensorModel
/// 是否选中
@property (nonatomic, readwrite,assign,getter=isSelect) BOOL select;

@end

NS_ASSUME_NONNULL_END
