//
//  AlertTipsView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AlertTipsView.h"
#import "KKAlertView.h"
#import "UIImage+GIF.h"

@interface AlertTipsView()
{
    /// 是否选中
    BOOL m_isSelect;
}
@end

@implementation AlertTipsView

- (IBAction)actionCancelClick:(UIButton *)sender {
    // 如果是添加设备
    if (m_isSelect) {
        GOS_SAVE_OBJ(@(m_isSelect), self.isAddDevice?kNoRemindAddNotify:kNoRemindWiFiNotify);
    }
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"qr_scan" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.topGifImg.image = [UIImage animatedGIFWithData:imageData];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.tipsLab.text = DPLocalizedString(@"ADDDevice_Qrcode_tip");
    self.tipsLab.adjustsFontSizeToFitWidth = YES;
    [self.confirmBtn setTitle:DPLocalizedString(@"GosComm_Confirm") forState:UIControlStateNormal];
    self.notRemindLabel.text = DPLocalizedString(@"Qrcode_notRemind");
}

- (void)initParams{
    m_isSelect = NO;
}

/// 不再提醒点击
- (IBAction)actionSelectClick:(UIButton *)sender {
    m_isSelect =! m_isSelect;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender setImage:m_isSelect?[UIImage imageNamed:@"icon_check_round_rectangle"]:[UIImage imageNamed:@"icon_uncheck_round_rectangle"] forState:UIControlStateNormal];
    });
}



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AlertTipsView" owner:self options:nil] lastObject];
    [self initParams];
    if (self) {
        self.frame = CGRectMake(0, 0, GOS_SCREEN_W - 50, ((float)(GOS_SCREEN_W + 50))/33.0f*30.0f);
    }
    return self;
}

@end
