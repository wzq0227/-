//
//  GosHUDView.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

/*
 全屏提示 HUD 提示语 View，3s 自动消失
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosHUDView : UIView

/**
 显示成功提示语
 
 @param status 提示语
 */
+ (void)showSuccessWithStatus:(NSString *)status;

/**
 显示失败提示语
 
 @param status 提示语
 */
+ (void)showErrorWithStatus:(NSString *)status;

@end

NS_ASSUME_NONNULL_END
