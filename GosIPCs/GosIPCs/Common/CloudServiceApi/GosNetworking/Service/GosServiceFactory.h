//  GosServiceFactory.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosServiceFactory : NSObject
+ (instancetype)sharedInstance;

- (id<GosServiceProtocol>)serviceWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
