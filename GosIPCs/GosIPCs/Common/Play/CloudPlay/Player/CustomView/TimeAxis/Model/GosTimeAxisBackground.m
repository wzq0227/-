//  GosTimeAxisBackground.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisBackground.h"

@implementation GosTimeAxisBackground
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor {
    [visitor visitTimeAxisBackground:self];
}

- (NSDictionary *)drawAttributes {
    if (!_drawAttributes) {
        _drawAttributes = [NSDictionary dictionary];
    }
    return _drawAttributes;
}
@end
