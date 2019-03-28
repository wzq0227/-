//  GosTimeAxisView.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisView.h"
#import "GosTimeAxisData.h"
#import "GosTimeAxisRenderer.h"

@implementation GosTimeAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 必须设置一种颜色，不然drawRect:绘制的图像会重叠
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.layer.contents = (__bridge id)[UIImage imageNamed:@"img_ruler"].CGImage;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        
        [self setRenderer:[[GosTimeAxisRenderer alloc] initWithSize:frame.size]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // 渲染的Visitor
    self.renderer.viewSize = rect.size;
    self.renderer.context = UIGraphicsGetCurrentContext();
    self.renderer.rendererView = self;
    
    // 先绘制UI
    for (id<GosTimeAxisModel> axis in _appearanceArray) {
        [axis acceptVisitor:_renderer];
    }
    
    // 再绘制段数据
    for (id<GosTimeAxisModel> axis in _dataArray) {
        [axis acceptVisitor:_renderer];
    }
}

@end
