//  MineHeaderView.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineHeaderView.h"
#import "Masonry.h"
#import "UIColor+GosColor.h"
#import "GosLoggedInUserInfo.h"

@interface MineHeaderView ()
/// 头像
@property (nonatomic, strong) UIButton *portraitButton;
/// 号码
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation MineHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:self.infoLabel];
        [self addSubview:self.portraitButton];
        
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-54);
        }];
        
        [self.portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.infoLabel.mas_top).offset(-10);
            make.height.mas_equalTo(64);
            make.width.mas_equalTo(64);
        }];
        
        self.layer.contents = (__bridge id)GOS_IMAGE(@"img_background").CGImage;
    }
    return self;
}

#pragma mark - getters and setters
- (UIButton *)portraitButton {
    if (!_portraitButton) {
        _portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitButton setImage:[UIImage imageNamed:@"icon_portrait_default"] forState:UIControlStateNormal];
    }
    return _portraitButton;
}
- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = GOS_FONT(14);
        _infoLabel.text = [GosLoggedInUserInfo account];
    }
    return _infoLabel;
}
@end
