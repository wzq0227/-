//
//  LoginViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "LoginViewController.h"
#import "EnlargeClickButton.h"
#import "UIButton+GosTitleAndImg.h"
#import "NSString+GosSize.h"
#import "UIView+GosCoord.h"
#import "AppDelegate+Jump.h"
#import "GosPickerView.h"
#import "NSString+GosCheck.h"
#import "iOSConfigSDK.h"
#import "CheckNetworkViewController.h"
#import "RegisterViewController.h"
#import "GosInfoLegalCheck.h"
#import "UIViewController+GosHiddenNavBar.h"
#import "RetrievePasswordViewController.h"
#import "UIView+GosGradient.h"
#import "CheckNetwork.h"
#import "CountrySelectViewController.h"

#define PICK_VIEW_HEIGHT    250


@interface LoginViewController () <
                                    UITextFieldDelegate,
                                    GosPickerViewDelegate,
                                    iOSConfigSDKUMDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate
                                  >
{
    BOOL m_isShowPassword;
    BOOL m_isRememberPassword;
    BOOL m_isShowPickerView;
    BOOL m_isEnalbeLogin;
    BOOL m_isConfigGradient;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *changeCountryViewWidth;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *changeCountryBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *quickRegisterBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *forgetPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberPasswordBtn;
@property (weak, nonatomic) IBOutlet UIView *changeCountryView;
@property (weak, nonatomic) IBOutlet UILabel *rememberPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet UIView *loginBtnStyleView;
@property (weak, nonatomic) IBOutlet UILabel *countryInfoLabel;
@property (nonatomic, readwrite, strong) GosPickerView *pickerView;
@property (nonatomic, readwrite, strong) NSArray<NSArray*> *countries;

@property (nonatomic, readwrite, copy) NSString *accountStr;
@property (nonatomic, readwrite, copy) NSString *passwordStr;
@property (nonatomic, readwrite, assign) LoginServerArea loginArea;

@property (nonatomic, strong) iOSConfigSDK *configSdk;
/** 历史账号集合 */
@property (nonatomic, readwrite, strong) NSSet<NSString*>*historyAccountSet;
@property (nonatomic, readwrite, strong) NSMutableArray<NSString*>*matchAccountList;

@property(nonatomic, copy) NSString *mobileCN;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    
    [self configUI];
    
    [self addNetworkChangeNotify];
    
    [self loadHistoryAccountSet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self inputDefaultAccount];
    [self configRememberPasswordBtnIcon:m_isRememberPassword];
    [self configTableViewHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configCountriesPickerVew];
}

- (void)viewWillLayoutSubviews
{
    if (NO == m_isConfigGradient)
    {
        m_isConfigGradient = YES;
        
        GOS_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf configLoginBtnStyle:Button_disble];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.pickerView dismiss];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- LoginViewController dealloc ----------");
}

- (void)initParam
{
    m_isShowPassword     = NO;
    m_isRememberPassword = NO;
    m_isShowPickerView   = NO;
    m_isEnalbeLogin      = NO;
    m_isConfigGradient   = NO;
    self.loginArea       = [GosLoggedInUserInfo serverArea];
}

#pragma mark - UI 设置
- (void)configUI
{
    self.view.backgroundColor          = GOS_COLOR_RGB(0xF7F7F7);
    self.navigationController.delegate = self;
    self.passwordTF.placeholder        = DPLocalizedString(@"PasswordTFPlaceholder");
    self.rememberPasswordLabel.text    = DPLocalizedString(@"RememberPassword");
    self.countryInfoLabel.text         = DPLocalizedString(@"Country_TitleDefault");
    [self.quickRegisterBtn setTitle:DPLocalizedString(@"FastRegister")
                           forState:UIControlStateNormal];
    
    
    [self.forgetPasswordBtn setTitle:DPLocalizedString(@"ForgetPassword")
                            forState:UIControlStateNormal];
    
    [self configAccounTFPlaceholder:self.loginArea];
    [self configShowPasswordImg:m_isShowPassword];
    [self configRememberPasswordBtnIcon:m_isRememberPassword];
    
    [self.loginBtn setTitle:DPLocalizedString(@"Login")
                   forState:UIControlStateNormal];
    [self configChangeCountryUI];
    
    [self.accountTF addTarget:self
                       action:@selector(inputAccountStr:)
             forControlEvents:UIControlEventEditingChanged];
    [self.passwordTF addTarget:self
                        action:@selector(inputPasswordStr:)
              forControlEvents:UIControlEventEditingChanged];
    
    [self configMatchAccountTableView];
}

#pragma mark -- 设置登录按钮
- (void)configLoginBtnStyle:(ButtonStatus)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (status)
        {
            case Button_disble:
            {
                [self.loginBtnStyleView gradientStartColor:BTN_DISABLE_START_COLOR
                                                  endColor:BTN_DISABLE_END_COLOR
                                              cornerRadius:20
                                                 direction:GosGradientLeftToRight];
                [self.loginBtn setBackgroundColor:GOS_COLOR_RGB_A(0xFFFFFF, 0.5)];
            }
                break;
                
            case Button_normal:
            {
                [self.loginBtnStyleView gradientStartColor:BTN_NORMAL_START_COLOR
                                                  endColor:BTN_NORMAL_END_COLOR
                                              cornerRadius:20
                                                 direction:GosGradientLeftToRight];
                [self.loginBtn setBackgroundColor:GOS_COLOR_RGB_A(0xFFFFFF, 0.25)];
            }
                break;
                
            case Button_highlight:
            {
                [self.loginBtnStyleView gradientStartColor:BTN_HIGHLIGHT_START_COLOR
                                                  endColor:BTN_HIGHLIGHT_END_COLOR
                                              cornerRadius:20
                                                 direction:GosGradientLeftToRight];
                [self.loginBtn setBackgroundColor:GOS_CLEAR_COLOR];
            }
                break;
        }
    });
}

- (void)enableLoginBtn:(BOOL)isEnable
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.loginBtn.enabled = isEnable;
    });
}

#pragma mark -- 设置国家选择器
- (void)configCountriesPickerVew
{
    self.pickerView                   = [[GosPickerView alloc] init];
    self.pickerView.delegate          = self;
    self.pickerView.topViewBGColor    = GOS_COLOR_RGB(0xF2F2F2);
    self.pickerView.pickerViewBGColor = GOS_COLOR_RGB(0xF2F2F2);
    self.pickerView.pvTitle           = DPLocalizedString(@"ChnageCountry");
    self.pickerView.leftBtnTitle      = DPLocalizedString(@"GosComm_Cancel");
    self.pickerView.rightBtnTitle     = DPLocalizedString(@"GosComm_Confirm");
    self.pickerView.rowHeight         = 35.0f;
    [self.pickerView configWithDatas:[self countries]];
}

- (void)configMatchAccountTableView
{
    self.accountTableView.rowHeight       = 40.0f;
    self.accountTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.accountTableView.bounces         = NO;
}
#pragma mark -- 历史账号导入
- (void)loadHistoryAccountSet
{
    NSData *setData = GOS_GET_OBJ(kHistoryAccountList);
    self.historyAccountSet = [NSKeyedUnarchiver unarchiveObjectWithData:setData];
}

- (void)saveToHistorySetWithAccount:(NSString *)account
{
    if (IS_EMPTY_STRING(account))
    {
        return;
    }
    NSData *setData   = GOS_GET_OBJ(kHistoryAccountList);
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:setData];
    if (!set)
    {
        set = [NSMutableSet setWithCapacity:0];
    }
    [set addObject:account];
    GosLog(@"保存已登录成功账号：%@", account);
    setData = [NSKeyedArchiver archivedDataWithRootObject:set];
    GOS_SAVE_OBJ(setData, kHistoryAccountList);
}

#pragma mark -- 默认输入上传登录成功账号
- (void)inputDefaultAccount
{
    self.accountStr     = [GosLoggedInUserInfo account];
    self.accountTF.text = self.accountStr;
}

#pragma mark -- 监听账号输入
- (void)inputAccountStr:(UITextField *)tf
{
    self.accountStr = tf.text;
    GosLog(@"账号：%@", self.accountStr);
    [self refreshTableView];
}

#pragma mark -- 监听密码输入
- (void)inputPasswordStr:(UITextField *)tf
{
    self.passwordStr = tf.text;
    GosLog(@"密码：%@", self.passwordStr);
    if (GOS_ACCOUNT_MIN_LEN <= self.accountStr.length
        && GOS_PASSWORD_MIN_LEN <= self.passwordStr.length)
    {
        m_isEnalbeLogin = YES;
        [self configLoginBtnStyle:Button_normal];
    }
    else
    {
        m_isEnalbeLogin = NO;
        [self configLoginBtnStyle:Button_disble];
    }
    [self enableLoginBtn:m_isEnalbeLogin];
}

#pragma mark -- 刷新匹配历史账号列表
- (void)refreshTableView
{
    [self.matchAccountList removeAllObjects];
    GOS_WEAK_SELF;
    [self.historyAccountSet enumerateObjectsWithOptions:NSEnumerationConcurrent
                                             usingBlock:^(NSString * _Nonnull obj,
                                                          BOOL * _Nonnull stop)
    {
        GOS_STRONG_SELF;
        if (0 < [obj rangeOfString:self.accountStr options:NSCaseInsensitiveSearch].length)
        {
            [strongSelf.matchAccountList addObject:obj];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (0 < self.matchAccountList.count)
        {
            self.accountTableView.hidden = NO;
            [self.accountTableView reloadData];
        }
        else
        {
            self.accountTableView.hidden = YES;
        }
    });
}

- (void)configTableViewHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.accountTableView.hidden = isHidden;
    });
}

#pragma mark -- 设置选择器
- (void)configChangeCountryUI
{
    [self configChangeCountryBtnTitleWithArea:self.loginArea];
    self.changeCountryView.layer.shadowColor   = GOS_COLOR_RGBA(108, 168, 251, 0.2).CGColor;
    self.changeCountryView.layer.shadowOffset  = CGSizeMake(0, 4);
    self.changeCountryView.layer.shadowOpacity = 1;
    self.changeCountryView.layer.shadowRadius  = 8;
    self.changeCountryView.layer.borderWidth   = 0.5;
    self.changeCountryView.layer.borderColor   = GOS_COLOR_RGBA(85, 175, 252, 1).CGColor;
    self.changeCountryView.layer.cornerRadius  = 15;
    
    [self.changeCountryBtn configImageLocation:GosBtnImgLeft
                                  withInterval:10];
}

#pragma mark -- 设置切换国家地区按钮标题
- (void)configChangeCountryBtnTitleWithArea:(LoginServerArea)lgArea
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSString *countryTitle;
        if ((NSUInteger)lgArea >= self.countries[0].count)
        {
            countryTitle = DPLocalizedString(@"China");
        }
        else
        {
            countryTitle = self.countries[0][lgArea];
        }
        GosLog(@"选择国家和地区：%@", countryTitle);
        [self.changeCountryBtn setTitle:countryTitle
                               forState:UIControlStateNormal];
        CGSize strSize = [NSString sizeWithString:countryTitle
                                             font:[UIFont systemFontOfSize:14]
                                       forMaxSize:CGSizeMake(140, 30)];
        self.changeCountryViewWidth.constant = strSize.width + 50;
    });
}

#pragma mark -- 设置账户输入提示语
- (void)configAccounTFPlaceholder:(LoginServerArea)lsArea
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *placeholder;
//        if (LoginServerChina == lsArea)
//        {
            placeholder = DPLocalizedString(@"AccountTFPlaceholder");
//        }
//        else
//        {
//            placeholder = DPLocalizedString(@"AccountTFPlaceholder2");
//        }
        self.accountTF.placeholder = placeholder;
    });
}

#pragma mark -- 设置显示密码图标
- (void)configShowPasswordImg:(BOOL)isShow
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (NO == isShow)   // 隐藏密码
        {
            [self.showPasswordBtn setImage:GOS_IMAGE(@"icon_eyes_close")
                                  forState:UIControlStateNormal];
        }
        else    // 显示密码
        {
            [self.showPasswordBtn setImage:GOS_IMAGE(@"icon_eyes_open")
                                  forState:UIControlStateNormal];
        }
        self.passwordTF.secureTextEntry = !isShow;
    });
}

#pragma mark -- 设置记住密码图标
- (void)configRememberPasswordBtnIcon:(BOOL)isRemember
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
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

#pragma mark - 按钮事件中心
#pragma mark -- 显示/隐藏密码
- (IBAction)showPasswordBtnAction:(id)sender
{
    m_isShowPassword = !m_isShowPassword;
    [self configShowPasswordImg:m_isShowPassword];
}

#pragma mark -- 快速注册
- (IBAction)fastRegisterBtnAction:(id)sender
{
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.loginArea               = self.loginArea;
    registerVC.hasNetwork              = self.hasNetWork;
    [self.navigationController pushViewController:registerVC
                                         animated:YES];
}

#pragma mark -- 记住密码
- (IBAction)rememberPasswordBtnAction:(id)sender
{
    m_isRememberPassword = !m_isRememberPassword;
    [self configRememberPasswordBtnIcon:m_isRememberPassword];
}

#pragma mark -- 登录
- (IBAction)loginBtnAction:(id)sender
{
    if (NO == [GosInfoLegalCheck isLegalWithAccount:self.accountStr]
        || NO == [GosInfoLegalCheck isLegalWithPassword:self.passwordStr])
    {
        return;
    }
    if (NO == self.hasNetWork)
    {
        [SVProgressHUD showInfoWithStatus:DPLocalizedString(@"HasNoNetwork")];
        return;
    }
    [self enableLoginBtn:NO];
    [self configLoginBtnStyle:Button_highlight];
    [self.view endEditing:YES];
    [self configTableViewHidden:YES];
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    GosLog(@"开始登录（服务器区域：%ld)。。。", self.loginArea);
    [self.configSdk loginWithAccount:self.accountStr
                            password:self.passwordStr];
}

#pragma mark -- 切换国家地区
- (IBAction)changeCountryBtnAction:(id)sender
{
    [self.view endEditing:YES];
    [self configTableViewHidden:YES];
    [self.pickerView configDefaultSelectRow:self.loginArea inComponent:0];
    [self.pickerView show];
}

#pragma mark -- 忘记密码
- (IBAction)forgetPasswordBtnAction:(id)sender
{
    RetrievePasswordViewController *retrievePwdVC = [[RetrievePasswordViewController alloc] init];
    retrievePwdVC.loginArea                       = self.loginArea;
    retrievePwdVC.hasNetwork                      = self.hasNetWork;
    [self.navigationController pushViewController:retrievePwdVC
                                         animated:YES];
}

#pragma mark -- 登录成功，跳转到主页
- (void)jumpToMainRootVC
{
    [AppDelegate setUpMainTabBarVCOnWindow:[UIApplication sharedApplication].keyWindow
                               isAutoLogin:NO
                                hasNetwork:YES];
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
    switch (curStatus)
    {
    case CurNetwork_unknow: // 未知
    {
        GosLog(@"监测到当前网络状态为：未知");
        self.hasNetWork = NO;
    }
        break;
        
    case CurNetwork_wifi:         // WiFi 连接
    {
        GosLog(@"监测到当前网络状态为：WiFi 连接");
        self.hasNetWork = YES;
    }
        break;
            
    case CurNetwork_2G:         // 蜂窝数据连接 - 2G
    {
        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 2G");
        self.hasNetWork = YES;
    }
        break;
        
    case CurNetwork_3G:         // 蜂窝数据连接 - 3G
    {
        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 3G");
        self.hasNetWork = YES;
    }
        break;
        
    case CurNetwork_4G:         // 蜂窝数据连接 - 4G
    {
        GosLog(@"监测到当前网络状态为：蜂窝数据连接 - 4G");
        self.hasNetWork = YES;
    }
        break;
        
    default:
        break;
    }
}

#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.pickerView dismiss];
    [self configTableViewHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountTF)
    {
        [self.accountTF resignFirstResponder];
        [self.passwordTF becomeFirstResponder];
    }
    else if (textField == self.passwordTF)
    {
        [self.passwordTF resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    [self configTableViewHidden:YES];
    return YES;
}

- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        ServerAreaType sArea = ServerArea_domestic;
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
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.umDelegate = self;
    }
    return _configSdk;
}

- (NSArray<NSArray*> *)countries
{
    if (!_countries)
    {
        _countries = @[@[
                           DPLocalizedString(@"NorthAmerica"),    // 北美
                           DPLocalizedString(@"European"),        // 欧洲
                           DPLocalizedString(@"China"),           // 中国
                           DPLocalizedString(@"AsiaPacific"),     // 亚太
                           DPLocalizedString(@"MiddleEast"),      // 中东
                           ]];
    }
    return _countries;
}

#pragma mark - GosPickerViewDelegate
- (void)didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    GosLog(@"选择了：%@", self.countries[component][row]);
    if (self.loginArea == row)
    {
        return;
    }
    self.loginArea = row;
    ServerAreaType sArea = ServerArea_domestic;
    switch (self.loginArea)
    {
        case LoginServerNorthAmerica: sArea = ServerArea_overseas; break;   // 北美
        case LoginServerEuropean:     sArea = ServerArea_overseas; break;   // 欧洲
        case LoginServerChina:        sArea = ServerArea_domestic; break;   // 中国
        case LoginServerAsiaPacific:  sArea = ServerArea_overseas; break;   // 亚太
        case LoginServerMiddleEast:   sArea = ServerArea_overseas; break;   // 中东
        default: break;
    }
    [iOSConfigSDK setupServerArea:sArea];
    [self configChangeCountryBtnTitleWithArea:self.loginArea];
    [self configAccounTFPlaceholder:self.loginArea];
    
}

- (void)pickerViewStatus:(GosPickerViewStatus)status
{
    switch (status)
    {
        case GosPickerViewIsBeingHidden:
        {
//            GosLog(@"选择器正在隐藏中。。。");
            m_isShowPickerView = NO;
        }
            break;
            
        case GosPickerViewIsBeingAnimation:
        {
//            GosLog(@"选择器动画中。。。");
        }
            break;
            
        case GosPickerViewIsBeingShow:
        {
//            GosLog(@"选择器正在显示中。。。");
            m_isShowPickerView = YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 显示网络诊断
- (void)showCheckNetworkAlert
{
    [SVProgressHUD dismiss];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:DPLocalizedString(@"NetworkReqTimeOUt")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    UIAlertAction *checkAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"CheckNetwork")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                            [self turnToCheckNetwork];
                                                        }];
    [alert addAction:cancelAction];
    [alert addAction:checkAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    });
}

#pragma mark -- 转向网络诊断
- (void)turnToCheckNetwork
{
    CheckNetworkViewController *vc = [[CheckNetworkViewController alloc] init];
    vc.loginAgain = YES;
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

#pragma mark - 懒加载
- (NSMutableArray<NSString *> *)matchAccountList
{
    if (!_matchAccountList)
    {
        _matchAccountList = [NSMutableArray arrayWithCapacity:0];
    }
    return _matchAccountList;
}

#pragma mark - TableView DataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchAccountList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *historyAccountTBCellId = @"HistoryAccountTableViewCellId";
    NSUInteger rowIndex   = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyAccountTBCellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:historyAccountTBCellId];
    }
    if (self.matchAccountList.count > rowIndex)
    {
        cell.textLabel.text = self.matchAccountList[rowIndex];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex = indexPath.row;
    if (self.matchAccountList.count <= rowIndex)
    {
        return;
    }
    self.accountTF.text = self.matchAccountList[rowIndex];
    self.accountStr     = self.matchAccountList[rowIndex];
    [self configTableViewHidden:YES];
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
    [SVProgressHUD dismiss];
    [self enableLoginBtn:YES];
    [self configLoginBtnStyle:Button_normal];
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
            [CheckNetwork showCheckAlert];
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

#pragma mark -- 登录结果回调
- (void)login:(BOOL)isSuccess
    userToken:(NSString *)uToken
    errorCode:(int)eCode
{
    if (YES == isSuccess)
    {
        GosLog(@"登录成功！");
        // 登录成功后跳转
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self jumpToMainRootVC];
        });
        
        if (YES == m_isRememberPassword)
        {
            [GosLoggedInUserInfo savePassword:self.passwordStr];
        }
        [self saveToHistorySetWithAccount:self.accountStr];
        [GosLoggedInUserInfo saveAccount:self.accountStr];
        [GosLoggedInUserInfo saveUserToken:uToken];
        [GosLoggedInUserInfo saveServerArea:self.loginArea];
        [GosLoggedInUserInfo saveAutoLogin:m_isRememberPassword];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotify
                                                            object:nil];
    }
    else
    {
        GosLog(@"登录失败！");
        [self enableLoginBtn:YES];
        [self configLoginBtnStyle:Button_normal];
        switch (eCode)
        {
            case CONSDK_ERR_PARAM_ILLEGAL:  // 参数不合法
            {
                GosLog(@"登录失败，error：参数不合法");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"ParamIllegal")];
            }
                break;
                
            case CONSDK_ERR_USER_NOT_EXIST: // 用户不存在
            {
                GosLog(@"登录失败，error：用户不存在");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"AccountNotExist")];
            }
                break;
                
            case CONSDK_ERR_USER_NAME_ERROR:    // 用户名错误
            {
                GosLog(@"登录失败，error：用户名错误");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"UserNameError")];
            }
                break;
                
            case CONSDK_ERR_USER_PWD_ERROR: // 密码错误
            {
                GosLog(@"登录失败，error：密码错误");
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"PasswordError")];
            }
                break;
                
            default:    // 网络诊断
            {
                GosLog(@"登录失败，error：网络诊断");
                [self showCheckNetworkAlert];
            }
                break;
        }
    }
}
@end
