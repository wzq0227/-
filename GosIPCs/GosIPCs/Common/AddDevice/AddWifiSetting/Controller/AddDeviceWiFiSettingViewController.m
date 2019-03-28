//
//  AddDeviceWiFiSettingViewController.m
//  ULife3.5
//
//  Created by AnDong on 2018/8/22.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "AddDeviceWiFiSettingViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ChangeWifiTipViewController.h"
#import "EnlargeClickButton.h"
#import "AddDeviceConfigViewController.h"
#import "UIColor+GosColor.h"
#import "CreateQRCodeViewController.h"
#import "AddDeviceConnectToDeviceWiFiViewController.h"
#import "GosLoggedSSIDInfo.h"
//#import "JumpWiFiTipsView.h"

@interface AddDeviceWiFiSettingViewController () <UITextFieldDelegate> {
    NSString *currentWiFiName;
}

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *ssidTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeWiFiBtn;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet EnlargeClickButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberPasswordBtn;
@property (weak, nonatomic) IBOutlet UILabel *rememberPWDLabel;

@end

@implementation AddDeviceWiFiSettingViewController
#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SSIDDidBeChangedNotifiCation) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self SSIDDidBeChangedNotifiCation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - UI相关
- (void)initUI {
    self.navigationItem.title = DPLocalizedString(@"AddDEV_wifiSet_title");
    self.view.backgroundColor = [UIColor gosGrayColor];
    self.label.text = DPLocalizedString(@"AddDEV_WiFiSet_tip");
    [self.label setTextColor:[UIColor blackColor]];
    self.label.hidden = NO;
    
    self.ssidTextField.placeholder = DPLocalizedString(@"AddDEV_PlaceHolder_SSID");
    self.pwdTextField.placeholder = DPLocalizedString(@"AddDEV_PlaceHolder_PWD");
    self.ssidTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
    [self.changeWiFiBtn setTitle:DPLocalizedString(@"AddDEV_ChangeNet") forState:UIControlStateNormal];
    [self.changeWiFiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.changeWiFiBtn setBackgroundColor:GOSCOM_THEME_START_COLOR];
    self.changeWiFiBtn.layer.cornerRadius = 5.f;
//    self.changeWiFiBtn.titleLabel.numberOfLines = 0;
    self.changeWiFiBtn.titleLabel.minimumScaleFactor = 0.5;
    self.changeWiFiBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.changeWiFiBtn addTarget:self action:@selector(changeWiFiBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.rememberPWDLabel.text = DPLocalizedString(@"RememberPassword");
    
    [self.nextBtn setTitle:DPLocalizedString(@"AddDEV_NextStep") forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
//    self.alertLabel.text = DPLocalizedString(@"WiFi_SSID_PWD");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEndEditing)];
    [self.view addGestureRecognizer:tap];
    
    self.pwdTextField.secureTextEntry = YES;
    [self configShowPasswordImg];
    [self configRememberPasswordBtnIcon];
}

#pragma mark -- 根据wifi名称配置相关控件
- (void)configUIWithWifiName {
    if (!currentWiFiName) {
        [self updateNextBtnUI:NO];
        return;
    }
    
    if ([currentWiFiName hasSuffix:@"5G"]){
        [self updateNextBtnUI:NO];
        self.label.text = DPLocalizedString(@"AddDEV_5GWiFi_tip");
        [self.label setTextColor:[UIColor redColor]];
    }
    else {
        self.label.text = DPLocalizedString(@"AddDEV_WiFiSet_tip");
        [self.label setTextColor:[UIColor blackColor]];
        
        if (self.pwdTextField.text.length < 8) {
            [self updateNextBtnUI:NO];
        } else {
            [self updateNextBtnUI:YES];
        }
    }
}

#pragma mark -- 设置显示密码图标
- (void)configShowPasswordImg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isHidden = self.pwdTextField.secureTextEntry;
        if (isHidden)   // 隐藏密码
        {
            [self.showPasswordBtn setImage:GOS_IMAGE(@"icon_eyes_close")
                                  forState:UIControlStateNormal];
        }
        else    // 显示密码
        {
            [self.showPasswordBtn setImage:GOS_IMAGE(@"icon_eyes_open")
                                  forState:UIControlStateNormal];
        }
    });
}

#pragma mark -- 设置记住密码图标
- (void)configRememberPasswordBtnIcon
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isRemember = self.rememberPasswordBtn.selected;
        if (NO == isRemember)
        {
            [self.rememberPasswordBtn setImage:GOS_IMAGE(@"icon_uncheck_round_rectangle")
                                      forState:UIControlStateNormal];
        }
        else    // 记住密码
        {
            [self.rememberPasswordBtn setImage:GOS_IMAGE(@"icon_check_round_rectangle")
                                      forState:UIControlStateNormal];
        }
    });
}

#pragma mark - 记住密码相关
#pragma mark -- 获取上次保存的ssid和密码，配置输入框
- (void)configTestField {
    NSString *ssid = [GosLoggedSSIDInfo SSID];
    if ([ssid isEqualToString:self.ssidTextField.text]) {
        self.pwdTextField.text = [GosLoggedSSIDInfo SSIDPassword];
        self.rememberPasswordBtn.selected = YES;
        [self configRememberPasswordBtnIcon];
    } else {
        self.pwdTextField.text = @"";
        self.rememberPasswordBtn.selected = NO;
        [self configRememberPasswordBtnIcon];
    }
}

#pragma mark -- 保存ssid和密码
- (void)saveSSIDAndPWD {
    [GosLoggedSSIDInfo saveSSID:self.ssidTextField.text];
    [GosLoggedSSIDInfo saveSSIDPassword:self.pwdTextField.text];
}

#pragma mark -- 清除保存的ssid和密码
- (void)clearSSIDAndPWD {
    [GosLoggedSSIDInfo clearSSID];
    [GosLoggedSSIDInfo clearPassword];
}

#pragma mark - ssid切换通知处理
- (void)SSIDDidBeChangedNotifiCation {
    currentWiFiName = [self getWifiName];
    self.ssidTextField.text = currentWiFiName;
    [self configTestField];
    [self configUIWithWifiName];
}

#pragma mark -- 获取当前wifi名称
- (NSString *) getWifiName {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces)
        return @"";
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

#pragma mark - 按钮相关
#pragma mark -- 显示/隐藏密码按钮事件
- (IBAction)showPasswordBtnAction:(UIButton *)btn
{
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
    [self configShowPasswordImg];
}

#pragma mark -- 记住密码按钮事件
- (IBAction)rememberPasswordBtnAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self configRememberPasswordBtnIcon];
}

#pragma mark -- 切换wifi按钮事件
- (void)changeWiFiBtnDidClick {
    // 弹框提示设置WiFi
    ChangeWifiTipViewController *vc = [[ChangeWifiTipViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- tap事件
- (void)viewEndEditing {
    [self.view endEditing:YES];
}

#pragma mark -- 下一步按钮事件
- (void)nextBtnDidClick {
    if (self.ssidTextField.text.length!=0 && self.pwdTextField.text.length!=0) {
        if (self.pwdTextField.text.length <8) {
            //少于8位
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_LenShort")];
            return;
        }
        
        if (self.pwdTextField.text.length >64) {
            //大于64位
            [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_LenLong")];
            return;
        }
        
        //保存WiFi名称和密码
        if (self.rememberPasswordBtn.isSelected) {
            [self saveSSIDAndPWD];
        } else {
            [self clearSSIDAndPWD];
        }
        self.devModel.wifiName = self.ssidTextField.text;
        self.devModel.wifiPWD  = self.pwdTextField.text;

        
        if (self.addMethodType == SupportAdd_wifi) {
            AddDeviceConfigViewController *vc = [[AddDeviceConfigViewController alloc] init];
            vc.devModel = self.devModel;
            vc.addMethodType = self.addMethodType;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (self.addMethodType == SupportAdd_scan) {
            CreateQRCodeViewController * view = [[CreateQRCodeViewController alloc] init];
            view.devModel = self.devModel;
            [self.navigationController pushViewController:view animated:NO];
        } else if (self.addMethodType == SupportAdd_apNew) {
            AddDeviceConnectToDeviceWiFiViewController *vc = [[AddDeviceConnectToDeviceWiFiViewController alloc] init];
            vc.devModel = self.devModel;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.ssidTextField) {
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length == 1 && string.length == 0) {
        return YES;
    }
    if (textField == self.ssidTextField) {
        return YES;
    } else if (self.pwdTextField.text.length > 63){
        self.pwdTextField.text = [textField.text substringToIndex:64];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self configUIWithWifiName];
    
    if (textField == self.pwdTextField && textField.text.length < 8) {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AddDEV_LenShort")];
    }
}

- (void)updateNextBtnUI:(BOOL)show {
    self.nextBtn.userInteractionEnabled = show;
    self.nextBtn.backgroundColor = show ? GOSCOM_THEME_START_COLOR : GOS_COLOR_RGB(0x55AFFC);
//    self.label.hidden = show;
}

@end
