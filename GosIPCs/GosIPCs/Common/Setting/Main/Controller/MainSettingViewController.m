//
//  MainSettingViewController.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MainSettingViewController.h"
#import "MainSettingCell.h"
#import "iOSConfigSDK.h"
#import "MainSettingModel.h"
#import "MainSettingFootView.h"
#import "MainSettingViewModel.h"
#import "PackageValidTimeApiManager.h"  // 获取云存储套餐API
#import "PackageValidTimeApiRespModel.h"    //  云存储套餐model
#import "ThirdAccessVC.h"       //  alex 第三方接入
#import "BabyMusicVC.h"         //  babymusic 音乐播放
#import "NightVersionVC.h"      //  夜视
#import "TempAlarmVC.h"         //  温度报警
#import "MotionDetectSettingVC.h"   //  移动侦测 运动检测
#import "VoiceDetectVC.h"       //  声音侦测
#import "DeviceInfoVC.h"        //  设备信息
#import "TimeCheckVC.h"         //  时间校验
#import "CloudServiceVC.h"      //  云录制套餐
#import "CloudPackageDetailVC.h"// 套餐详情界面
#import "WiFiSettingVC.h"       //  WiFi设置
#import "LightDurationVC.h"     //  灯照时长
#import "SettingPhotoAlbumVC.h" //  用户相册
#import "AddSensorVC.h"         //  添加传感器
#import "SceneTaskVC.h"         //  情景任务
#import "ShareWithFriendsVC.h"  //  好友分享
#import "PushStatusMananger.h"  //  获取推送状态
#import "APNSManager.h"         //  移除设备推送
#import "GosDevManager.h"       //  设备管理器
#import "DevAbilityManager.h"   //  设备能力集管理类
@interface MainSettingViewController ()
<iOSConfigSDKParamDelegate,
iOSConfigSDKDMDelegate,
UITableViewDelegate,
UITableViewDataSource,
MainSettingCellDelegate,
iOSConfigSDKIOTDelegate,
GosApiManagerCallBackDelegate,
iOSConfigSDKABDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainSettingTableview;
@property (nonatomic, strong) iOSConfigSDK *configSdk;
@property (nonatomic, strong) NSArray <NSMutableArray *>* dataSourceArr;   // 数据数组
@property (nonatomic, strong) UIView * tableFootView;  // 脚视图
@property (nonatomic, strong) AllParamModel * allParamModel;   // 所有开关能力集
@property (nonatomic, strong) AbilityModel * abilityModel;   // 设备能力集
/// 获取云存储套餐时长 Api
@property (nonatomic, strong) PackageValidTimeApiManager *packageValidTimeApiManager;

@end

@implementation MainSettingViewController

#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self loadAbilityCache];
    [self configSensorTask];  // 获取情景任务能力集
    [self configPackageValid];  //  获取云储存时长
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark -- config
- (void) configUI{
    self.title = DPLocalizedString(@"Setting_SettingTitle");
    self.mainSettingTableview.rowHeight = 44.0f;
    self.mainSettingTableview.tableFooterView = self.tableFootView;
    self.mainSettingTableview.backgroundColor = GOS_VC_BG_COLOR;
    self.mainSettingTableview.bounces = NO;
}

#pragma mark -- 加载已缓存好的能力集
- (void)loadAbilityCache
{
    self.abilityModel =  [DevAbilityManager abilityOfDevice:self.devModel.DeviceId];
    if (self.abilityModel)
    {
        self.dataSourceArr = [MainSettingViewModel handleTableDataModel:self.abilityModel
                                                           devDataModel:self.devModel];
        [self refreshTable];
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        /// 请求到能力集后再请求开关状态  请求一
        [self.configSdk reqAllParamOfDevId:self.devModel.DeviceId];
        /// 请求夜视开关状态            请求二
        [self.configSdk reqNightVisionWithDevId:self.devModel.DeviceId];
    }
    else
    {
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        [self addReqAbilityNotify];
        /// 请求能力集    请求三
        [self.configSdk reqAbilityOfDevId:self.devModel.DeviceId];
    }
}
- (void) configPackageValid{
    [self.packageValidTimeApiManager loadDataWithDeviceId:self.devModel.DeviceId];
}

#pragma mark -- 请求能力集结果通知
- (void)addReqAbilityNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(abilityResult:)
                                                 name:kAddAbilityNotify
                                               object:nil];
}

- (void)abilityResult:(NSNotification *)notifyData
{
    NSDictionary *recvDict = notifyData.object;
    if (!recvDict || NO == [[recvDict allKeys] containsObject:@"DeviceID"])
    {
        return;
    }
    NSString *deviceId  = recvDict[@"DeviceID"];
    if ([deviceId isEqualToString:self.devModel.DeviceId])
    {
        GosLog(@"这是设置界面已获得设备（ID = %@）能力集请求结果通知！", deviceId);
        [SVProgressHUD dismiss];
        self.abilityModel =  [DevAbilityManager abilityOfDevice:deviceId];
        if (self.abilityModel)
        {
            self.dataSourceArr = [MainSettingViewModel handleTableDataModel:self.abilityModel
                                                               devDataModel:self.devModel];
            [self refreshTable];
            [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
            /// 请求到能力集后再请求开关状态   请求一
            [self.configSdk reqAllParamOfDevId:self.devModel.DeviceId];
            /// 请求夜视开关状态            请求二
            [self.configSdk reqNightVisionWithDevId:self.devModel.DeviceId];
        }
    }
}
#pragma mark - 获取情景任务
- (void)configSensorTask{
    /// 请求服务器列表   请求四
    [self.configSdk reqIotSensorListOfDevice:self.devModel.DeviceId
                                   onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark -- function
- (void)refreshTable{
    GosLog(@"已有能力集数据，开始刷新设置界面！");
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.mainSettingTableview reloadData];
    });
}
#pragma mark -- 删除设备
- (void)delectDevice{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:@"" message:DPLocalizedString(@"Setting_DeleteDeviceTips") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel")
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    __weak typeof(self) weakSelf = self;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
                                                             [weakSelf performDeleteOperation];
                                                             GosLog(@"点击删除设备");
                                                         }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x4D4D4D) forKey:@"titleTextColor"];
    }
    [alertview addAction:defultAction];
    [alertview addAction:cancelAction];
    [self presentViewController:alertview animated:YES completion:nil];
    
    
}
#pragma mark -- 执行删除操作
- (void)performDeleteOperation{
    GOS_WEAK_SELF;
    // 如果设备推送是打开的
    if([PushStatusMananger pushModelOfDevice:self.devModel.DeviceId].PushFlag){
        GOS_STRONG_SELF;
        // 关闭设备推送功能
        [APNSManager closePushWithDevId:self.devModel.DeviceId
                                 result:^(BOOL isSuccess) {
                                     if (isSuccess) {
                                         /// 解绑删除设备   请求五
                                         [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
                                         [strongSelf.configSdk unBindDevice:strongSelf.devModel fromAccount:[GosLoggedInUserInfo account]];
                                     }
                                 }];
    }else{
        /// 解绑删除设备   请求五
        GOS_STRONG_SELF
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        [strongSelf.configSdk unBindDevice:strongSelf.devModel fromAccount:[GosLoggedInUserInfo account]];
    }
}
#pragma mark -- 请求设备开关集回调   请求一回调
- (void)reqAllParam:(BOOL)isSuccess
           deviceId:(NSString *)devId
              param:(AllParamModel *)paramModel
{
    [GosHUD dismiss];
    if (isSuccess) {
        self.allParamModel = paramModel;
        if (self.dataSourceArr.count > 0) {
            self.dataSourceArr = [MainSettingViewModel updateTableDataArr:self.dataSourceArr
                                                            allParamModel:paramModel];
            [self refreshTable];
        }
    }
}
#pragma mark - 请求夜视参数结果回调   请求二回调
- (void)reqNightVision:(BOOL)isSuccess
              deviceId:(NSString *)devId
               nvParam:(NightVisionModel *)nvModel{
    [GosHUD dismiss];
    if (isSuccess) {
        [MainSettingViewModel updateNightVersionWithDataArr:self.dataSourceArr
                                           nightVisionModel:nvModel];
        [self refreshTable];
    }else{
        //        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 获取能力集回调   请求三回调
- (void)reqAbility:(BOOL)isSuccess
          deviceId:(NSString *)devId
           ability:(AbilityModel *)abModel{
    if (isSuccess) {
        self.dataSourceArr =nil;
        self.abilityModel = abModel;
        self.dataSourceArr = [MainSettingViewModel handleTableDataModel:self.abilityModel
                                                           devDataModel:self.devModel];
        [self refreshTable];
        /// 请求到能力集后再请求开关状态  请求一
        [self.configSdk reqAllParamOfDevId:self.devModel.DeviceId];
        /// 请求夜视开关状态   请求二
        [self.configSdk reqNightVisionWithDevId:self.devModel.DeviceId];
    }else{
        self.dataSourceArr =nil;
        // 没有请求道能力集，就要默认给出4个能力集
        self.dataSourceArr = [MainSettingViewModel getDefaultAbilityDevModel:self.devModel];
        [self refreshTable];
    }
}
#pragma mark - 请求 IOT-传感器列表结果回调(服务器端)  请求四回调
- (void)reqIot:(BOOL)isSuccess
    sensorList:(NSArray<IotSensorModel *>*)sList
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        [MainSettingViewModel hasSensorTaskModel:sList
                                    tableDataArr:self.dataSourceArr
                                    devDataModel:self.devModel];
        [self refreshTable];
    }else{
        
    }
}
#pragma mark --  解绑设备回调   请求五回调
- (void)unBind:(BOOL)isSuccess
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [GosHUD dismiss];
    GOS_WEAK_SELF;
    if (isSuccess) {
        [self removeCacheData];
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteDeviceNotify object:nil];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"cloudShare_delete_fail")];
        });
    }
}

- (void) removeCacheData{
    [GosDevManager delDevice:self.devModel];
    [DevAbilityManager rmvAbilityFromDevice:self.devModel.DeviceId];
    [MediaManager cleanOfDevice:self.devModel.DeviceId
                     deviceType:(GosDeviceType)self.devModel.DeviceType];
}
#pragma mark -- 设置开关属性结果回调    请求六回调
- (void)configSwitch:(BOOL)isSuccess
                type:(SwitchType)sType
            deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (isSuccess) {
        //        [GosHUD showScreenfulHUDSuccessWithStatus:DPLocalizedString(@"GosComm_Set_Succeeded")];
    }else{
        /// 改变状态失败，重新请求开关状态  请求一
        [self.configSdk reqAllParamOfDevId:self.devModel.DeviceId];
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}
#pragma mark -- 设置视频模式结果回调  请求七回调
- (void)configVideoMode:(BOOL)isSuccess
               deviceId:(NSString *)devId{
    [GosHUD dismiss];
    if (!isSuccess) {
        /// 改变状态失败，重新请求开关状态  请求一
        [self.configSdk reqAllParamOfDevId:self.devModel.DeviceId];
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_Set_Failed")];
    }
}
#pragma mark -- actionFunction
#pragma mark - GosApiManagerCallBackDelegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *)manager {
    if (manager == self.packageValidTimeApiManager) {
        PackageValidTimeApiRespModel * result = [manager fetchDataWithReformer:self.packageValidTimeApiManager];
        [MainSettingViewModel updateValidCloudSerVice:self.dataSourceArr
                                    packageCloudModel:result];
    }
}
- (void)managerCallApiDidFailed:(GosApiBaseManager *)manager {
    GosLog(@"%s error: %@", __PRETTY_FUNCTION__, manager.errorMessage);
    if (manager == self.packageValidTimeApiManager) {
        [MainSettingViewModel updateValidCloudSerVice:self.dataSourceArr
                                    packageCloudModel:nil];
        [self refreshTable];
    }
}
#pragma mark -- cell switch 状态改变代理
- (void)cellSwitchDidChangeState:(MainSettingCell *) settingCell{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    switch (settingCell.cellModel.settingType) {
        case SettingType_CameraSwitch:{     //  摄像头开关   请求六
            [self.configSdk configSwitch:Switch_camera
                                   state:settingCell.cellModel.switchState
                               withDevId:self.devModel.DeviceId];
        }break;
        case SettingType_CameraMicrophone:{ //  麦克风开关  请求六
            [self.configSdk configSwitch:Switch_mic
                                   state:settingCell.cellModel.switchState
                               withDevId:self.devModel.DeviceId];
        }break;
        case SettingType_StatusIndicator:{      //  状态指示灯   请求六
            [self.configSdk configSwitch:Switch_statusLamp
                                   state:settingCell.cellModel.switchState
                               withDevId:self.devModel.DeviceId];
        }break;
        case SettingType_ManualRecord:{      //  手动录像    请求六
            [self.configSdk configSwitch:Switch_manualRecord
                                   state:settingCell.cellModel.switchState
                               withDevId:self.devModel.DeviceId];
        }break;
        case SettingType_PIRDetection:{      //  状态指示灯   请求六
            [self.configSdk configSwitch:Switch_pirDetect
                                   state:settingCell.cellModel.switchState
                               withDevId:self.devModel.DeviceId];
        }break;
        case SettingType_RotateSemicircle:{     //  旋转180度  请求七
            VideoMode tempVideoMode = Video_normal;
            if (settingCell.settingSwitch.on) {
                tempVideoMode = Video_mirror;
            }
            [self.configSdk configVideoMode:tempVideoMode
                                  withDevId:self.devModel.DeviceId];
        }
        default:
            break;
    }
}
#pragma mark -- delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MainSettingModel * model =[[self.dataSourceArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch (model.settingType) {
        case SettingType_Alexa:         //  ALEX
        case SettingType_BabyMusic:     //  音乐播放
        case SettingType_NightVersion:  //  夜视
        case SettingType_TempAlarmSetting:  //  温度报警
        case SettingType_MotionDetection:   //  移动侦测
        case SettingType_VoiceDetection:    //  声音报警
        case SettingType_TimeCheck:     // 时间校验
        case SettingType_CloudService:  //  云套餐服务
        case SettingType_LightDuration: //  灯照时长
        case SettingType_AddSensor:     //  添加传感器
        case SettingType_SceneTask:     //  情景任务
            //        case SettingType_ShareWithFriends:  //  好友分享
        {
            /// 设备不在线  不让点击
            if (self.devModel.Status != DevStatus_onLine) {
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"Setting_DeviceOffLine")];
                return;
            }
        }break;
            
        default:
            break;
    }
    
    switch (model.settingType) {
            /// NOTE :aleax 第三方接入
        case SettingType_Alexa:{
            ThirdAccessVC * vc = [[ThirdAccessVC alloc] init];
            vc.abilityModel = self.abilityModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :音乐播放
        case SettingType_BabyMusic:{
            BabyMusicVC * vc = [[BabyMusicVC alloc] init];
            vc.abilityModel = self.abilityModel;
            vc.deviceID = self.devModel.DeviceId;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :夜视
        case SettingType_NightVersion:{
            NightVersionVC * vc = [[NightVersionVC alloc] init];
            vc.deviceID = self.devModel.DeviceId;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :温度报警
        case SettingType_TempAlarmSetting:{
            TempAlarmVC * vc = [[TempAlarmVC alloc] init];
            vc.deviceID = self.devModel.DeviceId;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :移动侦测
        case SettingType_MotionDetection:{
            MotionDetectSettingVC * vc = [[MotionDetectSettingVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :声音报警
        case SettingType_VoiceDetection:{
            VoiceDetectVC * vc = [[VoiceDetectVC alloc] init];
            vc.devDataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :设备信息
        case SettingType_DeviceInfo:{
            DeviceInfoVC * vc = [[DeviceInfoVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :时间校验
        case SettingType_TimeCheck:{
            TimeCheckVC * vc = [[TimeCheckVC alloc] init];
            vc.devDataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :云套餐服务
        case SettingType_CloudService:{
            if (model.PackageModel) {
                CloudPackageDetailVC * vc = [[CloudPackageDetailVC alloc] init];
                vc.PackageModel = model.PackageModel;
                vc.dataModel = self.devModel;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                CloudServiceVC * vc = [[CloudServiceVC alloc] init];
                vc.dataModel = self.devModel;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }break;
            /// NOTE :WiFi设置
        case SettingType_WiFiSetting:{
            WiFiSettingVC * vc = [[WiFiSettingVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :灯照时长
        case SettingType_LightDuration:{
            LightDurationVC * vc = [[LightDurationVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :相册
        case SettingType_PhotoAlbum:{
            SettingPhotoAlbumVC * vc = [[SettingPhotoAlbumVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :添加传感器
        case SettingType_AddSensor:{
            AddSensorVC * vc = [[AddSensorVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :情景任务
        case SettingType_SceneTask:{
            SceneTaskVC * vc = [[SceneTaskVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            /// NOTE :好友分享
        case SettingType_ShareWithFriends:{
            ShareWithFriendsVC * vc = [[ShareWithFriendsVC alloc] init];
            vc.dataModel = self.devModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dataSourceArr objectAtIndex:section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MainSettingCell cellModelWithTableView:tableView
                                         indexPath:indexPath
                                             model:[[self.dataSourceArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
                                          delegate:self];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.01;
}
#pragma mark -- lazy
- (UIView *)tableFootView{
    if (!_tableFootView) {
        _tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 180)];
        MainSettingFootView * footView = [[MainSettingFootView alloc] init];
        [footView.deleteBtn addTarget:self action:@selector(delectDevice) forControlEvents:UIControlEventTouchUpInside];
        [_tableFootView addSubview:footView];
    }
    return _tableFootView;
}
- (iOSConfigSDK *)configSdk{
    if (!_configSdk) {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.paramDelegate = self;
        _configSdk.dmDelegate = self;
        _configSdk.iotDelegate = self;
        _configSdk.abDelegate = self;
    }
    return _configSdk;
}
- (PackageValidTimeApiManager *)packageValidTimeApiManager {
    if (!_packageValidTimeApiManager) {
        _packageValidTimeApiManager = [[PackageValidTimeApiManager alloc] init];
        _packageValidTimeApiManager.delegate = self;
    }
    return _packageValidTimeApiManager;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GosLog(@"---------- MainSettingViewController dealloc ----------");
    GosLog(@"---%s---",__PRETTY_FUNCTION__);
}
@end
