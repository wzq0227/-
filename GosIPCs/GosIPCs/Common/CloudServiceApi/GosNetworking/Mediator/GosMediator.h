//  GosMediator.h
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosMediator : NSObject
+ (instancetype)sharedInstance;
/// target must has prefix: GosTarget
/// action must has prefix: gos_
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *_Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;

@end

NS_ASSUME_NONNULL_END
