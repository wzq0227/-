//  ModifyLoginPasswordViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ModifyLoginPasswordViewController.h"
#import "UITextField+GosTextField.h"
#import "PasswordInputValidator.h"
#import "ConfirmInputValidator.h"
#import "GosHUD.h"
#import "GosLoggedInUserInfo.h"
#import "UIButton+GosGradientButton.h"
#import "iOSConfigSDK.h"
#import "GosLoggedInUserInfo+SDKExtension.h"
#import "LogoutModuleCommand.h"


@interface ModifyLoginPasswordViewController () <UITextFieldDelegate, iOSConfigSDKUMDelegate>
/// 旧密码
@property (weak, nonatomic) IBOutlet UITextField *oldTextField;
/// 新密码
@property (weak, nonatomic) IBOutlet UITextField *replaceTextField;
/// 验证密码
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
/// 保存按钮
@property (weak, nonatomic) IBOutlet UIButton *savedButton;

@property (nonatomic, strong) iOSConfigSDK *configSDK;

@end

@implementation ModifyLoginPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Mine_ModifyLoginPassword");
    
    [self configComponents];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [GosHUD dismiss];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)configComponents {
    // 验证本地存储的密码
    self.oldTextField.inputValidator = [[PasswordInputValidator alloc] initWithDefaultString:[GosLoggedInUserInfo password]];
    // 验证新密码正确逻辑
    self.replaceTextField.inputValidator = [[PasswordInputValidator alloc] init];
    // 验证与新密码相同
    self.confirmTextField.inputValidator = [[ConfirmInputValidator alloc] initWithDestinationConfirmTextField:self.replaceTextField];
    
    // 保存按钮底色
    [self.savedButton setupGradientStartColor:GOSCOM_THEME_START_COLOR endColor:GOSCOM_THEME_END_COLOR cornerRadiusFromHeightRatio:0.5 direction:GosGradientLeftToRight];
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.savedButton setEnabled:[textField validate]];
}

#pragma mark - iOSConfigSDKUMDelegate
- (void)resetPassword:(BOOL)isSuccess errorCode:(int)eCode {
    if (isSuccess) {
        [SVProgressHUD showSuccessWithStatus:@"GosComm_Set_Succeeded"];
        // 0.5s之后返回
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.navigationController popToRootViewControllerAnimated:YES];
            LogoutModuleCommand *command = [[LogoutModuleCommand alloc] init];
            [command execute];
        });
    }
    else{
        [GosHUD showProcessHUDErrorWithStatus:@"GosComm_Set_Failed"];
        
    }
}

#pragma mark - event response
- (IBAction)saveButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [GosHUD showProcessHUDWithStatus:@"Mine_Loading"];
    // 请求重置密码
    [self.configSDK resetPassword:self.replaceTextField.text oldPassword:self.oldTextField.text account:[GosLoggedInUserInfo account] accountType:[GosLoggedInUserInfo sdkAccountType]];
}

#pragma mark - getters and setters
- (iOSConfigSDK *)configSDK {
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.umDelegate = self;
    }
    return _configSDK;
}

@end
