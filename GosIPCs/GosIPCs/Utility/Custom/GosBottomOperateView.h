//
//  GosBottomOperateView.h
//  GosIPCs
//
//  Created by shenyuanluo on 2019/1/3.
//  Copyright © 2019 goscam. All rights reserved.
//


/*
 自定义底部’操作视图‘，集成全选/反全选、删除功能
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol GosBottomOperateViewDelegate <NSObject>

/*
 ’左‘按钮点击事件回调
 */
- (void)leftButtonAction;

/*
 ’右‘按钮点击事件回调
 */
- (void)rightButtonAction;
@end

@interface GosBottomOperateView : UIView

+ (void)configDelegate:(id<GosBottomOperateViewDelegate>)delegate;

/*
 显示视图
 */
+ (void)show;

/*
 隐藏视图
 */
+ (void)dismiss;

/*
 设置‘左’按钮标题
 
 @param title 标题
 @param state 状态
 */
+ (void)configLeftTitle:(NSString *)title
               forState:(UIControlState)state;

/*
 设置‘左’按钮标题颜色
 
 @param color 标题颜色
 @param state 状态
 */
+ (void)configLeftTitleColor:(UIColor *)color
                    forState:(UIControlState)state;

/*
 设置‘右’按钮标题
 
 @param title 标题
 @param state 状态
 */
+ (void)configRightTitle:(NSString *)title
                forState:(UIControlState)state;

/*
 设置‘右’按钮标题颜色
 
 @param color 标题颜色
 @param state 状态
 */
+ (void)configRightTitleColor:(UIColor *)color
                     forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
