//  CheckNetworkFootView.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import "CheckNetworkFootView.h"
#import "UIView+GosGradient.h"
@interface CheckNetworkFootView()
{
    BOOL m_isConfigGradient;
}

@end

@implementation CheckNetworkFootView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.addAgainBtn.layer.cornerRadius = 20.0f;
    self.addAgainBtn.clipsToBounds = YES;
    [self.addAgainBtn setTitle:self.isLoginAgain?DPLocalizedString(@"NetcheckReloadLogin"):DPLocalizedString(@"NetcheckReloadAdd") forState:UIControlStateNormal];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:DPLocalizedString(@"Mine_AdviceFeedback")];
    NSRange titleRange = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
    [self.feedBackInfoBtn setAttributedTitle:title forState:UIControlStateNormal];
    self.feedBackInfoBtn.titleLabel.textColor = GOS_WHITE_COLOR;
    [self initParam];
    //    [self addGradient];
}
- (void)initParam
{
    m_isConfigGradient = NO;
}
#pragma mark - 添加渐变
- (void)addGradient{
    [self gradientStartColor:GOS_COLOR_RGB(0x7EB7F7)
                    endColor:GOS_COLOR_RGB(0x84BFF7)
                cornerRadius:0
                   direction:GosGradientTopToBottom];
}
- (void)setCheckNetState:(checkNetState)checkNetState{
    _checkNetState = checkNetState;
    switch (checkNetState) {
        case checkNetState_Success:{
            self.feedBackInfoBtn.hidden = YES;
            [self.addAgainBtn setTitle:DPLocalizedString(@"NetcheckReloadAdd") forState:UIControlStateNormal];
        }break;
        case checkNetState_Fail:{
            [self.addAgainBtn setTitle:DPLocalizedString(@"NetcheckReload") forState:UIControlStateNormal];
            self.feedBackInfoBtn.hidden = NO;
        }break;
            
        default:
            break;
    }
}
#pragma mark - actionFunction
- (IBAction)actionBtnClick:(UIButton *)sender {
    switch (sender.tag) {
        case 10:{       // 重新检测 重新添加
            
        }break;
        case 11:{       //  信息反馈
            
        }break;
            
        default:
            break;
    }
}

#pragma mark - lifeStyle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"CheckNetworkFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}
@end
