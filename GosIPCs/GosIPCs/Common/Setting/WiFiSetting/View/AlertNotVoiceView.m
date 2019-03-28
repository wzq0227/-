//
//  AlertNotVoiceView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AlertNotVoiceView.h"
#import "KKAlertView.h"

@interface AlertNotVoiceView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab1;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab2;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab3;
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab4;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation AlertNotVoiceView
- (IBAction)actionComfirmClick:(UIButton *)sender {
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configUI];
}
- (void)configUI{
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    self.titleLab.text = DPLocalizedString(@"Qrcode_tipsTitle");
    self.tips1Lab1.text = DPLocalizedString(@"Qrcode_textView");
    //    self.tips1Lab2.text = DPLocalizedString(@"");
    //    self.tips1Lab3.text = DPLocalizedString(@"");
    //    self.tips1Lab4.text = DPLocalizedString(@"");
    [self.sureBtn setTitle:DPLocalizedString(@"GosComm_Confirm") forState:UIControlStateNormal];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AlertNotVoiceView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, (GOS_SCREEN_W - 50)>290?290:(GOS_SCREEN_W - 50), ((GOS_SCREEN_W - 50)/29.0f*26.0f) > 265?265:((GOS_SCREEN_W - 50)/29.0f*26.0f));
    }
    return self;
}
@end
