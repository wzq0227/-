//  GosTargetURLSchemes.m
//  GosPaymentSDK
//
//  Create by daniel.hu on 2018/12/13.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosTargetURLSchemes.h"
#import <iOSPaymentSDK/iOSPaymentDefines.h>

@implementation GosTargetURLSchemes
- (NSString *_Nullable)gos_alipayScheme:(NSDictionary *)params {
    NSArray *types = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *dict in types) {
        if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:GOS_SCHEME_URL_IDENTIFIER_ALIPAY]) {
            PayLog(@"%s alipay scheme: %@", __PRETTY_FUNCTION__, [dict objectForKey:@"CFBundleURLSchemes"]);
            return [[dict objectForKey:@"CFBundleURLSchemes"] firstObject];
        }
    }
    PayLog(@"%s alipay scheme is nil", __PRETTY_FUNCTION__);
    return nil;
}
- (NSString *_Nullable)gos_wechatScheme:(NSDictionary *)params {NSArray *types = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *dict in types) {
        if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:GOS_SCHEME_URL_IDENTIFIER_WECHAT]) {
            PayLog(@"%s wechat scheme: %@", __PRETTY_FUNCTION__, [dict objectForKey:@"CFBundleURLSchemes"]);
            return [[dict objectForKey:@"CFBundleURLSchemes"] firstObject];
        }
    }
    PayLog(@"%s wechat scheme is nil", __PRETTY_FUNCTION__);
    return nil;
}
- (NSString *_Nullable)gos_paypalScheme:(NSDictionary *)params {
    NSArray *types = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *dict in types) {
        if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:GOS_SCHEME_URL_IDENTIFIER_PAYPAL]) {
            PayLog(@"%s wechat scheme: %@", __PRETTY_FUNCTION__, [dict objectForKey:@"CFBundleURLSchemes"]);
            return [[dict objectForKey:@"CFBundleURLSchemes"] firstObject];
        }
    }
    PayLog(@"%s paypal scheme is nil", __PRETTY_FUNCTION__);
    return nil;
}
@end
