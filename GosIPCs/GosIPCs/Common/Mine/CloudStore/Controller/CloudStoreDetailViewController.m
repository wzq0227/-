//  CloudStoreDetailViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/5.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreDetailViewController.h"
#import "UIButton+GosGradientButton.h"
#import "UIView+GosClipView.h"
#import "CloudStoreDetailTableViewCell.h"
#import "CloudStoreCellModel.h"
#import "DeviceOrderListApiManager.h"
#import "MigratePackageApiManager.h"
#import "CloudStoreViewModel.h"
#import "CloudServiceVC.h"
#import "GosAlertListView.h"


@interface CloudStoreDetailViewController () <UITableViewDataSource, UITableViewDelegate, GosApiManagerCallBackDelegate>
/// 截图视图
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
/// 截图背景——装载imageView, 蒙版, 播放按钮
@property (weak, nonatomic) IBOutlet UIView *scrrenshotImageBackground;
/// 截图前面的遮罩
@property (weak, nonatomic) IBOutlet UIView *screenshotCoverView;
/// 遮罩前面的按钮
@property (weak, nonatomic) IBOutlet UIButton *screenshotButton;
/// 历史套餐记录tableview
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
/// tableview的高度限制
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBackgroundHeightConstraint;
/// 续费按钮 或者 转移按钮 或者 购买按钮
@property (weak, nonatomic) IBOutlet UIButton *renewButton;
/// tableview数据
@property (nonatomic, strong) NSArray *tableDataArray;
/// table顶部的视图，不与table同流合污
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
/// table背景视图，包含table顶部视图，tableview
@property (weak, nonatomic) IBOutlet UIView *tableBackgroundView;
/// 由其他页面传递而来的cellModel
@property (nonatomic, copy) CloudStoreCellModel *pageCellModel;
/// viewModel
@property (nonatomic, strong) CloudStoreViewModel *cloudViewModel;
/// 请求设备的订单列表
@property (nonatomic, strong) DeviceOrderListApiManager *deviceOrderListApiManager;
/// 转移设备套餐
@property (nonatomic, strong) MigratePackageApiManager *migratePackageApiManager;
@end

@implementation CloudStoreDetailViewController
#pragma mark - initialization
- (instancetype)initWithCellModel:(CloudStoreCellModel *)cellModel {
    if (self = [super init]) {
        self.pageCellModel = [cellModel copy];
    }
    return self;
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configComponents];
    
    // 请求获取设备套餐列表
    [self loadRequestDevicePackageListWithDeviceId:self.pageCellModel.deviceID];
    
}

- (void)configComponents {
    // 根据cellModel配置显示
    [self configUIWithCellModel:self.pageCellModel];
    
    // 观察tableDataArray
    [self addObserver:self forKeyPath:@"tableDataArray" options:NSKeyValueObservingOptionNew context:nil];
    
    // 截图背景的四个圆角
    _scrrenshotImageBackground.layer.cornerRadius = 6.0;
    _scrrenshotImageBackground.layer.masksToBounds = YES;

    // table背景的四个圆角
    _tableBackgroundView.layer.cornerRadius = 10.0;
    _tableBackgroundView.layer.masksToBounds = YES;
    
    // tableView高度
    _historyTableView.rowHeight = [CloudStoreDetailTableViewCell cellHeightWithModel:nil];
    
    // 按钮渐变设置
    [_renewButton setupGradientWithBlueColorAndHalfHeightAndLeftToRightDirection];

}
- (void)configUIWithCellModel:(CloudStoreCellModel *)cellModel {
    // 标题显示设备名
    self.title = cellModel.deviceName;
    // 显示续费还是转移还是付费
    [self.renewButton setTitle:DPLocalizedString(cellModel.status == CloudStoreOrderStatusUnbind?@"Mine_ServiceTransfer":(cellModel.status == CloudStoreOrderStatusUnpurchased?@"Mine_Purchase":@"Mine_Renew")) forState:UIControlStateNormal];
    // playback按钮是否可用
    BOOL enablePlayback = (cellModel.status == CloudStoreOrderStatusInUse || cellModel.status == CloudStoreOrderStatusUnbind);
    self.screenshotButton.userInteractionEnabled = enablePlayback;
    self.screenshotCoverView.hidden = enablePlayback;
    
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"tableDataArray"];
}
#pragma mark - observer method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tableDataArray"]) {
        // 动态改变响应
        [self setupTableBackgroundWithCellCount:self.tableDataArray.count];
    }
}
#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CloudStoreCellModel *cellModel = [self.tableDataArray objectAtIndex:indexPath.row];
    return [CloudStoreDetailTableViewCell cellWithTableView:tableView model:cellModel];
}


#pragma mark - GosApiManagerCallBackDelegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *)manager {
    [GosHUD dismiss];
    
    if (manager == self.deviceOrderListApiManager) {
        NSArray *dataArray = [manager fetchDataWithReformer:self.deviceOrderListApiManager];
        [self willChangeValueForKey:@"tableDataArray"];
        self.tableDataArray = [[self.cloudViewModel processNetRespModelArray:dataArray] mutableCopy];
        [self didChangeValueForKey:@"tableDataArray"];
        
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.historyTableView reloadData];
        });
    } else if (manager == self.migratePackageApiManager) {
        
        if ([[manager fetchDataWithReformer:self.migratePackageApiManager] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            // 删除推送
            [self.cloudViewModel deletePushMessageWithDeviceId:self.pageCellModel.deviceID];
        } else {
            [GosHUD showProcessHUDInfoWithStatus:@"GosComm_Set_Failed"];
        }
    }
}
- (void)managerCallApiDidFailed:(GosApiBaseManager *)manager {
    [GosHUD dismiss];
    GosLog(@"%s [manager] %@ [errorType] %zd", __PRETTY_FUNCTION__, manager, manager.errorType);
    [GosHUD showProcessHUDInfoWithStatus:@"Mine_GetNetworkDataFailed"];
}

#pragma mark - event response
/// 播放按钮点击响应
- (IBAction)screenshotImageButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.pageCellModel.status == CloudStoreOrderStatusInUse
        || self.pageCellModel.status == CloudStoreOrderStatusUnbind) {
        // TODO: 跳转到云播放页面
//        CloudPlayBackViewController *vc = [CloudPlayBackViewController new];
//        vc.deviceModel = wSelf.devDataModel;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    // 其他情况此按钮应该是不可点击状态，所以理论上不会响应此方法
}

/// 续费或转移或购买按钮点击响应
- (IBAction)renewButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    if (self.pageCellModel.status == CloudStoreOrderStatusUnbind) {
        /**
         转移功能
         */
        NSArray *devices = [self.cloudViewModel fetchDeviceDataModelArray];
        if ([devices count] == 0) {
            // 没有可转移的设备
            [GosHUD showProcessHUDInfoWithStatus:@"Mine_NoDeviceCanBeTransfer"];
        } else {
            // 显示设备选择列表
            __weak typeof(self) weakself = self;
            // 如果需要cancel按钮就设置cancel为@"Goscam_Cancel"
            [GosAlertListView alertTableShowWithTitle:@"Mine_SelectDeviceToTransfer" cancel:nil dataArray:devices textKeyPath:[self.cloudViewModel fetchDeviceDataModelForDisplayKeyPath] callback:^(NSInteger index, GosAlertListCellModel *alertCellModel) {
                
                NSString *transferDeviceId = [weakself.cloudViewModel fetchDeviceIdFromDeviceDataModel:alertCellModel.extraData];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@", DPLocalizedString(@"Mine_TransferConfirm"), alertCellModel.text] message:DPLocalizedString(@"Mine_TransferWipeTip") preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    /// 请求转移套餐
                    [weakself loadRequestFromOriginDeviceId:weakself.pageCellModel.deviceID toTransferDeviceId:transferDeviceId];
                }]];
                [weakself presentViewController:alert animated:YES completion:nil];
            }];
        }
    } else {
        /**
         续费或购买功能
         */
        // 判断是否支持云存储
        if (![self.cloudViewModel validateIsSupportCloudServiceWithDeviceId:self.pageCellModel.deviceID]) {
            [GosHUD showProcessHUDErrorWithStatus:DPLocalizedString(@"Mine_DeviceNotSupportCloud")];
        } else {
            // 支持云存储则跳转到套餐列表
            CloudServiceVC *packageListVC = [[CloudServiceVC alloc] init];
            packageListVC.dataModel = [self.cloudViewModel fetchDeviceDataModelWithDeviceId:self.pageCellModel.deviceID];
            [self.navigationController pushViewController:packageListVC animated:YES];
        }
    }
}

#pragma mark - request method
- (void)loadRequestFromOriginDeviceId:(NSString *)originDeviceId toTransferDeviceId:(NSString *)transferDeviceId {
    [GosHUD showProcessHUDWithStatus:@"Mine_Loading"];
    [self.migratePackageApiManager loadDataWithOriginDeviceId:originDeviceId destinationDeviceId:transferDeviceId];
}
- (void)loadRequestDevicePackageListWithDeviceId:(NSString *)deviceId {
    [GosHUD showProcessHUDWithStatus:@"Mine_Loading"];
    [self.deviceOrderListApiManager loadDataWithDeviceId:deviceId];
}
#pragma mark - private method
- (void)setupTableBackgroundWithCellCount:(NSInteger)count {
    if (count == 0) {
        self.tableBackgroundView.hidden = YES;
    } else {
        self.tableBackgroundView.hidden = NO;
        // 最大高度 = 续费按钮的最小Y - 截图背景的最大Y - 与截图背景的偏移 - 与续费按钮的偏移
        CGFloat maxHeight = CGRectGetMinY(self.renewButton.frame) - CGRectGetMaxY(self.scrrenshotImageBackground.frame) - 40 - 40;
        // 计算高度 = table顶部视图的高度 + cell数量 * cell高度 + 偏移
        CGFloat calculateHeight = self.tableHeaderView.frame.size.height + count * self.historyTableView.rowHeight + 5;
        self.tableBackgroundHeightConstraint.constant = calculateHeight > maxHeight ? maxHeight : calculateHeight;
    }
}
#pragma mark - getters and setters
- (NSArray *)tableDataArray {
    if (!_tableDataArray) {
        // tableDataArray改变时都要加两个方法，以响应观察者方法
        [self willChangeValueForKey:@"tableDataArray"];
        _tableDataArray = [self.cloudViewModel generateTableDataArray];
        [self didChangeValueForKey:@"tableDataArray"];
    }
    return _tableDataArray;
}
- (CloudStoreViewModel *)cloudViewModel {
    if (!_cloudViewModel) {
        _cloudViewModel = [[CloudStoreViewModel alloc] init];
    }
    return _cloudViewModel;
}
- (DeviceOrderListApiManager *)deviceOrderListApiManager {
    if (!_deviceOrderListApiManager) {
        _deviceOrderListApiManager = [[DeviceOrderListApiManager alloc] init];
        _deviceOrderListApiManager.delegate = self;
    }
    return _deviceOrderListApiManager;
}
- (MigratePackageApiManager *)migratePackageApiManager {
    if (!_migratePackageApiManager) {
        _migratePackageApiManager = [[MigratePackageApiManager alloc] init];
        _migratePackageApiManager.delegate = self;
    }
    return _migratePackageApiManager;
}
@end
