//
//  DeviceInfoVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//  设备信息界面

#import "DeviceInfoVC.h"
#import "DeviceInfoCell.h"
#import "TableViewHeadView.h"
#import "DeviceInfoNameVC.h"
#import "iOSConfigSDK.h"
#import "DeviceInfoModel.h"
#import "DeviceInfoViewModel.h"
#import "DeviceInfoFootView.h"
#import "iOSConfigSDKModel.h"
#import "DeviceUpgradeView.h"
#import "KKAlertView.h"


@interface DeviceInfoVC ()<UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKParamDelegate,
DeviceUpgradeViewDelegate,
DeviceInfoNameVCDelegate>
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (weak, nonatomic) IBOutlet UITableView *deviceInfoTableview;
@property (nonatomic, strong) NSArray * dataSourceArr;   /// 数据数组
@property (nonatomic, strong) UIView * tableFootView;   ///  tablefoot
@property (nonatomic, strong) DevInfoModel * devInfoModel;   /// 整个设备模型
@property (nonatomic, strong) DevFirmwareInfoModel *firmwareInfo;   /// 设备固件版本信息模型
@property (nonatomic, strong) DeviceUpgradeView * upgradeView;      /// 升级进度View
@property (nonatomic, strong) NSTimer     *updateProgressTimer;      /// 定时器
@property (nonatomic, assign) UpdateStage updateStage;        ///  更新阶段
@property (nonatomic, assign) int updateStageResult;    /// 设备端返回的result
@end

@implementation DeviceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Setting_DeviceInfo");
    [self configTable];
    [self configNetSdk];
    self.updateStage = UpdateStageBegin;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configTable{
    self.deviceInfoTableview.bounces = NO;
    self.deviceInfoTableview.rowHeight = 50.0f;
    DeviceInfoFootView * footView = [[DeviceInfoFootView alloc] init];
    [footView.formatSDcardBtn addTarget:self action:@selector(formatSDClick) forControlEvents:UIControlEventTouchUpInside];
    self.tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 150)];
    [self.tableFootView addSubview:footView];
    self.deviceInfoTableview.tableFooterView = self.tableFootView;
    [self.tableFootView setHidden:YES];
}
- (void)configNetSdk{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqInfoOfDevId:self.dataModel.DeviceId];
}
#pragma mark -- function
- (void)setDataModel:(DevDataModel *)dataModel{
    _dataModel = dataModel;
}
- (void)refreshUI{
    BOOL hasSdCard = NO;
    GOS_WEAK_SELF;
    for (DeviceInfoTypeModel * mm in self.dataSourceArr) {
        if ([mm.sectionTitleStr isEqualToString:DPLocalizedString(@"DevInfo_SDCard")]) {
            hasSdCard = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf.deviceInfoTableview reloadData];
        if (!hasSdCard) {
            [strongSelf.tableFootView setHidden:YES];
        }else{
            [strongSelf.tableFootView setHidden:NO];
        }
    });
}
#pragma mark - 取消升级点击
- (void)DeviceUpgradeCancel{
    [self stopProgressTimer];
    //    if (self.updateStageResult < 130) {
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk cancelUpdateFirmwareOfDevice:self.dataModel.DeviceId upsAddress:self.firmwareInfo.upsIp upsPort:self.firmwareInfo.upsPort];
    //    }else{
    //        [self alertTipsViewWithTitle:@"" message:@"升级被中断" cancelTitle:@"确定"];
    //        [[KKAlertView shareView] hide];
    //    }
}
#pragma mark -- actionFunction
- (void)formatSDClick{
    GosLog(@"格式化SD卡点击");
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"Format_SD_card") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleDefault handler:nil];
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    GOS_WEAK_SELF;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        GOS_STRONG_SELF;
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"Format_SD_Warning")];
        [strongSelf.configSdk formatSdCarOfDevice:self.dataModel.DeviceId];
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x4D4D4D) forKey:@"titleTextColor"];
    }
    [alertview addAction:defultAction];
    [alertview addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf presentViewController:alertview animated:YES completion:nil];
    });
}
#pragma mark - 格式化SD卡回调
- (void)formatSdCard:(BOOL)isSuccess
            deviceId:(NSString *)devId
           sdCarInfo:(SdCardInfoModel*)cardInfo{
    [GosHUD dismiss];
    if (isSuccess) {
        self.dataSourceArr = [DeviceInfoViewModel modifyTFCardData:self.dataSourceArr andSdCardInfoModel:cardInfo];
        [self refreshUI];
        [self alertTipsViewWithTitle:DPLocalizedString(@"Format_SD_card_success") message:@"" cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
    }else{
        [self alertTipsViewWithTitle:DPLocalizedString(@"Format_SD_card_unsuccess") message:@"" cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
    }
}
#pragma mark - 处理升级信息
- (void)handleUpgradeData{
    if (self.firmwareInfo.hasNewer) {
        self.dataSourceArr = [DeviceInfoViewModel modifyModelData:self.dataSourceArr];
        [self refreshUI];
    }
}
//@param isSuccess 是否开始升级成功；YES：成功，NO：失败
//@param result 升级进度结果【说明】如下：
//0：准备开始升级；
//1：由于申请内存失败导致升级失败
//2：由于创建线程失败导致升级失败
//3：升级过程中出错
//4、5：升级完成
//100~200：表示升级进度百分比（如 108 表示当前升级进度 8%），其中 100~130 会实时回调回来，超过了 30% 时，由于设备下载固件成功，安装后需要重启，所以无法继续回调进度，因此 APP 端需要使用定时器模拟后面 30%~100% 的进度，当接收到 4、5 时，表明设备s安装固件并重启成功，表明升级完成
//@param devId 设备 ID
#pragma mark - 处理设备升级数据
- (void)handleUpgradeResultData:(int) result{
    GosLog(@"升级返回进度数据 = %d",result);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.upgradeView setUpgradeResult:result andUpdateStage:self.updateStage];
    });
    self.updateStageResult = result;
    [self.upgradeView setUpgradeResult:result];     /// 将实时请求到的数据传入progressView
    if (result == 0) {      ///  开始准备升级，这个时候给出弹框
        [self showUpdateProgressView];
    }else if(result>=100 && result<=200){
        if (result >= 130) {        ///  做假数据  进度条自己走
            self.updateStage = UpdateStageUpdating;
        }else{                      /// 真实进度条
            
        }
    }else if(result == 3){
        if (_updateStage == UpdateStageDownloading ||
            _updateStage == UpdateStageUpdating) {
            [self showUpdateErrorInfo];     ///  弹出更新失败提示
        }
    }else if(result == 4 || result ==5){     ///    升级成功处理
        self.updateStage = UpdateStageSucceeded;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showUpdateSuccessInfo];
        });
    }else if(result <= 2){      ///1->请求下载失败，申请内存失败 2->请求下载失败,设备端创建线程失败
        [self showUpdateErrorInfo];
    }
    
}
#pragma mark - 显示升级进度条view
- (void)showUpdateProgressView{
    /// 防止设备端在升级下载的2,3阶段，突然返回一个0
    if (self.updateStage == UpdateStageDownloading ||
        self.updateStage == UpdateStageUpdating ||
        self.updateStage == UpdateStageSucceeded ||
        self.updateStage == UpdateStageFailed) {
        return;
    }
    self.updateStage = UpdateStageDownloading;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUpdateView];
        [self startUpdateProgressTimer];
    });
}
- (void)showUpdateView{
    self.upgradeView = [[DeviceUpgradeView alloc] init];
    self.upgradeView.delegate = self;
    [KKAlertView shareView].contentView = self.upgradeView;
    [[KKAlertView shareView] show];
}
- (void)startUpdateProgressTimer{
    if(!_updateProgressTimer){
        _updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateProgressTiemrFunc:) userInfo:nil repeats:YES];
    }
}
- (void)updateProgressTiemrFunc:(id)sender{
    [self.configSdk startUpdateFirmwareOfDevice:self.dataModel.DeviceId upsAddress:self.firmwareInfo.upsIp upsPort:self.firmwareInfo.upsPort];
}
- (void)stopProgressTimer{
    if([_updateProgressTimer isValid]){
        [_updateProgressTimer invalidate];
        _updateProgressTimer = nil;
    }
}
#pragma mark - 升级失败弹框
- (void)showUpdateErrorInfo{
    self.updateStage = UpdateStageFailed;
    [self alertTipsViewWithTitle:@"" message:DPLocalizedString(@"Update_UpdateError_TryAgainLater") cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
    GosLog(@"给出弹框，升级失败");
}
- (void)showUpdateSuccessInfo{
    GOS_WEAK_SELF;
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:@"" message:DPLocalizedString(@"Update_Tips_DowloadComplete") preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction * cancelAction=[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            [strongSelf.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
    [alertview addAction:defaultAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf stopProgressTimer];
        [strongSelf presentViewController:alertview animated:YES completion:nil];
    });
    
    //    [self alertTipsViewWithTitle:@"" message:@"下载成功，摄像机稍后将自动重启进行升级，请耐心等待" cancelTitle:@"确定"];
}

#pragma mark - 弹出固件升级的框
- (void)showAlertView{
    NSString *  message = [NSString stringWithFormat:@"%@ \n%@\n%@",DPLocalizedString(@"update_to"),self.firmwareInfo.version,self.firmwareInfo.updateDes];
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"Update_FirmwareUpdate") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    //修改按钮
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x999999) forKey:@"titleTextColor"];
    }
    GOS_WEAK_SELF;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"Update_UpdateRightNow") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        GOS_STRONG_SELF;
        [strongSelf initUpdateNow];
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    [alertview addAction:cancelAction];
    [alertview addAction:defultAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf presentViewController:alertview animated:YES completion:nil];
    });
}
- (void)initUpdateNow{
    [self.configSdk startUpdateFirmwareOfDevice:self.dataModel.DeviceId upsAddress:self.firmwareInfo.upsIp upsPort:self.firmwareInfo.upsPort];
}
#pragma mark - 代理数据回调
#pragma mark - 请求设备信息结果回调
- (void)reqDevInfo:(BOOL)isSuccess
          deviceId:(NSString *)devId
              info:(DevInfoModel *)infoModel{
    [GosHUD dismiss];
    if (isSuccess) {
        self.devInfoModel = infoModel;
        self.dataSourceArr = [DeviceInfoViewModel handleDeviceInfoModel:infoModel
                                                           DevDataModel:self.dataModel];
        /// 只有获取到设备信息才能去请示是否可升级
        [self.configSdk checkFirmwareOfDevice:self.dataModel.DeviceId forCurSWVersion:self.devInfoModel.swVersion curHWVersion:self.devInfoModel.hwVersion];
        [self refreshUI];
    }else{
        /// 请求数据失败，就只显示设备名和设备ID
        self.dataSourceArr = [DeviceInfoViewModel handleTableArrOFFLineModel:self.dataModel];
        [self refreshUI];
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 查询设备固件版本信息结果回调
- (void)checkFirmware:(BOOL)isSuccess
         firmwareInfo:(DevFirmwareInfoModel *)firmwareInfo
             deviceId:(NSString *)devId
            errorCode:(int)eCode{
    if (isSuccess) {
        self.firmwareInfo = firmwareInfo;
        [self handleUpgradeData];
    }
}
#pragma mark - 开始升级设备固件版本信息结果回调
- (void)startUpdateFirmware:(BOOL)isSuccess
               updateResult:(int)result
                   deviceId:(NSString *)devId{
    if (isSuccess) {
        [self handleUpgradeResultData:result];    /// 升级返回结果处理
    }else{
        if (self.updateStage == UpdateStageFailed) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KKAlertView shareView] hide];
        });
        self.updateStage = UpdateStageFailed;
        [self alertTipsViewWithTitle:@"" message:DPLocalizedString(@"Update_DownloadErrorTryAgain") cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
        GosLog(@"升级过程中出现失败");
    }
}
#pragma mark - 取消升级设备固件版本信息结果回调
- (void)cancelUpdateFirmware:(BOOL)isSuccess
                updateResult:(int)result
                    deviceId:(NSString *)devId{
    [GosHUD dismiss];
    [[KKAlertView shareView] hide];
    self.updateStage = UpdateStageBegin;
    if (isSuccess) {
        [self alertTipsViewWithTitle:DPLocalizedString(@"Update_CancelSucceeded") message:@"" cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
        GosLog(@"取消升级成功");
    }else{
        [self alertTipsViewWithTitle:DPLocalizedString(@"Update_CancelUnSucceeded") message:@"" cancelTitle:DPLocalizedString(@"GosComm_Confirm")];
        GosLog(@"取消升级失败");
    }
}
#pragma mark - 弹框
- (void)alertTipsViewWithTitle:(NSString *) title
                       message:(NSString *) message
                   cancelTitle:(NSString *) cancelTitle{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction=[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil];
    [alertview addAction:cancelAction];
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        [strongSelf stopProgressTimer];
        [strongSelf presentViewController:alertview animated:YES completion:nil];
    });
}
#pragma mark - 修改设备名回调代理
- (void)modifyDeviceName:(DevDataModel *)dataModel{
    [DeviceInfoViewModel modifyDeviceName:dataModel.DeviceName tableArr:self.dataSourceArr];
    [self refreshUI];
}
#pragma mark - tableview&delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DeviceInfoTypeModel * model = [self.dataSourceArr objectAtIndex:section];
    return [model.sectionDataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTypeModel * model = [self.dataSourceArr objectAtIndex:indexPath.section];
    return [DeviceInfoCell cellWithTableView:tableView indexPath:indexPath infoModel:[model.sectionDataArr objectAtIndex:indexPath.row]];
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TableViewHeadView * headView = [[TableViewHeadView alloc] init];
    DeviceInfoTypeModel * model = [self.dataSourceArr objectAtIndex:section];
    [headView setTitleStr:model.sectionTitleStr];
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTypeModel * model = [self.dataSourceArr objectAtIndex:indexPath.section];
    DeviceInfoModel * infoModel = model.sectionDataArr[indexPath.row];
    if ([model.sectionTitleStr isEqualToString:DPLocalizedString(@"DevInfo_DevName")]) {
        DeviceInfoNameVC * vc = [[DeviceInfoNameVC alloc] init];
        vc.dataModel = self.dataModel;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([infoModel.titleStr isEqualToString:DPLocalizedString(@"system_firmware")] && self.firmwareInfo.hasNewer) {
        [self showAlertView];
    }
}
#pragma mark -- lazy
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
    }
    return _configSdk;
}
#pragma mark -- lifestyle
-(void)dealloc{
    GosLog(@"---%s---",__PRETTY_FUNCTION__);
}
@end
