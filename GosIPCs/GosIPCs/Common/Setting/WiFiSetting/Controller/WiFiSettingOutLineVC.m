//
//  WiFiSettingOutLineVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingOutLineVC.h"
#import "iOSConfigSDK.h"
#import "WiFiSettingScanQrVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "iOSConfigSDKModel.h"
#import "UIImage+GIF.h"
@interface WiFiSettingOutLineVC ()<iOSConfigSDKParamDelegate,
UITextFieldDelegate>{
    BOOL m_isShowPassword;
}
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (weak, nonatomic) IBOutlet UILabel *closeLab;
@property (weak, nonatomic) IBOutlet UITextField *wifiNameTF;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTF;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UIImageView *topGifImg;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topGifLength;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnLength;
@property (weak, nonatomic) IBOutlet UIButton *showPassBtn;

@end

@implementation WiFiSettingOutLineVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    //    [self configNetData];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_WiFiConnect");
    self.nextStepBtn.layer.cornerRadius = 20.0f;
    self.nextStepBtn.clipsToBounds = YES;
    
    self.wifiNameTF.placeholder = DPLocalizedString(@"Input_WiFiAccount");
    self.wifiNameTF.enabled = NO;
    self.wifiPasswordTF.placeholder = DPLocalizedString(@"Input_WiFiPassword");
    self.wifiPasswordTF.delegate = self;
    
    self.tipsLab.text = [NSString stringWithFormat:@"%@\n%@",DPLocalizedString(@"ADDDevice_Set"),DPLocalizedString(@"WiFiSetting_PhoneConnectedToWiFi")];
    self.closeLab.text = DPLocalizedString(@"WiFiSetting_CameraCloseToRouter");
    [self.nextStepBtn setTitle:DPLocalizedString(@"Setting_NextStep") forState:UIControlStateNormal];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"addDev_configuration" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.topGifImg.image = [UIImage animatedGIFWithData:imageData];
    self.topGifLength.constant = 80.0f/667.0f*GOS_SCREEN_H;
    self.nextBtnLength.constant = 80.0f/667.0f*GOS_SCREEN_H;
}
- (void)configNetData{
    [self.configSdk reqSsidListOfDevId:self.dataModel.DeviceId];
    m_isShowPassword = NO;
}
#pragma mark - 明暗文点击切换
- (IBAction)actionEyeClick:(UIButton *)sender {
    m_isShowPassword =! m_isShowPassword;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NO == m_isShowPassword)   // 隐藏密码
        {
            [self.showPassBtn setImage:GOS_IMAGE(@"icon_eyes_close")
                              forState:UIControlStateNormal];
        }
        else    // 显示密码
        {
            [self.showPassBtn setImage:GOS_IMAGE(@"icon_eyes_open")
                              forState:UIControlStateNormal];
        }
        self.wifiPasswordTF.secureTextEntry = !m_isShowPassword;
    });
}

#pragma mark - textField&delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}
#pragma mark -- actionFunction
- (IBAction)actionNextStepClick:(UIButton *)sender {
    if (self.wifiNameTF.text.length < 1 ) {
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"Input_WiFiAccount")];
        return;
    }
    if(self.wifiPasswordTF.text.length < 1){
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"Input_WiFiPassword")];
        return;
    }
    
    WiFiSettingScanQrVC * vc = [[WiFiSettingScanQrVC alloc] init];
    vc.wifiName = self.wifiNameTF.text;
    vc.wifiPassword = self.wifiPasswordTF.text;
    vc.dataModel = self.dataModel;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- lifestyle
#pragma mark - 监听后台到前台的切换
- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self applicationDidBecomeActive];
}
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)applicationDidBecomeActive {
    if ([[self getCurrentWiFiSSID] isKindOfClass:[NSString class]]) {
        self.wifiNameTF.text = [self getCurrentWiFiSSID];
    };
}
#pragma mark -- function
- (NSString *) getCurrentWiFiSSID{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"];
    return ssid;
}

#pragma mark -- delegate
#pragma mark -- lazy
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
@end
