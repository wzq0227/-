//  GosTargetURLSchemes.h
//  GosPaymentSDK
//
//  Create by daniel.hu on 2018/12/13.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosTargetURLSchemes : NSObject
- (NSString *_Nullable)gos_alipayScheme:(NSDictionary *)params;
- (NSString *_Nullable)gos_wechatScheme:(NSDictionary *)params;
- (NSString *_Nullable)gos_paypalScheme:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
