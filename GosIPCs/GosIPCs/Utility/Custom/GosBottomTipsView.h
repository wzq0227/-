//
//  GosBottomTipsView.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//


/*
 底部提示语 View，3s 自动消失
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GosBottomTipsView : UIView

/**
 显示提示语
 
 @param msg 提示语
 */
+ (void)showWithMessge:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
