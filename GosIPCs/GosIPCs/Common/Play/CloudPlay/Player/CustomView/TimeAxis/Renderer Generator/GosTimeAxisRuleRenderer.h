//  GosTimeAxisRuleRenderer.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisRenderer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 渲染类
 在context上绘制
 */
@interface GosTimeAxisRuleRenderer : GosTimeAxisRenderer

/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis;
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData;
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule;
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments;
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground;
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine;
@end

NS_ASSUME_NONNULL_END
