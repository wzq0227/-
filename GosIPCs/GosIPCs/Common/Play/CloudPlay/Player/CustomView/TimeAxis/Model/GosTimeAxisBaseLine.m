//  GosTimeAxisBaseLine.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisBaseLine.h"

@implementation GosTimeAxisBaseLine
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor {
    [visitor visitTimeAxisBaseLine:self];
}

- (NSDictionary *)drawAttributes {
    if (!_drawAttributes) {
        _drawAttributes = [NSDictionary dictionary];
    }
    return _drawAttributes;
}
@end
