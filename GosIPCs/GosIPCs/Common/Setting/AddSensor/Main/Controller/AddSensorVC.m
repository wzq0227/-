//
//  AddSensorVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AddSensorVC.h"
#import "AddSensorCell.h"
#import "AddSensorHeadView.h"
#import "AddSOSVC.h"                    //  添加SOS
#import "AddSoundLightAlarmVC.h"        //  添加声光报警器
#import "AddMagneticDoorVC.h"           //  添加门磁
#import "AddInfraredIntrusVC.h"         //  添加红外入侵探测器
#import "AddSensorModifyeNameView.h"
#import "KKAlertView.h"
#import "iOSConfigSDK.h"
#import "ADDIotProtocol.h"
#import "AddSensorViewModel.h"
#import "AddSensorTypeModel.h"
@interface AddSensorVC ()<UITableViewDelegate,
UITableViewDataSource,
AddSensorHeadViewDelegate,
iOSConfigSDKIOTDelegate,
ADDIotProtocolDelegate,
addSensorCellDelegate,
modifyNameDelegate>
@property (weak, nonatomic) IBOutlet UITableView *sensorTableview;
/// sdk
@property (nonatomic, strong) iOSConfigSDK * iOSConfigSDK;
/// 数据模型
@property (nonatomic, strong) NSArray <AddSensorTypeModel *>* dataSourceArr;
/// 传感器数组
@property (nonatomic, strong) NSArray<IotSensorModel *>* sensorArr;
/// 容器模型
@property (nonatomic, strong) IotSensorModel * tempModel;

@end

@implementation AddSensorVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_AddSensor");
    self.sensorTableview.bounces = NO;
    self.sensorTableview.rowHeight = 44.0f;
    self.sensorTableview.backgroundColor = GOS_VC_BG_COLOR;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    /// 请求设备端列表  请求一
    [self.iOSConfigSDK queryIotListOfDevice:self.dataModel.DeviceId];
    /// 请求服务器列表  请求二
    [self.iOSConfigSDK reqIotSensorListOfDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark - 查询 IOT 列表结果回调(设备端) 请求一回调
- (void)queryIotList:(BOOL)isSuccess
            deviceId:(NSString *)devId
             iotList:(NSArray<IotSensorModel*>*)iList
           errorCode:(int)eCode{
    
}
#pragma mark -- 请求 IOT-传感器列表结果回调(服务器端) 请求二回调
- (void)reqIot:(BOOL)isSuccess
    sensorList:(NSArray<IotSensorModel *>*)sList
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        self.sensorArr = sList;
        self.dataSourceArr = [AddSensorViewModel handleListDataWithArr:sList];
    }else{
        
    }
    [self refreshTableView];
}
#pragma mark - 修改 IOT 状态结果回调(设备端) 请求三回调
- (void)modifyIot:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode{
    [GosHUD dismiss];
    /// 设备端修改成功，再改服务器
    if (isSuccess) {
        // 修改服务器数据请求 请求四
        [self.iOSConfigSDK modifyIotSensor:self.tempModel ofDevice:devId onAccount:[GosLoggedInUserInfo account]];
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"ModifyFailure")];
    }
}
#pragma mark - 修改 IOT-传感器结果回调(服务器端) 请求四回调
- (void)modifyIotSensor:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    [GosHUD dismiss];
    
    if (isSuccess) {
        /// 请求服务器列表 请求二
        [self.iOSConfigSDK reqIotSensorListOfDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"Setting_ModifySensorSucces")];
        GosLog(@"服务器也修改成功");
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"ModifyFailure")];
        GosLog(@"服务器修改失败");
    }
}

#pragma mark - 删除 IOT 状态结果回调(设备端) 请求五回调
- (void)deleteIot:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode{
    if (isSuccess) {
        /// NOTE: 删除IOT从服务器 数据请求 请求六
        [self.iOSConfigSDK unBindIotSensor:self.tempModel fromDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }else{
        [GosHUD dismiss];
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"cloudShare_delete_success")];
    }
}
#pragma mark - 解除绑定 IOT-传感器到设备结果回调(服务端) 请求六回调
- (void)unBindIotSensor:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        [AddSensorViewModel deleteSensorWithIotModel:self.tempModel withTableArr:self.dataSourceArr];
        [self refreshTableView];
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"cloudShare_delete_fail")];
    }
}

#pragma mark -- actionFunction
#pragma mark -- 添加设备结果回调
- (void)callBackState:(AddIOTStatus) callBackState
           gosIOTType:(GosIOTType) gosIOTType
             sensorId:(NSString *) sensorId{
    switch (callBackState) {
        case AddIot_timeout:{   //  超时
            [self bottonShowTips:DPLocalizedString(@"NetworkReqTimeOUt")];
        }break;
        case AddIot_failure:{   //  添加失败
            [self bottonShowTips:DPLocalizedString(@"AddDEV_AddFailed")];
        }break;
        case AddIot_repeat:{    // 重复添加
            [self bottonShowTips:DPLocalizedString(@"Setting_addRepeat")];
        }break;
        case AddIot_success:{   //  添加成功
            [self bottonShowTips:DPLocalizedString(@"AddDEV_AddSuccess")];
            [self addSensorToService:sensorId gosIOTType:gosIOTType];
        }break;
        default:
            break;
    }
}
#pragma mark -- 将添加到设备的ID返回 添加到服务器
- (void)addSensorToService:(NSString *) sensorId
                gosIOTType:(GosIOTType) gosIOTType{
    __weak typeof(self) weakSelf = self;
    IotSensorModel * model = [[IotSensorModel alloc] init];
    model.iotSensorType = gosIOTType;
    model.iotSensorId = sensorId;
    model.isAPNSOpen = YES;
    model.isSceneOpen = YES;
    model.iotSensorName = [self sensorDefaultName];
    
    /// 第三步 添加到自己服务器  请求七
    [weakSelf.iOSConfigSDK bindIotSensor:model toDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    [AddSensorViewModel addSensorWithIotModel:model withTableArr:self.dataSourceArr];
    [self refreshTableView];
}
#pragma mark -- 绑定 IOT-传感器到设备结果回调(服务器端) 请求七回调
- (void)bindIotSensor:(BOOL)isSuccess
             deviceId:(NSString *)devId
            errorCode:(int)eCode{
    if (isSuccess) {
        /// 请求服务器列表
        [self.iOSConfigSDK reqIotSensorListOfDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }
}
#pragma mark -- 取默认名字
- (NSString *)sensorDefaultName
{
    __block NSUInteger nameCount = 0;
    [self.sensorArr enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.iotSensorName rangeOfString:DPLocalizedString(@"Setting_DefenceArea")].location !=NSNotFound) {
            NSUInteger nameLen = DPLocalizedString(@"Setting_DefenceArea").length;
            NSInteger nameNo = [[obj.iotSensorName substringFromIndex:nameLen] integerValue];
            nameCount = MAX(nameCount, nameNo);
        }
    }];
    NSString * nameStr = [NSString stringWithFormat:@"%@%ld",DPLocalizedString(@"Setting_DefenceArea"),(long)++nameCount];
    return nameStr;
}
#pragma mark -- 头视图添加传感器代理
- (void)AddSensorWithType:(GosIOTType) gosIOTType{
    switch (gosIOTType) {
        case GosIot_sensorMagnetic:{
            AddMagneticDoorVC * vc = [[AddMagneticDoorVC alloc] init];
            vc.dataModel = self.dataModel;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case GosIot_sensorInfrared:{
            AddInfraredIntrusVC * vc = [[AddInfraredIntrusVC alloc] init];
            vc.delegate = self;
            vc.dataModel = self.dataModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case GosIot_sensorAudibleAlarm:{
            AddSoundLightAlarmVC * vc = [[AddSoundLightAlarmVC alloc] init];
            vc.dataModel = self.dataModel;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case GosIot_sensorSOS:{
            AddSOSVC * vc =[[AddSOSVC alloc] init];
            vc.dataModel = self.dataModel;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
}
#pragma mark -- function
- (void)refreshTableView{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.sensorTableview reloadData];
    });
}
- (void)bottonShowTips:(NSString *) tips{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [GosHUD showBottomHUDWithStatus:tips];
    });
}

#pragma mark - cell&delegate
// 改开关状态
- (void)modifySensorSwitch:(IotSensorModel *) cellModel{
    self.tempModel = cellModel;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    // 设备端修改 请求三
    [self.iOSConfigSDK modifyIotSensor:cellModel ofDevice:self.dataModel.DeviceId];
    
}
// 改名
- (void)modifySensorName:(IotSensorModel *) cellModel{
    self.tempModel = cellModel;
    AddSensorModifyeNameView * modifyView = [[AddSensorModifyeNameView alloc] init];
    [KKAlertView shareView].contentView = modifyView;
    modifyView.titleLab.text = DPLocalizedString(@"Setting_EditSensorName");
    modifyView.delegate = self;
    modifyView.placeTitle = DPLocalizedString(@"Setting_SceneTaskInput");
    [[KKAlertView shareView] show];
}
#pragma mark - 弹出框确认点击代理
- (void)modifyNameWithNewName:(NSString *) name{
    self.tempModel.iotSensorName = name;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    // 设备端修改 请求三
    [self.iOSConfigSDK modifyIotSensor:self.tempModel ofDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark -- TableView&delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddSensorTypeModel * model = self.dataSourceArr[indexPath.section];
    IotSensorModel * cellModel = model.sectionArr[indexPath.row];
    return [AddSensorCell cellWithTableView:tableView cellModel:cellModel delegate:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    AddSensorTypeModel * model = self.dataSourceArr[section];
    return model.sectionArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [AddSensorHeadView headViewWithTypeModel:self.dataSourceArr[section] delegate:self];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}
/// 1
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
/// 2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DPLocalizedString(@"GosComm_Delete");
}
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSensorTypeModel * model = self.dataSourceArr[indexPath.section];
    IotSensorModel * cellModel = model.sectionArr[indexPath.row];
    self.tempModel = cellModel;
    GOS_WEAK_SELF;
    //    //在这里实现删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GOS_STRONG_SELF;
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        /// NOTE: 删除IOT设备端 数据请求 请求五
        [strongSelf.iOSConfigSDK deleteIotSensor:cellModel fromDevice:strongSelf.dataModel.DeviceId];
    }
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    //删除
    AddSensorTypeModel * model = self.dataSourceArr[indexPath.section];
    IotSensorModel * cellModel = model.sectionArr[indexPath.row];
    self.tempModel = cellModel;
    GOS_WEAK_SELF;
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:DPLocalizedString(@"GosComm_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GOS_STRONG_SELF;
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        /// NOTE: 删除IOT设备端 数据请求 请求五
        [strongSelf.iOSConfigSDK deleteIotSensor:cellModel fromDevice:strongSelf.dataModel.DeviceId];
    }];
    return @[deleteRowAction];
}
#pragma mark -- lazy
- (iOSConfigSDK *)iOSConfigSDK{
    if (!_iOSConfigSDK) {
        _iOSConfigSDK = [iOSConfigSDK shareCofigSdk];
        _iOSConfigSDK.iotDelegate = self;
    }
    return _iOSConfigSDK;
}
#pragma mark - 视图消失
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
-(void)dealloc{
    GosLog(@"----  %s ----", __PRETTY_FUNCTION__);
}
@end
