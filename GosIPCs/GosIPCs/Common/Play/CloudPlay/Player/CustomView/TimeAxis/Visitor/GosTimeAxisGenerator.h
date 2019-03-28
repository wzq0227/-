//  GosTimeAxisGenerator.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisVisitor.h"
NS_ASSUME_NONNULL_BEGIN

/**
 生产数据基类
 */
@interface GosTimeAxisGenerator : NSObject <GosTimeAxisVisitor>

#pragma mark - property
@property (nonatomic, assign) CGSize viewSize;

#pragma mark - visitor method
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

/// 初始化
- (id<GosTimeAxisVisitor>)initWithSize:(CGSize)aSize;
@end

NS_ASSUME_NONNULL_END
