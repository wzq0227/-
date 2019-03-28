//  CheckNetResultModel.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/18.
//  Copyright © 2019 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKModel.h"
typedef NS_ENUM(NSInteger,checkNetState) {
    checkNetState_Detecting,      //    检测中
//    checkNetState_Waiting,        //    依瓢画葫芦
    checkNetState_Success,        //    网络良好
    checkNetState_Fail,           //    网络不通
};
NS_ASSUME_NONNULL_BEGIN

@interface CheckNetResultModel : ServerAddressInfo
/// 检查网络状态结果
@property (nonatomic, assign) checkNetState checkNwtstate;
/// 发送的包(模拟数据)
@property (nonatomic, assign) NSInteger sentPack;
@end

NS_ASSUME_NONNULL_END
