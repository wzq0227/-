//  AddSceneTaskVC.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/29.
//  Copyright © 2018 goscam. All rights reserved.

#import "AddSceneTaskVC.h"
#import "AddSensorModifyeNameView.h"    //  修改传感器名view
#import "KKAlertView.h"
#import "AddSceneTaskHeadView.h"    //  section头视图
#import "AddSceneTaskCell.h"        //  cell
#import "SceneTaskSelectDeviceVC.h"     //  选择设备界面
#import "SceneTaskTableHead.h"  //  table头视图
#import "SceneTaskTableFoot.h"  //  table脚视图
#import "iOSConfigSDKModel.h"      //   模型
#import "UIViewController+CommonExtension.h"
#import "iOSConfigSDK.h"

@interface AddSceneTaskVC ()
<UITableViewDelegate,
UITableViewDataSource,
modifyNameDelegate,
sceneTaskSelectDelegate,
iOSConfigSDKIOTDelegate>
@property (weak, nonatomic) IBOutlet UITableView *addSceneTaskTableView;
/// 皮囊头视图
@property (nonatomic, strong) UIView * headView;
/// 皮囊脚视图
@property (nonatomic, strong) UIView * footView;
/// 真正的头视图
@property (nonatomic, strong) SceneTaskTableHead * tableHeadView;
/// 真正的脚视图
@property (nonatomic, strong) SceneTaskTableFoot * tableFootView;
/// 添加IotTask模型
@property (nonatomic, strong) IotSceneTask * uploadTaskModel;
/// sdk
@property (nonatomic, strong) iOSConfigSDK * iOSConfigsdk;
@end

@implementation AddSceneTaskVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_SceneTask");
    [self configRightBtnTitle:DPLocalizedString(@"GosComm_Save") titleFont:nil titleColor:nil];
    self.addSceneTaskTableView.bounces = NO;
    self.addSceneTaskTableView.backgroundColor = GOS_VC_BG_COLOR;
    self.addSceneTaskTableView.tableHeaderView = self.headView;
}
#pragma mark - set&methods
- (void)setDetail:(BOOL)detail{
    _detail = detail;
    if (self.isDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.addSceneTaskTableView.tableFooterView = self.footView;
        });
    }else{
        self.uploadTaskModel.iotSceneTaskName = [self getSceneTaskDefaultName];
        [self refreshTable];
    }
}
- (void)setDataModel:(IotSceneTask *)dataModel{
    _dataModel = dataModel;
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    /// NOTE: 详情界面过来，请求情景任务下的具体IOT设备 请求一
    [self.iOSConfigsdk queryIfExeListOfSceneTask:self.dataModel.iotSceneTaskId onAccount:[GosLoggedInUserInfo account]];
}
- (void)setSceneTaksArr:(NSArray<IotSceneTask *> *)sceneTaksArr{
    _sceneTaksArr = sceneTaksArr;
}
#pragma mark - 查询 IOT-情景任务（满足条件/执行传感器）信息列表结果回调 请求一回调
- (void)query:(BOOL)isSuccess
 ifSensorList:(NSArray<IotSensorModel*>*)ifSensorList
exeSensorList:(NSArray<IotSensorModel*>*)exeSensorList
    errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        if (!self.dataModel.satisfyList) {
            self.dataModel.satisfyList = [NSMutableArray new];
        }
        if (!self.dataModel.carryoutList) {
            self.dataModel.carryoutList = [NSMutableArray new];
        }
        [self.dataModel.satisfyList removeAllObjects];
        [self.dataModel.carryoutList removeAllObjects];
        if (ifSensorList && ifSensorList.count >0) {
            [self.dataModel.satisfyList addObjectsFromArray:ifSensorList];
        }
        if (exeSensorList && exeSensorList.count >0) {
            [self.dataModel.carryoutList addObjectsFromArray:exeSensorList];
        }
        [self refreshTable];
    }
}
#pragma mark - function
#pragma mark - 删除情景任务
- (void)deleteSceneTask{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"Setting_DeleteSceneTaskTip") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleDefault handler:nil];
    if (cancelAction) {
        [cancelAction setValue:GOS_COLOR_RGB(0x55AFFC) forKey:@"titleTextColor"];
    }
    __weak typeof(self) weakSelf = self;
    UIAlertAction *defultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
        /// 删除情景任务 数据请求  请求二
        [weakSelf.iOSConfigsdk delSceneTask:weakSelf.dataModel.iotSceneTaskId fromDevice:weakSelf.devModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
        GosLog(@"删除情景任务设备");
    }];
    if (defultAction) {
        [defultAction setValue:GOS_COLOR_RGB(0x4D4D4D) forKey:@"titleTextColor"];
    }
    [alertview addAction:defultAction];
    [alertview addAction:cancelAction];
    [self presentViewController:alertview animated:YES completion:nil];
}

#pragma mark - 修改情景任务名点击
- (void)modifySceneTaskName{
    AddSensorModifyeNameView * modifyView = [[AddSensorModifyeNameView alloc] init];
    [KKAlertView shareView].contentView = modifyView;
    modifyView.titleLab.text = DPLocalizedString(@"Setting_SceneTaskReName");
    modifyView.placeTitle = DPLocalizedString(@"Setting_SceneTaskInput");
    modifyView.delegate = self;
    [[KKAlertView shareView] show];
}
#pragma mark - 输入情景任务名确认回调
- (void)modifyNameWithNewName:(nonnull NSString *)name {
    self.uploadTaskModel.iotSceneTaskName = name;
    if (self.isDetail) {
        self.dataModel.iotSceneTaskName = name;
    }
    [self refreshTable];
}

#pragma mark - 添加情景任务 任务和条件 10是条件  11是任务
- (void)addtask:(UIButton *) sender{
    SceneTaskSelectDeviceVC * vc = [[SceneTaskSelectDeviceVC alloc] init];
    vc.devModel = self.devModel;
    vc.dataModel = self.isDetail?self.dataModel:self.uploadTaskModel;
    vc.delegate = self;
    switch (sender.tag) {
        case 10:{
            vc.task = NO;
        }break;
        case 11:{
            vc.task = YES;
        }break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 删除 IOT-情景任务结果回调 请求二回调
- (void)delSceneTask:(BOOL)isSuccess
            deviceId:(NSString *)devId
           errorCode:(int)eCode{
    [GosHUD dismiss];
    __weak typeof(self) weakSelf = self;
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.deleteBlock) {
                weakSelf.deleteBlock(weakSelf.dataModel);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showBottomHUDWithStatus:DPLocalizedString(@"GosComm_DeleteFailure")];
    }
}
#pragma mark - 选好条件或任务回调
- (void)didSelectSceneTaskIotModel:(NSArray<IotSensorModel *>*) IotSensorArr
                            isTask:(BOOL) isTask{
    if (self.isDetail) {
        if (isTask) {
            [self.dataModel.carryoutList removeAllObjects];
            [self.dataModel.carryoutList addObjectsFromArray:IotSensorArr];
        }else{
            [self.dataModel.satisfyList removeAllObjects];
            [self.dataModel.satisfyList addObjectsFromArray:IotSensorArr];
        }
    }else{
        if (isTask) {
            [self.uploadTaskModel.carryoutList removeAllObjects];
            [self.uploadTaskModel.carryoutList addObjectsFromArray:IotSensorArr];
        }else{
            [self.uploadTaskModel.satisfyList removeAllObjects];
            [self.uploadTaskModel.satisfyList addObjectsFromArray:IotSensorArr];
        }
    }
    [self refreshTable];
}

#pragma mark - 保存情景任务点击
- (void)rightBtnClicked{
    if (![self hasTaskAndCondition]) {
        UIAlertController *alertview=[UIAlertController alertControllerWithTitle:DPLocalizedString(@"Setting_Tips") message:DPLocalizedString(@"Setting_TipsContents") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertview addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertview animated:YES completion:nil];
        });
        return;
    }
    
    GosLog(@"保存情景任务");
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    /// 编辑保存
    if (self.isDetail) {
        /// NOTE: 修改情景任务 数据请求 请求三
        [self.iOSConfigsdk modifySceneTask:self.dataModel toDevice:self.devModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }
    /// 新建保存
    else{
        /// NOTE: 添加情景任务 数据请求 请求四
        [self.iOSConfigsdk addSceneTask:self.uploadTaskModel toDevice:self.devModel.DeviceId onAccount:[GosLoggedInUserInfo account]];
    }
}
#pragma mark - 添加 IOT-情景任务结果回调 请求四回调
- (void)addSceneTask:(BOOL)isSuccess
         sceneTaskId:(NSInteger)sTaskId
            deviceId:(NSString *)devId
           errorCode:(int)eCode{
    [GosHUD dismiss];
    __weak typeof(self) weakSelf = self;
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.block) {
                weakSelf.block(weakSelf.uploadTaskModel);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"AddDEV_addFailed")];
    }
}
#pragma mark - 修改 IOT-情景任务结果回调  请求三回调
- (void)modifySceneTask:(BOOL)isSuccess
               deviceId:(NSString *)devId
              errorCode:(int)eCode{
    [GosHUD dismiss];
    __weak typeof(self) weakSelf = self;
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.block) {
                weakSelf.block(nil);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }else{
        [GosHUD showScreenfulHUDErrorWithStatus:DPLocalizedString(@"ModifyFailure")];
    }
}
#pragma mark - 获取情景任务默认名
- (NSString *)getSceneTaskDefaultName{
    __block NSUInteger nameCount = 0;
    [self.sceneTaksArr enumerateObjectsUsingBlock:^(IotSceneTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * sceneTask = DPLocalizedString(@"Setting_SceneTask");
        if ([obj.iotSceneTaskName rangeOfString:sceneTask].location != NSNotFound) {
            NSUInteger nameLen = DPLocalizedString(@"Setting_SceneTask").length;
            NSInteger nameNo = [[obj.iotSceneTaskName substringFromIndex:nameLen] integerValue];
            nameCount = MAX(nameCount, nameNo);
        }
    }];
    NSString * nameStr = [NSString stringWithFormat:@"%@%ld",DPLocalizedString(@"Setting_SceneTask"),(long)++nameCount];
    return nameStr;
}
#pragma mark - 判断条件和任务是否都齐全
- (BOOL)hasTaskAndCondition{
    if (self.isDetail) {
        if (self.dataModel.satisfyList.count < 1||
            self.dataModel.carryoutList.count < 1) {
            return NO;
        }
    }else{
        if (self.uploadTaskModel.satisfyList.count < 1 ||
            self.uploadTaskModel.carryoutList.count < 1) {
            return NO;
        }
    }
    return YES;
}
#pragma mark - 刷新Tableview
- (void)refreshTable{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.addSceneTaskTableView reloadData];
        strongSelf.tableHeadView.titleLab.text = strongSelf.detail?strongSelf.dataModel.iotSceneTaskName:strongSelf.uploadTaskModel.iotSceneTaskName;
    });
}
#pragma mark - tableView&delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    IotSensorModel * model = [IotSensorModel new];
    switch (indexPath.section) {
        case 0:{
            model = self.detail?self.dataModel.satisfyList[indexPath.row]:self.uploadTaskModel.satisfyList[indexPath.row];
        }break;
        case 1:{
            model = self.detail?self.dataModel.carryoutList[indexPath.row]:self.uploadTaskModel.carryoutList[indexPath.row];
        }break;
        default:
            break;
    }
    return [AddSceneTaskCell cellWithTableView:tableView cellModel:model];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.detail?self.dataModel.satisfyList.count:self.uploadTaskModel.satisfyList.count;
    }
    return self.detail?self.dataModel.carryoutList.count:self.uploadTaskModel.carryoutList.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    AddSceneTaskHeadView * headView = [[AddSceneTaskHeadView alloc] init];
    if (section == 0) {
        headView.titleLab.text = DPLocalizedString(@"Setting_SatisfyTitle");
        [headView.addBtn setTag:10];
    }else{
        headView.titleLab.text = DPLocalizedString(@"Setting_CarryoutTitle");
        [headView.addBtn setTag:11];
    }
    [headView.addBtn setHidden:self.isDetail?YES:NO];
    [headView.addBtn addTarget:self action:@selector(addtask:) forControlEvents:UIControlEventTouchUpInside];
    return headView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 44.0f)];
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 44.0f)];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textColor = GOS_COLOR_RGB(0x999999);
    
    lab.textAlignment = NSTextAlignmentCenter;
    [footView addSubview:lab];
    switch (section) {
        case 0:{
            if (self.isDetail?self.dataModel.satisfyList.count <1:self.uploadTaskModel.satisfyList.count <1) {
                lab.text = DPLocalizedString(@"Setting_HaveNotYetSceneCondition");
                return footView;
            }
        }break;
        case 1:{
            if (self.isDetail?self.dataModel.carryoutList.count <1:self.uploadTaskModel.carryoutList.count <1) {
                lab.text = DPLocalizedString(@"Setting_HaveNotYetSceneTask");
                return footView;
            }
        }break;
        default:
            break;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 40.0f;
}
#pragma mark - 懒加载
- (UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] init];
        _headView.frame = CGRectMake(0, 0, GOS_SCREEN_W, 60);
        self.tableHeadView = [[SceneTaskTableHead alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 60)];
        [self.tableHeadView.nameBtn addTarget:self action:@selector(modifySceneTaskName) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:self.tableHeadView];
    }
    return _headView;
}
- (UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc] init];
        _footView.frame = CGRectMake(0, 0, GOS_SCREEN_W, 50);
        self.tableFootView = [[SceneTaskTableFoot alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 50)];
        [self.tableFootView.deleteBtn addTarget:self action:@selector(deleteSceneTask) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:self.tableFootView];
    }
    return _footView;
}
- (IotSceneTask *)uploadTaskModel{
    if (!_uploadTaskModel) {
        _uploadTaskModel = [[IotSceneTask alloc] init];
        _uploadTaskModel.isCarryOut = YES;
        _uploadTaskModel.satisfyList = [NSMutableArray new];
        _uploadTaskModel.carryoutList = [NSMutableArray new];
    }
    return _uploadTaskModel;
}
- (iOSConfigSDK *)iOSConfigsdk{
    if (!_iOSConfigsdk) {
        _iOSConfigsdk = [iOSConfigSDK shareCofigSdk];
        _iOSConfigsdk.iotDelegate = self;
    }
    return _iOSConfigsdk;
}
@end
