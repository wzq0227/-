//  GosTimeAxisData.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisData.h"
@implementation GosTimeAxisData
- (instancetype)init {
    if (self = [super init]) {
        self.attributeStyle = GosTimeAxisDataAttributeStylePurple;
    }
    return self;
}
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor {
    [visitor visitTimeAxisData:self];
}

- (id)copyWithZone:(NSZone *)zone {
    GosTimeAxisData *axisData = [[GosTimeAxisData allocWithZone:zone] init];
    axisData.startTimeInterval = self.startTimeInterval;
    axisData.endTimeInterval = self.endTimeInterval;
    axisData.drawAttributes = self.drawAttributes;
    axisData.extraData = self.extraData;
    return axisData;
}
#pragma mark - getters and setters
- (NSTimeInterval)duration {
    return self.endTimeInterval - self.startTimeInterval;
}

- (NSDictionary *)drawAttributes {
    if (!_drawAttributes) {
        _drawAttributes = [NSDictionary dictionary];
    }
    return _drawAttributes;
}

- (void)setAttributeStyle:(GosTimeAxisDataAttributeStyle)attributeStyle {
    _attributeStyle = attributeStyle;
    switch (attributeStyle) {
            /// 紫色 0xBF96FF
        case GosTimeAxisDataAttributeStylePurple:
            self.drawAttributes = @{GosStrokeColorAttributeName:[GOS_COLOR_RGB(0xBF96FF) colorWithAlphaComponent:0.3]};
            break;
            /// 橘黄色 0xFFB973
        case GosTimeAxisDataAttributeStyleOrange:
            self.drawAttributes = @{GosStrokeColorAttributeName:[GOS_COLOR_RGB(0xFFB973) colorWithAlphaComponent:0.3]};
            break;
            /// 青绿色 0x67D4DB
        case GosTimeAxisDataAttributeStyleTurquoise:
            self.drawAttributes = @{GosStrokeColorAttributeName:[GOS_COLOR_RGB(0x67D4DB) colorWithAlphaComponent:0.3]};
            break;
            /// 粉红色 0xFF96CB
        case GosTimeAxisDataAttributeStylePinkPinkPink:
            self.drawAttributes = @{GosStrokeColorAttributeName:[GOS_COLOR_RGB(0xFF96CB) colorWithAlphaComponent:0.3]};
            break;
        default:
            break;
    }
}
@end
