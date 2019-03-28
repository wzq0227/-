//  PlayerBaseControl.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/20.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerBaseControl : UIView
/// 左边按钮
@property (nonatomic, strong) UIButton *leftButton;
/// 中间按钮
@property (nonatomic, strong) UIButton *centerButton;
/// 右边按钮
@property (nonatomic, strong) UIButton *rightButton;

@end

NS_ASSUME_NONNULL_END
