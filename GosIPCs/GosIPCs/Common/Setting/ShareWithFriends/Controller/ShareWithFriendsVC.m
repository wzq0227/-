//
//  ShareWithFriendsVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//  好友分享界面

#import "ShareWithFriendsVC.h"
#import "ShareWithFriendsCell.h"
#import "iOSConfigSDK.h"
#import "ShareWithFriendsModel.h"
#import "ShareWithFriendsHeadView.h"
@interface ShareWithFriendsVC ()<UITableViewDelegate,
UITableViewDataSource,
iOSConfigSDKDMDelegate,
ShareWithFriendsDeletDelegate,
ShareFriendsHeadViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *shareTableview;   //  tableview
@property (nonatomic, strong) iOSConfigSDK *configSDK;   // configSDK
@property (nonatomic, strong) NSMutableArray * dataSourceArr;   // 数据
@property (nonatomic, assign) BOOL isEdit;   // 是否编辑状态
/// 真正的头视图
@property (nonatomic, strong) ShareWithFriendsHeadView * headView;
/// 皮囊脚视图
@property (nonatomic, strong) UIView * tableHeadView;
@end

@implementation ShareWithFriendsVC
#pragma mark -- lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configTable];
    [self configNetData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark -- config
- (void)configUI{
    self.title = DPLocalizedString(@"Setting_ShareWithFriends");
    self.isEdit = NO;
}
- (void)configTable{
    self.shareTableview.bounces = NO;
    self.shareTableview.rowHeight = 44.0f;
    self.shareTableview.tableHeaderView = self.tableHeadView;
    self.shareTableview.tableFooterView = [UIView new];
    self.shareTableview.backgroundColor = GOS_VC_BG_COLOR;
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;//几个手指点击
    tableViewGesture.cancelsTouchesInView = NO;//是否取消点击处的其他action
    [self.shareTableview addGestureRecognizer:tableViewGesture];
}
- (void)configNetData{
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSDK queryShareListWithDevId:self.dataModel.DeviceId];
}
// ------tableView 上添加的自定义手势
- (void)tableViewTouchInSide{
    // ------结束编辑，隐藏键盘
    [self.view endEditing:YES];
}

#pragma mark - function
- (void)refreshUI{
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.shareTableview reloadData];
        [strongSelf.headView setDataArr:strongSelf.dataSourceArr];
    });
}
#pragma mark - 确认分享
- (void)shareFriendsConfirm:(NSString *)shareUserID{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headView.accountTextField resignFirstResponder];
    });
//    [self.configSDK bindDeviceId:self.dataModel.DeviceId
//                      deviceName:self.dataModel.DeviceName
//                      deviceType:self.dataModel.DeviceType
//                         ownType:DevOwn_share
//                         account:shareUserID];
    DevDataModel * tempModel = [self.dataModel copy];
    tempModel.DeviceOwner = DevOwn_share;
    tempModel.DeviceId = self.dataModel.DeviceId;
    [self.configSDK bindDevice:tempModel toAccount:shareUserID];
}
#pragma mark - 编辑点击
- (void)shareFriendsEdit:(BOOL)isEdit{
    [self refreshUI];
}
#pragma mark - 查询设备分享列表数据回调
- (void)queryShareList:(BOOL)isSuccess
              deviceId:(NSString *)devId
           accountList:(NSArray<NSString *>*)aList
             errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        [self initTableDataArr:aList];
    }else{
        [self showFail:DPLocalizedString(@"GosComm_getData_fail")];
    }
}
#pragma mark - 处理请求数据
- (void)initTableDataArr:(NSArray<NSString *>*) dataArr{
    [GosHUD dismiss];
    [self.dataSourceArr removeAllObjects];
    for (int i=0;i<dataArr.count; i++) {
        ShareWithFriendsModel * model = [[ShareWithFriendsModel alloc] init];
        model.IDStr = dataArr[i];
        model.isEdit = NO;
        [self.dataSourceArr addObject:model];
    }
    [self refreshUI];
}

#pragma mark -- actionFunction
/// callbackDelegate
#pragma mark - 删除点击回调
- (void)friendsDeleteWithCellModel:(ShareWithFriendsModel *)cellModel{
    [self.dataSourceArr removeObject:cellModel];
    [GosHUD showProcessHUDWithStatus:DPLocalizedString(@"SVPLoading")];
//    [self.configSDK unBindDevice:self.dataModel fromAccount:[cellModel.IDStr];
    [self.configSDK unBindDevice:self.dataModel fromAccount:cellModel.IDStr];
}
#pragma mark - 解绑设备回调
- (void)unBind:(BOOL)isSuccess
      deviceId:(NSString *)devId
     errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        [self showSuccess:DPLocalizedString(@"cloudShare_delete_success")];
        [self refreshUI];
    }else{
        [self showFail:DPLocalizedString(@"cloudShare_delete_fail")];
    }
}
#pragma mark - 绑定设备回调
- (void)bind:(BOOL)isSuccess
    deviceId:(NSString *)devId
   errorCode:(int)eCode{
    [GosHUD dismiss];
    if (isSuccess) {
        [self configNetData];
        [self showSuccess:DPLocalizedString(@"cloudShare_share_success")];
    }else{
        [self showFail:DPLocalizedString(@"cloudShare_share_failed")];
    }
}
- (void)showSuccess:(NSString *)tips{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosHUD showScreenfulHUDSuccessWithStatus:tips];
    });
}
- (void)showFail:(NSString *) tips{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GosHUD showScreenfulHUDErrorWithStatus:tips];
    });
}
#pragma mark -- delegate
//1
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DPLocalizedString(@"GosComm_Delete");
}
//4
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    GOS_WEAK_SELF;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GOS_STRONG_SELF;
        ShareWithFriendsModel * model = strongSelf.dataSourceArr[indexPath.row];
        [strongSelf.dataSourceArr removeObject:model];
        [strongSelf.configSDK unBindDevice:strongSelf.dataModel fromAccount:model.IDStr];
//        [strongSelf.configSDK unBindDeviceId:strongSelf.dataModel.DeviceId account:model.IDStr];
    }
    
}
//5
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    //删除
    GOS_WEAK_SELF;
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:DPLocalizedString(@"GosComm_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GOS_STRONG_SELF;
        ShareWithFriendsModel * model = strongSelf.dataSourceArr[indexPath.row];
        [strongSelf.dataSourceArr removeObject:model];
        [strongSelf.configSDK unBindDevice:strongSelf.dataModel fromAccount:model.IDStr];
//        [strongSelf.configSDK unBindDeviceId:strongSelf.dataModel.DeviceId account:model.IDStr];
    }];
    return @[deleteRowAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ShareWithFriendsCell cellWithTableView:tableView cellModel:self.dataSourceArr[indexPath.row] delegate:self];
}

#pragma mark -- lazy
- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [[NSMutableArray alloc] init];
    }
    return _dataSourceArr;
}
- (iOSConfigSDK *)configSDK{
    if (!_configSDK) {
        _configSDK = [iOSConfigSDK shareCofigSdk];
        _configSDK.dmDelegate = self;
    }
    return _configSDK;
}
- (UIView *)tableHeadView{
    if (!_tableHeadView) {
        self.headView = [[ShareWithFriendsHeadView alloc] init];
        self.headView.delegate = self;
        _tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, 250)];
        [_tableHeadView addSubview:self.headView];
        
    }
    return _tableHeadView;
}
@end
