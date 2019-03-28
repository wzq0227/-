//  PlaybackBaseControl.m
//  Goscom
//
//  Create by daniel.hu on 2019/2/13.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlaybackBaseControl.h"
#import "UIButton+PlayerBaseControlButtonHelper.h"

@implementation PlaybackBaseControl
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 静音，默认静音，选择打开声音
        [self.leftButton muteStateConfiguration];
        // 裁剪
        [self.centerButton cutStateConfiguration];
        // 抓图
        [self.rightButton snapshotStateConfiguration];
        
        // 检测静音按钮的选择状态
        [self.leftButton addObserver:self
                          forKeyPath:@"selected"
                             options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                             context:nil];
    }
    return self;
}

- (void)dealloc {
    [self.leftButton removeObserver:self forKeyPath:@"selected"];
    GosLog(@"--------------- PlaybackBaseControl dealloc -------------------");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        // 选择状态没有改变时、不执行下去
        if ([change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]])
            return ;
        
        // 此判断是根据选择状态的图片来决定，即muteStateConfiguration的UIControlStateSelected
        if (self.leftButton.isSelected) {
            // 高亮与无效是开启声音
            [self.leftButton soundDisableAndHighlightedConfiguration];
        } else {
            // 高亮与无效是关闭声音
            [self.leftButton muteDisableAndHighlightedConfiguration];
        }
    }
}

@end
