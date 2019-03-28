//  GosTimeAxisView.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

@protocol GosTimeAxisModel;
@class GosTimeAxisRenderer;
@class GosTimeAxisData;

NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxisView : UIView
/// 外观数组
@property (nonatomic, copy) NSArray<id<GosTimeAxisModel>> *appearanceArray;
/// 数据数组
@property (nonatomic, copy) NSArray<GosTimeAxisData *> *dataArray;
/// 渲染类
@property (nonatomic, weak) GosTimeAxisRenderer *renderer;

@end

NS_ASSUME_NONNULL_END
