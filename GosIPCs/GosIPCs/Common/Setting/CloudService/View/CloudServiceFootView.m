//
//  CloudServiceFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "CloudServiceFootView.h"

@interface CloudServiceFootView ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *agreeTextView;

@end

@implementation CloudServiceFootView



- (void)awakeFromNib{
    [super awakeFromNib];
    [self.freeUserBtn setTitle:DPLocalizedString(@"CS_PackageType_FreeTryTitle2") forState:UIControlStateNormal];
    [self.payBtn setTitle:DPLocalizedString(@"CS_Package_Pay") forState:UIControlStateNormal];
    self.freeUserBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self configAgree];
}
- (void)configAgree{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: DPLocalizedString(@"CS_Agree_CSAgreement")];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"CSAgreementURL://"
                             range:[[attributedString string] rangeOfString:DPLocalizedString(@"CS_CSAgreement")]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attributedString.length)];
    self.agreeTextView.attributedText = attributedString;
    self.agreeTextView.backgroundColor = [UIColor clearColor];
    self.agreeTextView.editable = NO;
    self.agreeTextView.scrollEnabled = NO;
    self.agreeTextView.delegate = self;
    self.agreeTextView.textAlignment = NSTextAlignmentCenter;
    self.agreeTextView.linkTextAttributes = @{NSForegroundColorAttributeName: GOS_COLOR_RGB(0x55AFFC),
                                              NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                              NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
}
#pragma mark - 免费试用模型
- (void)setFreeApiRespModel:(FreePackageTypesApiRespModel *)freeApiRespModel{
    _freeApiRespModel = freeApiRespModel;
    if (!_freeApiRespModel) {
        self.payTopConstraint.constant = 50;
        self.freeUserBtn.hidden = YES;
    }else{
        self.payTopConstraint.constant = 140;
        self.freeUserBtn.hidden = NO;
    }
}
#pragma mark - 云录制服务协议点击
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if ([[URL scheme] isEqualToString:@"CSAgreementURL"]) {
        NSURL *url = [NSURL URLWithString:@"http://www.ulifecam.com/common/cloud-storage-agreements.html"];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
        return NO;
    }
    return YES;
}
#pragma mark - 支付点击
- (IBAction)actionPayClick:(UIButton *)sender {
    switch (sender.tag) {
        case 10:{
            self.payType = cloudServiceOrderType_FreeDay;
        }break;
        case 11:{
            self.payType = cloudServiceOrderType_Pay;
        }break;
            
        default:
            break;
    }
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(CloudServiceFootViewBtnClick:)]) {
        [self.delegate CloudServiceFootViewBtnClick:self.payType];
    }
}

#pragma mark - lifyCycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"CloudServiceFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}


@end
