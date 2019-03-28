//
//  RetrievePasswordViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "RetrievePasswordViewController.h"
#import "UIView+GosGradient.h"
#import "NSString+GosSize.h"
#import "NSString+GosCheck.h"
#import "GosInfoLegalCheck.h"
#import "iOSConfigSDK.h"
#import "GosBottomTipsView.h"
#import "GosHUDView.h"
#import "CountrySelectViewController.h"

@interface RetrievePasswordViewController () <
                                                UITextFieldDelegate,
                                                iOSConfigSDKUMDelegate
                                             >
{
    BOOL m_isConfigGradient;
    BOOL m_isEnableReqAuthCode;
    BOOL m_isShowPassword;
    BOOL m_isShowConfirmPassword;
    BOOL m_isEnalbeCommit;
    AccountType m_aType;
}

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *authCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *reqAuthCodeBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *commitBtn;
@property (weak, nonatomic) IBOutlet UILabel *formatTipsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authCodeBtnWidth;
@property (weak, nonatomic) IBOutlet UIView *commitBtnStyleView;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *passwordLockBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *confirmPasswordLockBtn;
@property (weak, nonatomic) IBOutlet UILabel *countryInfoLabel;
@property (nonatomic, readwrite, copy) NSString *accountStr;
@property (nonatomic, readwrite, copy) NSString *authCodeStr;
@property (nonatomic, readwrite, copy) NSString *passwordStr;
@property (nonatomic, readwrite, copy) NSString *confirmPasswordStr;
@property (nonatomic, readwrite, strong) iOSConfigSDK *configSdk;
@property(nonatomic, copy) NSString *mobileCN;
@end

@implementation RetrievePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    [self configUI];
    [self addNetworkChangeNotify];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    if (NO == m_isConfigGradient)
    {
        m_isConfigGradient = YES;
        
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf configCommitBtnStyle:Button_disble];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- RetrievePasswordViewController dealloc ----------");
}

- (void)initParam
{
    m_isConfigGradient      = NO;
    m_isEnableReqAuthCode   = NO;
    m_isEnalbeCommit        = NO;
    m_isShowPassword        = NO;
    m_isShowConfirmPassword = NO;
    m_aType               = Account_email;
    ServerAreaType sArea  = ServerArea_domestic;
    switch (_loginArea)
    {
        case LoginServerNorthAmerica: sArea = ServerArea_overseas; break;   // 北美
        case LoginServerEuropean:     sArea = ServerArea_overseas; break;   // 欧洲
        case LoginServerChina:        sArea = ServerArea_domestic; break;   // 中国
        case LoginServerAsiaPacific:  sArea = ServerArea_overseas; break;   // 亚太
        case LoginServerMiddleEast:   sArea = ServerArea_overseas; break;   // 中东
        default: break;
    }
    [iOSConfigSDK setupServerArea:sArea];
    self.configSdk = [iOSConfigSDK shareCofigSdk];
    self.configSdk.umDelegate = self;
}

- (void)configUI
{
    self.title                         = DPLocalizedString(@"RetrievePassword");
    self.view.backgroundColor          = GOS_COLOR_RGB(0xF7F7F7);
    self.passwordTF.placeholder        = DPLocalizedString(@"PasswordTFPlaceholder");
    self.confirmPasswordTF.placeholder = DPLocalizedString(@"ConfirmPasswordTFPlaceholder");
    self.formatTipsLabel.text          = DPLocalizedString(@"Register_include_two_Format");
    self.countryInfoLabel.text         = DPLocalizedString(@"Country_TitleDefault");
    [self.commitBtn setTitle:DPLocalizedString(@"Commit")
                    forState:UIControlStateNormal];
    [self configShowPasswordIcon:m_isShowPassword];
    [self configShowConfirmPasswordIcon:m_isShowConfirmPassword];
    [self configAuthCodeBtn];
    [self configPlaceholder];
    [self addTFActions];
}
- (void)configPlaceholder
{
    NSString * tempAccountPlaceholder = DPLocalizedString(@"AccountTFPlaceholder");
    NSString * tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder");
//    switch (self.loginArea)
//    {
//        case LoginServerUnknow: //  未知
//        {
//
//        }break;
//        case LoginServerNorthAmerica:   // 北美
//        {
//            tempAccountPlaceholder  = DPLocalizedString(@"AccountTFPlaceholder2");
//            tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder2");
//        }break;
//        case LoginServerEuropean:   // 欧洲
//        {
//            tempAccountPlaceholder  = DPLocalizedString(@"AccountTFPlaceholder2");
//            tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder2");
//        }break;
//        case LoginServerChina:   // 中国
//        {
//            tempAccountPlaceholder  = DPLocalizedString(@"AccountTFPlaceholder");
//            tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder");
//        }break;
//        case LoginServerAsiaPacific:    // 亚太
//        {
//            tempAccountPlaceholder  = DPLocalizedString(@"AccountTFPlaceholder2");
//            tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder2");
//        }break;
//        case LoginServerMiddleEast: // 中东
//        {
//            tempAccountPlaceholder  = DPLocalizedString(@"AccountTFPlaceholder2");
//            tempAuthCodePlaceholder = DPLocalizedString(@"AuthCodeTFPlaceholder2");
//        }break;
//        default:
//            break;
//    }
    self.accountTF.placeholder         = tempAccountPlaceholder;
    self.authCodeTF.placeholder        = tempAuthCodePlaceholder;
}
#pragma mark -- 设置显示密码图标
- (void)configShowPasswordIcon:(BOOL)isShow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isShow)   // 隐藏密码
        {
            [self.passwordLockBtn setImage:GOS_IMAGE(@"icon_eyes_close")
                                  forState:UIControlStateNormal];
        }
        else    // 显示密码
        {
            [self.passwordLockBtn setImage:GOS_IMAGE(@"icon_eyes_open")
                                  forState:UIControlStateNormal];
        }
        self.passwordTF.secureTextEntry = !isShow;
    });
}

#pragma mark -- 设置显示确认密码图标
- (void)configShowConfirmPasswordIcon:(BOOL)isShow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (NO == isShow)   // 隐藏密码
        {
            [self.confirmPasswordLockBtn setImage:GOS_IMAGE(@"icon_eyes_close")
                                         forState:UIControlStateNormal];
        }
        else    // 显示密码
        {
            [self.confirmPasswordLockBtn setImage:GOS_IMAGE(@"icon_eyes_open")
                                         forState:UIControlStateNormal];
        }
        self.confirmPasswordTF.secureTextEntry = !isShow;
    });
}

#pragma mark -- 添加 TextField 事件
- (void)addTFActions
{
    [self.accountTF addTarget:self
                       action:@selector(inputAccountStr:)
             forControlEvents:UIControlEventEditingChanged];
    [self.authCodeTF addTarget:self
                        action:@selector(inputAuthCodeStr:)
              forControlEvents:UIControlEventEditingChanged];
    [self.passwordTF addTarget:self
                        action:@selector(inputPasswordStr:)
              forControlEvents:UIControlEventEditingChanged];
    [self.confirmPasswordTF addTarget:self
                               action:@selector(inputConfirmPasswordStr:)
                     forControlEvents:UIControlEventEditingChanged];
}

#pragma mark -- 设置验证码按钮
- (void)configAuthCodeBtn
{
    [self enableAuthCodeBtn:m_isEnableReqAuthCode];
    
    NSString *authTitle  = DPLocalizedString(@"ReqAuthCode");
    CGSize authTitleSize = [NSString sizeWithString:authTitle
                                               font:GOS_FONT(10)
                                         forMaxSize:CGSizeMake(120, 30)];
    self.authCodeBtnWidth.constant = authTitleSize.width + 10;
    [self.reqAuthCodeBtn setTitle:authTitle
                         forState:UIControlStateNormal];
    [self.reqAuthCodeBtn setTitleColor:GOS_WHITE_COLOR
                              forState:UIControlStateNormal];
    self.reqAuthCodeBtn.backgroundColor = GOS_COLOR_RGB(0x55AFFC);
}

- (void)enableAuthCodeBtn:(BOOL)isEnable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.reqAuthCodeBtn.enabled = isEnable;
    });
}

#pragma mark --  开启获取验证码倒计时
-(void)startReqAuthCoeCountdown
{
    __block NSInteger reqACTime  = REQ_AUTH_CODE_INTERVAL;
    dispatch_queue_t reqACQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t reqACTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, reqACQueue);
    dispatch_source_set_timer(reqACTimer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0); // 每秒执行
    
    dispatch_source_set_event_handler(reqACTimer, ^{
        
        if(0 >= reqACTime)   // 倒计时结束，关闭
        {
            dispatch_source_cancel(reqACTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 设置按钮的样式
                [self.reqAuthCodeBtn setTitle:DPLocalizedString(@"ReqAuthCode")
                                     forState:UIControlStateNormal];
                [self.reqAuthCodeBtn setTitleColor:GOS_WHITE_COLOR
                                          forState:UIControlStateNormal];
                self.reqAuthCodeBtn.backgroundColor = GOS_COLOR_RGB(0x55AFFC);
                self.reqAuthCodeBtn.userInteractionEnabled = YES;
            });
            
        }
        else
        {
            
            int seconds = reqACTime % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 设置按钮显示读秒效果
                [self.reqAuthCodeBtn setTitle:[NSString stringWithFormat:@"%.2d%@", seconds, DPLocalizedString(@"")]
                                     forState:UIControlStateNormal];
                [self.reqAuthCodeBtn setTitleColor:GOS_COLOR_RGB(0x999999)
                                          forState:UIControlStateNormal];
                self.reqAuthCodeBtn.backgroundColor = GOS_COLOR_RGB(0xF2F2F2);
                self.reqAuthCodeBtn.userInteractionEnabled = NO;
            });
            reqACTime--;
        }
    });
    dispatch_resume(reqACTimer);
}

#pragma mark -- 设置提交按钮
- (void)configCommitBtnStyle:(ButtonStatus)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (status)
        {
            case Button_disble:
            {
                [self.commitBtnStyleView gradientStartColor:BTN_DISABLE_START_COLOR
                                                   endColor:BTN_DISABLE_END_COLOR
                                               cornerRadius:20
                                                  direction:GosGradientLeftToRight];
                [self.commitBtn setBackgroundColor:GOS_COLOR_RGB_A(0xFFFFFF, 0.5)];
            }
                break;
                
            case Button_normal:
            {
                [self.commitBtnStyleView gradientStartColor:BTN_NORMAL_START_COLOR
                                                   endColor:BTN_NORMAL_END_COLOR
                                               cornerRadius:20
                                                  direction:GosGradientLeftToRight];
                [self.commitBtn setBackgroundColor:GOS_COLOR_RGB_A(0xFFFFFF, 0.25)];
            }
                break;
                
            case Button_highlight:
            {
                [self.commitBtnStyleView gradientStartColor:BTN_HIGHLIGHT_START_COLOR
                                                   endColor:BTN_HIGHLIGHT_END_COLOR
                                               cornerRadius:20
                                                  direction:GosGradientLeftToRight];
                [self.commitBtn setBackgroundColor:GOS_CLEAR_COLOR];
            }
                break;
        }
    });
}

- (void)enableCommitBtn:(BOOL)isEnable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.commitBtn.enabled = isEnable;
    });
}

#pragma mark -- 监听账号输入
- (void)inputAccountStr:(UITextField *)tf
{
    self.accountStr = tf.text;
    GosLog(@"账号：%@", self.accountStr);
    [self checkCanReqAuthCode];
    [self checkCanRegister];
}

- (void)inputAuthCodeStr:(UITextField *)tf
{
    self.authCodeStr = tf.text;
    GosLog(@"验证码：%@", self.authCodeStr);
    [self checkCanRegister];
}

#pragma mark -- 监听密码输入
- (void)inputPasswordStr:(UITextField *)tf
{
    self.passwordStr = tf.text;
    GosLog(@"密码：%@", self.passwordStr);
    [self checkCanRegister];
}

- (void)inputConfirmPasswordStr:(UITextField *)tf
{
    self.confirmPasswordStr = tf.text;
    GosLog(@"确认密码：%@", self.confirmPasswordStr);
    [self checkCanRegister];
}

#pragma mark -- 检查是否可以点击获取验证码
- (void)checkCanReqAuthCode
{
    if (GOS_ACCOUNT_MIN_LEN <= self.accountStr.length)
    {
        m_isEnableReqAuthCode = YES;
    }
    else
    {
        m_isEnableReqAuthCode = NO;
    }
    [self enableAuthCodeBtn:m_isEnableReqAuthCode];
}

#pragma mark -- 检查是否可以点击注册
- (void)checkCanRegister
{
    if (GOS_ACCOUNT_MIN_LEN <= self.accountStr.length
        && GOS_AUTH_CODE_MIN_LEN <= self.authCodeStr.length
        && GOS_PASSWORD_MIN_LEN <= self.passwordStr.length
        && GOS_PASSWORD_MIN_LEN <= self.confirmPasswordStr.length)
    {
        m_isEnalbeCommit = YES;
        [self configCommitBtnStyle:Button_normal];
    }
    else
    {
        m_isEnalbeCommit = NO;
        [self configCommitBtnStyle:Button_disble];
    }
    [self enableCommitBtn:m_isEnalbeCommit];
}

#pragma mark - 网络监控
- (void)addNetworkChangeNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kCurNetworkChangeNotify
                                               object:nil];
}

- (void)networkChanged:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    if (NO == [[dict allKeys] containsObject:@"CurNetworkStatus"])
    {
        return;
    }
    CurNetworkStatus curStatus = [dict[@"CurNetworkStatus"] integerValue];
    if (curStatus == CurNetwork_unknow)  // 无网络连接
    {
        self.hasNetwork = NO;
    }
    else
    {
        self.hasNetwork = YES;
    }
}

#pragma mark - 按钮事件中心
#pragma mark -- 获取验证码按钮事件
- (IBAction)reqAuthCodeBtnAction:(id)sender
{
    if (NO == [self.accountStr isLegalEmail])
    {
        m_aType = Account_phone;
    }
    if (NO == self.hasNetwork)
    {
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"HasNoNetwork")];
        return;
    }
    [self.configSdk reqVerCodeWithAccount:self.accountStr
                              accountType:m_aType
                                eventType:ReqVerCode_findPwd];
    [self.view endEditing:YES];
    [self startReqAuthCoeCountdown];
}
#pragma mark -- 密码显示按钮事件
- (IBAction)passwordLockBtnAction:(id)sender
{
    m_isShowPassword = !m_isShowPassword;
    [self configShowPasswordIcon:m_isShowPassword];
}

#pragma mark -- 确认密码显示按钮事件
- (IBAction)confirmPasswordLockBtnAction:(id)sender
{
    m_isShowConfirmPassword = !m_isShowConfirmPassword;
    [self configShowConfirmPasswordIcon:m_isShowConfirmPassword];
}

#pragma mark -- 提交按钮事件
- (IBAction)commitBtnAction:(id)sender
{
    if (NO == [GosInfoLegalCheck isLegalWithAccount:self.accountStr]
        || NO == [GosInfoLegalCheck isLegalWithPassword:self.passwordStr]
        || NO == [GosInfoLegalCheck isLegalWithPassword:self.confirmPasswordStr])
    {
        return;
    }
    if (NO == [self.passwordStr isEqualToString:self.confirmPasswordStr])
    {
        [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"PasswordInconformity")];
        return;
    }
    if (NO == self.hasNetwork)
    {
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"HasNoNetwork")];
        return;
    }
    if(NO == [self.passwordTF.text isAtLessExistTwoOfNumbersLowcaseUpcase])
    {
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"Register_include_two")];
        return;
    }
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    [self configCommitBtnStyle:Button_highlight];
    [self.configSdk findPassword:self.passwordStr
                         account:self.accountStr
                     accountType:m_aType
                        veryCode:self.authCodeStr];
}

#pragma mark -- 国别选择按钮
- (IBAction)selectCountryBtnAction:(UIButton *)sender {
    CountrySelectViewController *vc = [[CountrySelectViewController alloc] init];
    vc.resultBlock = ^(NSString * _Nonnull country, NSString * _Nonnull num) {
        self.countryInfoLabel.text = [NSString stringWithFormat:@"%@ %@",country,num];
        self.mobileCN = [num substringFromIndex:1];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -- 键盘返回键操作
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountTF)
    {
        [self.accountTF resignFirstResponder];
        [self.authCodeTF becomeFirstResponder];
    }
    else if (textField == self.authCodeTF)
    {
        [self.authCodeTF resignFirstResponder];
        [self.passwordTF becomeFirstResponder];
    }
    else if (textField == self.passwordTF)
    {
        [self.passwordTF resignFirstResponder];
        [self.confirmPasswordTF becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTF)
    {
        [self.confirmPasswordTF resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - iOSConfigSDKUMDelegate
#pragma mark --  iOSConfigSDK 初始化回调
- (void)initConfigSdk:(BOOL)isSuccess
            errorCode:(int)eCode
{
    if (YES == isSuccess)
    {
        GosLog(@"iOSConfigSDK 初始化成功！");
        return;
    }
    GosLog(@"iOSConfigSDK 初始化失败，错误码：%d", eCode);
    switch (eCode)
    {
        case CONSDK_ERR_NO_SUPPORT_BLOCK_MODE:      // 不支持阻塞模式
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：不支持阻塞模式");
        }
            break;
            
        case CONSDK_ERR_TIMEOUT:                    // 请求超时
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：请求超时");
        }
            break;
            
        case CONSDK_ERR_NO_SUPPORT_REQ:             // SDK不支持该请求
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：SDK不支持该请求");
        }
            break;
            
        case CONSDK_ERR_SEND_FAILED:                // 发送请求失败
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：发送请求失败");
        }
            break;
            
        case CONSDK_ERR_SEND_REQ_WHEN_DISCONNECT:   // 在断线的情况下发送的请求
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：在断线的情况下发送的请求");
        }
            break;
            
        case CONSDK_ERR_CONNECT_FAILED:             // 连接服务器失败
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：连接服务器失败");
        }
            break;
            
        case CONSDK_ERR_SOCKET_ERROR:               // 套接字异常
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：套接字异常");
        }
            break;
            
        case CONSDK_ERR_BUFFER_IS_TOO_SMALL:        // 用作输出拷贝的buffer空间不够
        {
            GosLog(@"iOSConfigSDK 初始化失败，原因：用作输出拷贝的buffer空间不够");
        }
            break;
            
        default:
            break;
    }
}
#pragma mark -- 获取验证码回调
- (void)reqVerCode:(BOOL)isSuccess
         errorCode:(int)eCode
{
    GosLog(@"获取验证码结果：%d, %d", isSuccess, eCode);
    if (YES == isSuccess)
    {
        switch (m_aType)
        {
            case Account_name:  // 用户名注册
            {
                [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"AuthCodeSendPhone")];
            }
                break;
                
            case Account_email: // 邮箱注册
            {
                [GosBottomTipsView showWithMessge:DPLocalizedString(@"AhtuCodeSendEmail")];
            }
                break;
                
            case Account_phone: // 手机注册
            {
                [GosBottomTipsView showWithMessge:DPLocalizedString(@"AuthCodeSendPhone")];
            }
                break;
                
            default:
            {
                [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"AuthCodeSendPhone")];
            }
                break;
        }
    }
    else
    {
        switch (eCode)
        {
            case CONSDK_ERR_PARAM_ILLEGAL:  // 参数不合法
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountOrPwdFmtError")];
            }
                break;
                
            case CONSDK_ERR_USER_NOT_EXIST:  // 用户不存在
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountNotExist")];
            }
                break;
                
            case CONSDK_ERR_USER_NAME_ERROR:    // 用户名错误
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"UserNameError")];
            }
                break;
                
            case CONSDK_ERR_EMAIL_ERROR:  // 用户邮箱地址错误
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"EmailAddrError")];
            }
                break;
                
            case CONSDK_ERR_SEND_SEND_VERIFY_CODE_FAILED:   // 发送验证码到邮箱失败
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"SendAuthCodeToEmailFailure")];
            }
                break;
                
            default:    // 发送失败，请检查网络连接
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"SendDataFailure")];
            }
                break;
        }
    }
}

#pragma mark -- 找回密码回调
- (void)findPassword:(BOOL)isSuccess
           errorCode:(int)eCode
{
    GosLog(@"找回密码结果：%d, %d", isSuccess, eCode);
    [SVProgressHUD dismiss];
    [self configCommitBtnStyle:Button_normal];
    if (YES == isSuccess)
    {
        [GosHUDView showSuccessWithStatus:DPLocalizedString(@"ResetSuccess")];
    }
    else
    {
        switch (eCode)
        {
            case CONSDK_ERR_PARAM_ILLEGAL:  // 参数不合法
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountOrPwdFmtError")];
            }
                break;
                
            case CONSDK_ERR_MODIFY_USER_PWD_FAILED:   // 修改用户密码失败
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountHasExist")];
            }
                break;
                
            case CONSDK_ERR_VERIFY_CODE_ERROR: // 验证码错误
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AuthCodeError")];
            }
                break;
                
            case CONSDK_ERR_VERIFY_CODE_OVERDUE:    // 验证码过期
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AuthCodeExpired")];
            }
                break;
                
            case CONSDK_ERR_NO_REQ_VERIFY_CODE: // 没有获取验证码
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"HaveNotReqAuthCode")];
            }
                break;
                
            default:    // 发送失败，请检查网络连接
            {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"SendDataFailure")];
            }
                break;
        }
    }
}

@end
