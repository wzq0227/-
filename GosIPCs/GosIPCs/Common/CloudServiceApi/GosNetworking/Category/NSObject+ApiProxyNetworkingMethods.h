//  NSObject+ApiProxyNetworkingMethods.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ApiProxyNetworkingMethods)
/// 得到期望类型的值，如果不是就设置为defaultData
- (id)gos_defaultValue:(id)defaultData;
/// 是否为空对象，或集合为空
- (BOOL)gos_isEmptyObject;
@end

NS_ASSUME_NONNULL_END
