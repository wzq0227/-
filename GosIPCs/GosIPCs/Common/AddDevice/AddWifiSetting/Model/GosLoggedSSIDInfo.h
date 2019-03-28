//
//  GosLoggedSSIDInfo.h
//  Goscom
//
//  Created by 罗乐 on 2018/12/8.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosLoggedSSIDInfo : NSObject
+ (NSString *)SSID;
+ (NSString *)SSIDPassword;
+ (void)saveSSID:(NSString *)SSIDStr;
+ (void)saveSSIDPassword:(NSString *)passwordStr;
+ (void)clearSSID;
+ (void)clearPassword;
@end

NS_ASSUME_NONNULL_END
