//
//  WiFiSettingOnlineVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "WiFiSettingOnlineVC.h"
#import "iOSConfigSDK.h"
#import "WiFiSettingOnlineCell.h"
#import "KKAlertView.h"
#import "AlertInputWiFiView.h"
#import "iOSConfigSDKModel.h"

@interface WiFiSettingOnlineVC ()<iOSConfigSDKParamDelegate,
UITableViewDelegate,
UITableViewDataSource,
AlertInputWiFiViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *wifiTableView;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) NSArray * dataSourceArr;   // 数据数组
@end

@implementation WiFiSettingOnlineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"WiFi_setting_online");
    [self configNetData];
    [self configTable];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configTable{
    self.wifiTableView.bounces = NO;
    self.wifiTableView.rowHeight = 44.0f;
    self.wifiTableView.tableFooterView = [UIView new];
    self.wifiTableView.backgroundColor = GOS_VC_BG_COLOR;
}
- (void)configNetData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqSsidListOfDevId:self.dataModel.DeviceId];
}

#pragma mark -- function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.wifiTableView reloadData];
    });
}
#pragma mark - actionFunction
#pragma mark - 请求设备附近 WiFi 列表结果回调
- (void)reqSsidInfo:(BOOL)isSuccess
           deviceId:(NSString *)devId
           wifiList:(NSArray <SsidInfoModel *>*)wList{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataSourceArr = wList;
        [self refreshUI];
    }else{
        [GosHUD showProcessHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 设置设备连接 WiFi结果回调
- (void)configConnSsid:(BOOL)isSuccess
              deviceId:(NSString *)devId{
    if (isSuccess) {
        [GosHUD showProcessHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showProcessHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}
#pragma mark - 输入WiFi密码设置回调
- (void)alertInputViewCallBack:(NSString *) wifiName
                      password:(NSString *) password{
    [self.configSdk configConnToSsid:wifiName password:password withDeviceId:self.dataModel.DeviceId];
}
#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SsidInfoModel * model = self.dataSourceArr[indexPath.row];
    AlertInputWiFiView *contentView = [AlertInputWiFiView initWithFrame:CGRectZero SSidName:model.wifiSsid delegate:self];
    [KKAlertView shareView].contentView = contentView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KKAlertView shareView] show];
    });
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [WiFiSettingOnlineCell cellWithTableView:tableView indexPath:indexPath cellModel:[self.dataSourceArr objectAtIndex:indexPath.row]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
#pragma mark - lazy
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
#pragma mark - lifestyle

@end
