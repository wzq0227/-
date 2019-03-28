//  NetCheckViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/18.
//  Copyright © 2019 goscam. All rights reserved.

#import <Foundation/Foundation.h>
@class CheckNetResultModel;
@class ServerAddressInfo;
NS_ASSUME_NONNULL_BEGIN

@interface NetCheckViewModel : NSObject

/**
 处理请求到要检测的地址

 @param normalArr 原有的服务器地址数组
 @return 转换后的服务器地址数组
 */
+ (NSMutableArray <CheckNetResultModel *>*)handleTableArr:(NSArray<ServerAddressInfo*> *) normalArr;


/**
 处理检测到的结果给table数组

 @param isReachable 检测的服务器是否可用
 @param checkModel 检测的模型
 @param tableArr 转换后编辑后的数组
 */
+ (void)handleCheckState:(BOOL)isReachable
          withCheckModel:(ServerAddressInfo *) checkModel
            withTableArr:(NSMutableArray <CheckNetResultModel *>*) tableArr;



@end

NS_ASSUME_NONNULL_END
