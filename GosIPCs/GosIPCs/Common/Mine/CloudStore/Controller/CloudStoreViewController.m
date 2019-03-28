//  CloudStoreViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "CloudStoreViewController.h"
#import "CloudStoreCellModel.h"
#import "CloudStoreTableViewCell.h"
#import "CloudStoreViewModel.h"
#import "UIColor+GosColor.h"
#import "UIViewController+MineTableExtension.h"
#import "AccountOrderListApiManager.h"

@interface CloudStoreViewController () <GosApiManagerCallBackDelegate>
/// 请求账户套餐列表
@property (nonatomic, strong) AccountOrderListApiManager *accountOrderListApiManager;
@end

@implementation CloudStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configAllComponents];
    // 请求账户套餐列表
    [self loadRequestAccountOrderList];
}

#pragma mark - config method
- (void)configComponentsAndAttributes {
    [super configComponentsAndAttributes];
    
    self.title = DPLocalizedString(@"Mine_CloudSubscription");
}

- (void)configTableView {
    self.mineTableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.mineTableView.sectionFooterHeight = 10.0;
    self.mineTableView.rowHeight = [CloudStoreTableViewCell cellHeightWithModel:nil];
    [self.view addSubview:self.mineTableView];
    [self.mineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)configTableDataArray:(id<MineViewModelDelegate> (^)(void))mineViewModelBlock {
    [super configTableDataArray: ^id<MineViewModelDelegate>(void){
        return [[CloudStoreViewModel alloc] init];
    }];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CloudStoreCellModel *cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
    return [CloudStoreTableViewCell cellWithTableView:tableView model:cellModel];
}

#pragma mark - GosApiManagerCallBackDelegate
- (void)managerCallApiDidSuccess:(GosApiBaseManager *)manager {
    [GosHUD dismiss];
    NSArray *dataArray = [manager fetchDataWithReformer:self.accountOrderListApiManager];
    self.mineTableDataArray = [[(CloudStoreViewModel *)self.mineViewModel processNetRespModelArray:dataArray] mutableCopy];
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.mineTableView reloadData];
    });
    
}
- (void)managerCallApiDidFailed:(GosApiBaseManager *)manager {
    [GosHUD dismiss];
    GosLog(@"%s [manager] %@ [errorType] %zd", __PRETTY_FUNCTION__, manager, manager.errorType);
    [GosHUD showProcessHUDInfoWithStatus:@"Mine_GetNetworkDataFailed"];
}
#pragma mark - load request
- (void)loadRequestAccountOrderList {
    [GosHUD showProcessHUDWithStatus:@"Mine_Loading"];
    [self.accountOrderListApiManager loadData];
}

#pragma mark - getters and setters
- (AccountOrderListApiManager *)accountOrderListApiManager {
    if (!_accountOrderListApiManager) {
        _accountOrderListApiManager = [[AccountOrderListApiManager alloc] init];
        _accountOrderListApiManager.delegate = self;
    }
    return _accountOrderListApiManager;
}

@end
