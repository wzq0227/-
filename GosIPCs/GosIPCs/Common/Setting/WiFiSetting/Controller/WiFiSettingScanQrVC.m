//
//  WiFiSettingScanQrVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingScanQrVC.h"
#import "WiFiSettingConnectRouterVC.h"
#import "KKAlertView.h"
#import "AlertNotVoiceView.h"
#import "AlertTipsView.h"
#import "iOSSmartSDK.h"
#import "iOSConfigSDKModel.h"
#import "UIAlertController+AddDeviceTip.h"
@interface WiFiSettingScanQrVC ()
@property (weak, nonatomic) IBOutlet UIImageView *scanQRImg;
@property (weak, nonatomic) IBOutlet UIButton *tipsBtn;
@property (weak, nonatomic) IBOutlet UIButton *hearBtn;

@property (nonatomic, strong) iOSSmartSDK * smartSDK;   // sdk
@end

@implementation WiFiSettingScanQrVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
     [self configUI];
    // Do any additional setup after loading the view from its nib.
    [self configQRCodeImage];
   
    BOOL obj = GOS_GET_OBJ(kNoRemindWiFiNotify);
    if (!obj) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AlertTipsView *contentView = [[AlertTipsView alloc]init];
            contentView.isAddDevice = NO;
            [KKAlertView shareView].contentView = contentView;
            [[KKAlertView shareView] show];
        });
    }
   
    
}
- (void)configUI{
    self.title = DPLocalizedString(@"Qrcode");
    self.hearBtn.layer.cornerRadius = 20.0f;
    self.hearBtn.clipsToBounds = YES;
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.tipsBtn setTitle:DPLocalizedString(@"Qrcode_unsoundBtn") forState:UIControlStateNormal];
        [strongSelf.hearBtn setTitle:DPLocalizedString(@"Qrcode_soundBtn") forState:UIControlStateNormal];

    });
    }

- (void)configQRCodeImage{
    self.smartSDK = [iOSSmartSDK shareSmartSdk];
    UIImage * qrImg = [self.smartSDK genQRCodeWithSsid:self.wifiName wifiPwd:self.wifiPassword deviceId:self.dataModel.DeviceId];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scanQRImg.image = qrImg;
    });
}

- (IBAction)actionNotVoiceClick:(UIButton *)sender {
//    AlertNotVoiceView *contentView = [[AlertNotVoiceView alloc]init];
//    [KKAlertView shareView].contentView = contentView;
//    dispatch_async(dispatch_get_main_queue(), ^{
//         [[KKAlertView shareView] show];
//    });
    UIAlertController *alertView = [UIAlertController NoSoundAlertController];
    [self.navigationController presentViewController:alertView
                                            animated:YES
                                          completion:nil];
}
- (IBAction)actionNextStepClick:(UIButton *)sender {
    WiFiSettingConnectRouterVC * vc = [[WiFiSettingConnectRouterVC alloc] init];
    vc.dataModel = self.dataModel;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
