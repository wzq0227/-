//
//  AddDeviceConfigViewController.m
//  GosIPCs
//
//  Created by 罗乐 on 2018/12/6.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AddDeviceConfigViewController.h"
#import "UIColor+GosColor.h"
#import "UIImage+Gif.h"
#import "iOSSmartSDK.h"
#import "iOSConfigSDK.h"
#import "GosLoggedInUserInfo.h"
#import "DeviceListViewController.h"
#import "UIAlertController+AddDeviceTip.h"

@interface AddDeviceConfigViewController () <
                                            iOSSmartDelegate,
                                            iOSConfigSDKDMDelegate
                                            >
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *configTipLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstStepLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondStepLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdStepLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *firstIndicator;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *secondIndicator;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *thirdIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *firstSuccessImgView;

@property (weak, nonatomic) IBOutlet UIImageView *secondSuccessImgView;

@property (weak, nonatomic) IBOutlet UIImageView *thridSuccessImgView;

@property (nonatomic, strong) iOSSmartSDK *smartSDK;

@property (nonatomic, strong) iOSConfigSDK *configSDK;

/** 用于网络检测后重新显示提示框 */
@property (nonatomic, assign)  BOOL isNeedShowTipView;

/** 设置WiFi和密码重复次数*/
@property (assign, nonatomic)  int setSSIDAndPwdCount;

/** 轮询设备是否已注册次数*/
@property (assign, nonatomic)  int checkIfDevRegisteredCount;
@end

@implementation AddDeviceConfigViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    
    if (self.addMethodType == SupportAdd_apNew) {
        [self getSSIDList];
    } else {
        [self startSmartLink];
    }
    [self startFirstStepAnimate];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.isNeedShowTipView) {
        [self showFailureAlertView];
    }
}

#pragma mark - UI相关
#pragma mark -- 配置ui
- (void)configUI {
    self.title = DPLocalizedString(@"AddDEV_Net_config");
    self.view.backgroundColor = [UIColor gosGrayColor];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"addDev_configuration" ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    self.imageView.image = [UIImage animatedGIFWithData:imageData];
    
    self.configTipLabel.text = DPLocalizedString(@"AddDEV_configTip");
    self.firstStepLabel.text = DPLocalizedString(@"AddDEV_FristStep");
    self.secondStepLabel.text = DPLocalizedString(@"AddDEV_SecondStep");
    self.thirdStepLabel.text = DPLocalizedString(@"AddDEV_ThirdStep");
}

#pragma mark -- 连接状态显示ui控制
- (void)startFirstStepAnimate {
    [self.firstIndicator startAnimating];
    self.firstIndicator.hidden = NO;
    self.firstSuccessImgView.hidden = YES;
    self.secondIndicator.hidden = YES;
    self.secondSuccessImgView.hidden = YES;
    self.thirdIndicator.hidden = YES;
    self.thridSuccessImgView.hidden = YES;
}

- (void)firstStepSuccess {
    [self.firstIndicator stopAnimating];
    self.firstIndicator.hidden = YES;
    self.firstSuccessImgView.hidden = NO;
}

- (void)startSecondStepAnimate {
    [self.secondIndicator startAnimating];
    self.secondIndicator.hidden = NO;
}

- (void)secondStepSuccess {
    [self.secondIndicator stopAnimating];
    self.secondIndicator.hidden = YES;
    self.secondSuccessImgView.hidden = NO;
}

- (void)startThirdStepAnimate {
    [self.thirdIndicator startAnimating];
    self.thirdIndicator.hidden = NO;
}

- (void)thirdStepSuccess {
    [self.thirdIndicator stopAnimating];
    self.thirdIndicator.hidden = YES;
    self.thridSuccessImgView.hidden = NO;
}

#pragma mark - 显示提示框
#pragma mark -- 显示提示并跳转
- (void)showAlertViewWithMessage:(NSString *)messasge PopToViewControllerClass:(Class)aClass{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:messasge preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *knownAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"AddDEV_GotIt") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self popToViewControllerWithClass:aClass];
            
        }];
        [alertController addAction:knownAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark -- 显示失败提示框
- (void)showFailureAlertView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isNeedShowTipView = YES;
        UIAlertController *alertView = [UIAlertController AddFailedAlertControllerWithNavigationController:self.navigationController];
        [self.navigationController presentViewController:alertView
                                                animated:YES
                                              completion:nil];
    });
}

#pragma mark -- 显示成功并跳转回设备列表页
- (void) showSuccessAndJumpToDeviceListVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:3
                         animations:^{
                             [SVProgressHUD showSuccessWithStatus:DPLocalizedString(@"AddDEV_CofigSuccess")];
                         }
                         completion:^(BOOL finished) {
                             [self popToViewControllerWithClass:[DeviceListViewController class] SuccessBlock:^(UIViewController *controller) {
                                 DeviceListViewController *vc = (DeviceListViewController *)controller;
                                 vc.isAddSuccess = YES;
                             }];
                         }];
        
    });
}

#pragma mark - smart link 相关
#pragma mark -- 开始smartLink
- (void)startSmartLink {
    self.smartSDK.delegate = self;
    BOOL isWifiAdd = self.addMethodType == SupportAdd_wifi;
    [self.smartSDK smartLinkByWifi:self.devModel.wifiName
                      withPassowrd:self.devModel.wifiPWD
                          deviceId:self.devModel.devId
                         isWifiAdd:isWifiAdd];
}

#pragma mark -- smartLink结果回调
- (void)smartLinkResult:(SmartLinkStatus)slStatus {
    switch (slStatus) {
        case SmartLink_start:
            GosLog(@"smartlink  正在连接");
            break;
        case SmartLink_success:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self firstStepSuccess];
                [self startSecondStepAnimate];
            });
            if (self.devModel.bStatus == DevBind_binded) {
                [self unBind];
            } else {
                [self bind];
            }
        }
            break;
        case SmartLink_failure:
            [self showFailureAlertView];
            break;
        default:
            break;
    }
}

#pragma mark - ap添加相关
#pragma mark -- 请求设备wifi列表信息
//MARK:旧AP模式为连接设备热点，获取设备周围wifi列表信息，选取需要的wifi进行配置；
//     新ap模式不需要wifi列表信息，只使用手机当前连接的wifi，但是为了让设备关闭热点，需要进行一次请求。
- (void)getSSIDList {
    [self.smartSDK queryWifiListWithDevId:self.devModel.devId timeout:120000];
}

#pragma mark -- 请求设备wifi列表信息回调
- (void)reqWIFI:(BOOL)isSuccess
           list:(SmartWifiList *)wifiList {
    if (isSuccess) {
        self.setSSIDAndPwdCount = 0;
        [self configDeviceSSIDAndPWD];
    } else {
        [self showFailureAlertView];
    }
}

#pragma mark -- 配置设备连接wifi名和密码
- (void)configDeviceSSIDAndPWD {
    [self.smartSDK configDeviceId:self.devModel.devId connToWifi:self.devModel.wifiName withPassword:self.devModel.wifiPWD timeout:36000];
}

#pragma mark -- 配置设备连接wifi名和密码回调
- (void)connToWifi:(BOOL)isSuccess {
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self firstStepSuccess];
            [self startSecondStepAnimate];
            [self getDevInfo];
        });
    } else {
        if (self.setSSIDAndPwdCount <= 2) {
            self.setSSIDAndPwdCount++;
            [self configDeviceSSIDAndPWD];
        } else {
            [self showFailureAlertView];
        }
    }
}

#pragma mark -- 获取设备信息
- (void)getDevInfo {
    [self.smartSDK extractInfoWithDevId:self.devModel.devId timeout:36000];
}

#pragma mark -- 获取设备信息回调
- (void)isExtract:(BOOL)isSuccess
       forDevInfo:(LanDeviceInfoModel *)devInfo {
    if (isSuccess) {
        //判断是否恢复出厂设置开启硬解绑
        if (!devInfo.supportForceUnBind && self.devModel.bStatus == DevBind_binded) {
            //设备已被绑定且未恢复出厂设置开启硬解绑
            [self showAlertViewWithMessage:DPLocalizedString(@"AddDEV_Restore_tip") PopToViewControllerClass:[DeviceListViewController class]];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self firstStepSuccess];
                [self startSecondStepAnimate];
            });
            
            self.checkIfDevRegisteredCount = 0;
            [self queryDevRegisterStatus];
        }
    } else {
        [self showFailureAlertView];
    }
}

#pragma mark -- 查询设备是否连接到服务器
- (void)queryDevRegisterStatus{
    if (self.checkIfDevRegisteredCount >= 9) {
        [self showFailureAlertView];
        return ;
    }
    self.checkIfDevRegisteredCount++;
    
    [self.configSDK queryRegistWithDevId:self.devModel.devId account:[GosLoggedInUserInfo account]];
}
#pragma mark -- 查询设备是否连接到服务器回调
- (void)queryRegist:(BOOL)isSuccess deviceId:(NSString *)devId account:(NSString *)account status:(BOOL)isRegist errorCode:(int)eCode {
    if (isSuccess) {
        if (isRegist) {
            if (self.devModel.bStatus == DevBind_binded) {
                [self unBind];
            } else {
                [self bind];
            }
        } else {
            [self queryDevRegisterStatus];
        }
    } else {
        //获取失败说明手机仍连接在设备热点，延迟5秒再次检查
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self queryDevRegisterStatus];
        });
    }
}

#pragma mark - 设备绑定
#pragma mark -- 强制解绑
- (void)unBind {
    [self.configSDK forceUnbindDeviceId:self.devModel.devId];
}

#pragma mark -- 强制解绑回调
- (void)forceUnBind:(BOOL)isSuccess
           deviceId:(NSString *)devId
          errorCode:(int)eCode {
    if (isSuccess) {
        [self bind];
    } else {
        if (eCode == CONSDK_ERR_UN_BINDED) {
            [self bind];
        } else {
            [self showFailureAlertView];
        }
    }
}
#pragma mark -- 开始绑定
- (void)bind {
    DevDataModel *devModel = [[DevDataModel alloc] init];
    devModel.DeviceId = self.devModel.devId;
    devModel.DeviceName = self.devModel.devName;
    devModel.DeviceType = self.devModel.devType;
    devModel.DeviceOwner = DevOwn_owner;
    [self.configSDK bindDevice:devModel toAccount:[GosLoggedInUserInfo account]];
}

#pragma mark -- 绑定回调
- (void)bind:(BOOL)isSuccess
    deviceId:(NSString *)devId
   errorCode:(int)eCode {
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self secondStepSuccess];
            [self startThirdStepAnimate];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self thirdStepSuccess];
            [self showSuccessAndJumpToDeviceListVC];
        });
    } else {
        switch (eCode) {
            case CONSDK_ERR_OWNER_ERROR:{
                [self showAlertViewWithMessage:DPLocalizedString(@"AddDEV_Restore_tip") PopToViewControllerClass:[DeviceListViewController class]];
            }
                break;
            case CONSDK_ERR_DEV_IS_BINDED:{
                [self showAlertViewWithMessage:DPLocalizedString(@"AddDEV_BeBind_tip") PopToViewControllerClass:[DeviceListViewController class]];
            }
                break;
            default:
                [self showFailureAlertView];
                break;
        }
    }
}

#pragma mark - 页面跳转
#pragma mark -- 根据view的class跳转、
- (void)popToViewControllerWithClass:(__unsafe_unretained Class)aClass {
    [self popToViewControllerWithClass:aClass SuccessBlock:nil];
}

- (void)popToViewControllerWithClass:(__unsafe_unretained Class)aClass SuccessBlock:(void(^)(UIViewController *controller))successBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *target = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:aClass]) {
                target = controller;
            }
        }
        if (target) {
            successBlock(target);
            [self.navigationController popToViewController:target animated:NO];
        }
    });
}

#pragma mark - 懒加载
- (iOSSmartSDK *)smartSDK {
    if (_smartSDK == nil) {
        _smartSDK = [iOSSmartSDK shareSmartSdk];
        _smartSDK.delegate = self;
    }
    return _smartSDK;
}

- (iOSConfigSDK *)configSDK {
    if (_configSDK == nil) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.dmDelegate = self;
    }
    return _configSDK;
}
@end
