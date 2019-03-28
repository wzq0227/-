//  GosHUD.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 通用HUD
 统一HUD生产器
 */
@interface GosHUD : NSObject
/// 显示成功信息，会自行消失
+ (void)showProcessHUDSuccessWithStatus:(NSString *)status;
/// 显示详情信息，会自行消失
+ (void)showProcessHUDInfoWithStatus:(NSString *)status;
/// 显示错误信息，会自行消失
+ (void)showProcessHUDErrorWithStatus:(NSString *)status;
/// 显示信息，不会自行消失
+ (void)showProcessHUDWithStatus:(NSString *)status;
/// 用于菊花加载，不会自行消失
+ (void)showProcessHUDForLoading;
/// 统一消失方法
+ (void)dismiss;

/// 底部展示信息，会自行消失
+ (void)showBottomHUDWithStatus:(NSString *)status;
/// 全屏展示成功信息，会自行消失
+ (void)showScreenfulHUDSuccessWithStatus:(NSString *)status;
/// 全屏展示错误信息，会自行消失
+ (void)showScreenfulHUDErrorWithStatus:(NSString *)status;
@end

NS_ASSUME_NONNULL_END
