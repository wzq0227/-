//  GosTimeAxisBackground.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GosTimeAxisBackground : NSObject <GosTimeAxisModel>
/// 绘制的属性，参考GosAttributeNameKey
@property (nonatomic, copy) NSDictionary *drawAttributes;

/// 通用访问方法
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor;
@end

NS_ASSUME_NONNULL_END
