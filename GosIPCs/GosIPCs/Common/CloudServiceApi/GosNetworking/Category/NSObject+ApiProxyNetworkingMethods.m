//  NSObject+ApiProxyNetworkingMethods.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "NSObject+ApiProxyNetworkingMethods.h"

@implementation NSObject (ApiProxyNetworkingMethods)

- (id)gos_defaultValue:(id)defaultData {
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    if ([self gos_isEmptyObject]) {
        return defaultData;
    }
    return self;
}

- (BOOL)gos_isEmptyObject {
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    return NO;
}
@end
