//  CloudStoreService.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 构造如下url
 http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/...
 
 http://css.ulifecam.com/api/cloudstore/cloudstore-service/...
 
 @attention params都是添加在url上的
 */
@interface CloudStoreService : NSObject <GosServiceProtocol>

@end

NS_ASSUME_NONNULL_END
