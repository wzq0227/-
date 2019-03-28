//
//  SceneTaskVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//  情景任务界面

#import "SceneTaskVC.h"
#import "SceneTaskCell.h"
#import "UIViewController+CommonExtension.h"
#import "AddSceneTaskVC.h"
#import "SceneTaskModel.h"
#import "SceneTaskViewModel.h"
#import "iOSConfigSDK.h"
#import "UIScrollView+EmptyDataSet.h"
@interface SceneTaskVC ()<
UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKIOTDelegate,
sceneTaskCellDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>
/// SDK
@property (nonatomic, strong) iOSConfigSDK * iOSConfigsdk;
/// TableView
@property (weak, nonatomic) IBOutlet UITableView *sceneTaskTableView;
/// 数组
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
/// 情景任务存储模型
@property (nonatomic, strong) IotSceneTask * tempTaskModel;

@end
@implementation SceneTaskVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark - config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_SceneTask");
    [self configRightBtnImg:@"icon_add"];
    self.sceneTaskTableView.bounces = NO;
    self.sceneTaskTableView.emptyDataSetSource = self;
    self.sceneTaskTableView.emptyDataSetDelegate = self;
    self.sceneTaskTableView.backgroundColor = GOS_VC_BG_COLOR;
    self.sceneTaskTableView.tableFooterView = [UIView new];
}
- (void)configData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.iOSConfigsdk querySceneTaskListOfDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark - 修改情景任务开关
- (void)didModifySceneTask:(IotSceneTask *) taskModel{
    self.tempTaskModel = taskModel;
    [SVProgressHUD showWithStatus: DPLocalizedString(@"SVPLoading")];
    /// 修改情景任务开关 数据设置 请求四
    [self.iOSConfigsdk modifySceneTask:taskModel toDevice:self.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    [self modifySceneTaskSwitch:taskModel];
}
#pragma mark - 查询 IOT-情景任列表务结果回调
- (void)querySceneTask:(BOOL)isSuccess
                  list:(NSArray<IotSceneTask*>*)stList
              deviceId:(NSString *)devId
             errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        if (!stList || stList.count < 1) {
            return;
        }
        [self.dataSourceArr removeAllObjects];
        [self.dataSourceArr addObjectsFromArray:stList];
        [self refreshTable];
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
    }
}

- (void)modifySceneTaskSwitch:(IotSceneTask *) taskModel{
    // 设置声光报警器开关  请求一
    [self.iOSConfigsdk configStrobeSirenSwitch:taskModel.isCarryOut ofDevice:self.dataModel.DeviceId];
    
    //   查询 IOT-情景任务（满足条件/执行传感器）信息列表  请求二
    [self.iOSConfigsdk queryIfExeListOfSceneTask:taskModel.iotSceneTaskId onAccount:[GosLoggedInUserInfo account]];
}
#pragma mark - 修改 IOT-情景任务结果回调  请求四回调
- (void)modifySceneTask:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"ModifyFailure")];
    }
}
#pragma mark - 查询 IOT-情景任务（满足条件/执行传感器）信息列表结果回调 请求二回调
- (void)query:(BOOL)isSuccess
 ifSensorList:(NSArray<IotSensorModel*>*)ifSensorList
exeSensorList:(NSArray<IotSensorModel*>*)exeSensorList
    errorCode:(int)eCode{
    __weak typeof(self) weakSelf = self;
    if (isSuccess) {
        if (ifSensorList && ifSensorList.count >0) {
            [ifSensorList enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSceneOpen = weakSelf.tempTaskModel.isCarryOut;
                /// 请求三
                [weakSelf.iOSConfigsdk modifyIotSensor:obj ofDevice:weakSelf.dataModel.DeviceId];
            }];
        }
        if(exeSensorList && exeSensorList.count >0){
            [exeSensorList enumerateObjectsUsingBlock:^(IotSensorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSceneOpen = weakSelf.tempTaskModel.isCarryOut;
                [weakSelf.iOSConfigsdk modifyIotSensor:obj ofDevice:weakSelf.dataModel.DeviceId];
            }];
        }
    }
}

#pragma mark - 设置声光报警器（报警）开关结果回调  请求一回调
- (void)configStrobeSirenSwitch:(BOOL)isSuccess
                       deviceId:(NSString *)devId
                      errorCode:(int)eCode{
    [GosHUD dismiss];
    if (!isSuccess) {
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"ModifyFailure")];
    }
}
#pragma mark - 修改 IOT 状态结果回调  请求三回调
- (void)modifyIot:(BOOL)isSuccess
         deviceId:(NSString *)devId
        errorCode:(int)eCode{
    if (isSuccess) {
        
    }
}
#pragma mark - 刷新tableView
- (void)refreshTable{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.sceneTaskTableView reloadData];
    });
}
#pragma mark - tableView&delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    IotSceneTask * model = self.dataSourceArr[indexPath.row];
    return [SceneTaskCell cellWithTableView:tableView cellModel:model delegate:self];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    AddSceneTaskVC * vc = [[AddSceneTaskVC alloc] init];
    vc.detail = YES;
    vc.dataModel = self.dataSourceArr[indexPath.row];
    vc.devModel = self.dataModel;
    vc.block = ^(IotSceneTask *model) {
        [weakSelf refreshTable];
    };
    vc.deleteBlock = ^(IotSceneTask *model) {
        [weakSelf.dataSourceArr removeObject:model];
        [weakSelf refreshTable];
    };
    [self.navigationController pushViewController:vc animated:YES];
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
    __weak typeof(self) weakSelf = self;
    IotSceneTask * model = self.dataSourceArr[indexPath.row];
    self.tempTaskModel = model;
        //在这里实现删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        /// NOTE: 删除情景任务
         [weakSelf.iOSConfigsdk delSceneTask:model.iotSceneTaskId fromDevice:weakSelf.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakself = self;
    //    //删除
    IotSceneTask * model = self.dataSourceArr[indexPath.row];
    self.tempTaskModel = model;
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:DPLocalizedString(@"GosComm_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
        /// 删除情景任务 数据请求  请求二
        [weakself.iOSConfigsdk delSceneTask:model.iotSceneTaskId fromDevice:weakself.dataModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }];
    return @[deleteRowAction];
}
#pragma mark - 添加情景任务
- (void)rightBtnClicked{
    GOS_WEAK_SELF;
    AddSceneTaskVC * vc = [[AddSceneTaskVC alloc] init];
    vc.sceneTaksArr = self.dataSourceArr;
    vc.detail = NO;
    vc.devModel = self.dataModel;
    vc.block = ^(IotSceneTask *model) {
        GOS_STRONG_SELF;
        [strongSelf.dataSourceArr addObject:model];
        [strongSelf refreshTable];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 删除 IOT-情景任务结果回调 请求二回调
- (void)delSceneTask:(BOOL)isSuccess
            deviceId:(NSString *)devId
           errorCode:(int)eCode{
    [GosHUD dismiss];
    GOS_WEAK_SELF;
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.dataSourceArr removeObject:strongSelf.tempTaskModel];
            [strongSelf refreshTable];
        });
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"GosComm_DeleteFailure")];
    }
}
#pragma mark - emptyDataDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"img_blankpage_scene_task"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString * title = DPLocalizedString(@"Setting_hasNotSceneList");
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:GOS_COLOR_RGBA(198, 198, 198, 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

#pragma mark - lazyStyle
- (iOSConfigSDK *)iOSConfigsdk{
    if (!_iOSConfigsdk) {
        _iOSConfigsdk = [iOSConfigSDK shareCofigSdk];
        _iOSConfigsdk.iotDelegate = self;
    }
    return _iOSConfigsdk;
}
- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [[NSMutableArray alloc] init];
    }
    return _dataSourceArr;
}
@end
