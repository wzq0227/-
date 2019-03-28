//  GosTimeAxisGenerator.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisGenerator.h"
@implementation GosTimeAxisGenerator

/// 通用访问方法
- (void)visitTimeAxis:(id<GosTimeAxisModel>)aTimeAxis {
    // do something in subclass
}
/// 访问数据
- (void)visitTimeAxisData:(GosTimeAxisData *)aTimeAxisData {
    // do something in subclass
}
/// 访问刻度线
- (void)visitTimeAxisRule:(GosTimeAxisRule *)aTimeAxisRule {
    // do something in subclass
}
/// 访问数字与分割线
- (void)visitTimeAxisSegments:(GosTimeAxisSegments *)aTimeAxisSegments {
    // do something in subclass
}
/// 访问背景
- (void)visitTimeAxisBackground:(GosTimeAxisBackground *)aTimeAxisBackground {
    // do something in subclass
}
/// 访问基线
- (void)visitTimeAxisBaseLine:(GosTimeAxisBaseLine *)aTimeAxisBaseLine {
    // do something in subclass
}

/// 初始化
- (id<GosTimeAxisVisitor>)initWithSize:(CGSize)aSize {
    if (self = [super init]) {
        [self setViewSize:aSize];
    }
    return self;
}
@end
