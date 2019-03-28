//
//  GosInfoLegalCheck.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//


/*
 信息合法性检查 类
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosInfoLegalCheck : NSObject

/**
 检查账号是否合法
 
 @param accountStr 账号
 @return 是否合法；YES：是，NO：否
 */
+ (BOOL)isLegalWithAccount:(NSString *)accountStr;

/**
 检查密码是否合法
 
 @param passwordStr 账号
 @return 是否合法；YES：是，NO：否
 */
+ (BOOL)isLegalWithPassword:(NSString *)passwordStr;

@end

NS_ASSUME_NONNULL_END
