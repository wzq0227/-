//  GosLoggedInUserInfo+SDKExtension.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosLoggedInUserInfo.h"
#import "iOSConfigSDKDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosLoggedInUserInfo (SDKExtension)

/**
 获取sdk服务器区域

 @return ServerAreaType
 */
+ (ServerAreaType)sdkServerArea;

/**
 获取sdk账户类型

 @returnn AccountType
 */
+ (AccountType)sdkAccountType;
@end

NS_ASSUME_NONNULL_END
