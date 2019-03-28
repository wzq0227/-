//  PlayerBaseControl.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/2/20.
//  Copyright © 2019年 goscam. All rights reserved.

#import "PlayerBaseControl.h"

static CGFloat s_leadingWidth;        //  适配小屏手机声音按钮和拍照按钮距离边框距离

@implementation PlayerBaseControl

+ (void)load {
    s_leadingWidth      = GOS_SCREEN_W == 320?18:38;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.leftButton];
        [self addSubview:self.centerButton];
        [self addSubview:self.rightButton];
        
        // 中间按钮
        [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mas_top).offset(59);
            make.height.mas_equalTo(100);
            make.width.mas_equalTo(100);
        }];
        // 左边按钮
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.centerButton.mas_left).offset(-s_leadingWidth);
            make.centerY.mas_equalTo(self.centerButton.mas_centerY);
            make.height.mas_equalTo(80);
            make.width.mas_equalTo(80);
        }];
        // 右边按钮
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.centerButton.mas_right).offset(s_leadingWidth);
            make.centerY.mas_equalTo(self.centerButton.mas_centerY);
            make.height.mas_equalTo(80);
            make.width.mas_equalTo(80);
        }];
        
    }
    return self;
}


#pragma mark - getters and setters
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _rightButton;
}

- (UIButton *)centerButton {
    if (!_centerButton) {
        _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _centerButton;
}

@end
