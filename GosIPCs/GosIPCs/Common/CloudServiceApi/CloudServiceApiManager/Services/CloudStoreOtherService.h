//  CloudStoreOtherService.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/25.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 构造如下url
 http://cn-css.ulifecam.com/api/cloudstore/cloudstore-service/...
 
 http://css.ulifecam.com/api/cloudstore/cloudstore-service/...
 
 @attention params与url分离
 */
@interface CloudStoreOtherService : NSObject <GosServiceProtocol>

@end

NS_ASSUME_NONNULL_END
