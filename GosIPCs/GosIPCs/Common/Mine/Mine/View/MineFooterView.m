//  MineFooterView.m
//  Goscom
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineFooterView.h"
#import "LogoutModuleCommand.h"
#import "UIView+ModuleCommandExtension.h"

@interface MineFooterView ()
/// 注销按钮
@property (nonatomic, strong) UIButton *logoutButton;
@end

@implementation MineFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.logoutButton];
        
        [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.right.mas_equalTo(self.mas_right);
            make.height.mas_equalTo(46);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}
- (void)logoutButtonDidClick:(UIButton *)sender {
    [sender.moduleCommand execute];
}

- (UIButton *)logoutButton {
    if (!_logoutButton) {
        _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_logoutButton setBackgroundColor:GOS_COLOR_RGB(0xFFFFFF)];
        [_logoutButton setTitle:DPLocalizedString(@"Mine_Logout") forState:UIControlStateNormal];
        [_logoutButton setTitleColor:GOS_COLOR_RGB(0xFF2424) forState:UIControlStateNormal];
        _logoutButton.moduleCommand = [[LogoutModuleCommand alloc] init];
        [_logoutButton addTarget:self action:@selector(logoutButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutButton;
}
@end
