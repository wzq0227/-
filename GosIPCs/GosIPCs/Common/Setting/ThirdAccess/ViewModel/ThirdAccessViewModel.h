//  ThirdAccessViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/7.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "ThirdAccessModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThirdAccessViewModel : NSObject

/**
 处理三方接入数据

 @param thirdPartySupport 三方接入支持
 @return 数组
 */
+ (NSArray *)initDataArrWithAbility:(AccessThirdPartySupport) thirdPartySupport;
@end

NS_ASSUME_NONNULL_END
