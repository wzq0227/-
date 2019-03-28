//
//  APNSManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/12.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

/** 查询账号所有设备推送状态结果 Block 回调 */
typedef void(^QueryPushResultBlock)(BOOL isSuccess, NSArray<DevPushStatusModel *>* _Nullable sList);

@interface APNSManager : NSObject

/*
 注册 iOS 设备 APNS Remote 推送（先保存 Token，第一次登录成功后再注册）
 */
+ (void)registiOSRemoteApns;

/*
 保存注册 APNS-Remote 成功时返回的 token （先保存 Token，第一次登录成功后再注册）
 
 @param devToken iOS-APNS-Remote token
 */
+ (void)saveiOSToken:(NSData *)devToken;

/*
 打开设备推送功能
 
 @param devId 设备 ID
 @param resultBlock 请求结果回调 Block
 */
+ (void)openPushWithDevId:(NSString *)devId
                   result:(void (^) (BOOL isSuccess))resultBlock;

/*
 关闭设备推送功能
 
 @param devId 设备 ID
 @param resultBlock 请求结果回调 Block
 */
+ (void)closePushWithDevId:(NSString *)devId
                    result:(void (^) (BOOL isSuccess))resultBlock;
/*
 查询所有设备推送状态
 */
+ (void)queryAllDevPushStatus:(QueryPushResultBlock)resultBlock;

/*
 处理‘Remote’推送消息
 
 @param userInfo ‘Remote’推送消息
 @param isClick 用户是否点击b该推送消息；YES：已点击，NO：未点击
 */
+ (void)handleRemoteNotification:(NSDictionary *)userInfo
                         isClick:(BOOL)isClick;


@end

NS_ASSUME_NONNULL_END
