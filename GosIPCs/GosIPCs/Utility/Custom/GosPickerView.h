//
//  GosPickerView.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* 选择器状态枚举 */
typedef NS_ENUM(NSInteger, GosPickerViewStatus) {
    GosPickerViewIsBeingHidden       = 0,    // 正在隐藏
    GosPickerViewIsBeingAnimation    = 1,    // 显示/隐藏动画过程中
    GosPickerViewIsBeingShow         = 2,    // 正在显示
};

/* 选择器结果返回代理 */
@protocol GosPickerViewDelegate <NSObject>

/* 选择结果返回 */
- (void)didSelectRow:(NSInteger)row
         inComponent:(NSInteger)component;

/* 选择器状态返回 */
- (void)pickerViewStatus:(GosPickerViewStatus)status;
@end

@interface GosPickerView : UIView
@property (nonatomic, readwrite, weak) id<GosPickerViewDelegate> delegate;

/* 顶部标题栏背景色（Default：WhiteColor） */
@property (nonatomic, readwrite, strong) UIColor *topViewBGColor;
/* 选择器背景色（Default：#F7F7F7） */
@property (nonatomic, readwrite, strong) UIColor *pickerViewBGColor;
/* 选择器分割线（Default：grayColor） */
@property (nonatomic, readwrite, strong) UIColor *separateLineColor;
/* 是否显示分割线（Default：YES） */
@property (nonatomic, readwrite, assign) BOOL isShowSeparateLine;
/* 选择器标题 */
@property (nonatomic, readwrite, copy) NSString *pvTitle;
/* 左按钮标题 */
@property (nonatomic, readwrite, copy) NSString *leftBtnTitle;
/* 右按钮标题 */
@property (nonatomic, readwrite, copy) NSString *rightBtnTitle;
/* 行高 */
@property (nonatomic, readwrite, assign) NSUInteger rowHeight;


/**
 设置选择器数据
 */
- (void)configWithDatas:(NSArray<NSArray*> *)pickerDatas;

/**
 设置默认选择行和组

 @param row 行
 @param component 组
 */
- (void) configDefaultSelectRow:(NSInteger) row inComponent:(NSInteger) component;

/**
 显示选择器
 */
- (void)show;

/**
 隐藏选择器
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
