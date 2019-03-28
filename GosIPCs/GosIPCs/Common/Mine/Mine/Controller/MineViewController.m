//
//  MineViewController.m
//  Goscom
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "MineViewController.h"
#import "UIViewController+MineTableExtension.h"
#import "MineHeaderView.h"
#import "MineFooterView.h"
#import "MineViewModel.h"
#import "Masonry.h"
#import "MineCellModel.h"
#import "GosRootViewController.h"
#import "GosDevManager.h"
#import "GosLoggedInUserInfo.h"
#import "GosAlertView.h"
#import "CloudStoreViewController.h"

@interface MineViewController ()
@property (nonatomic, strong) MineHeaderView *mineHeaderView;
@property (nonatomic, strong) MineFooterView *mineFooterView;
@end

@implementation MineViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置控件
    [self configAllComponents];

    // 必须使用此方法隐藏导航栏
    // 1. 防止导航栏返回的时候出现部分黑屏
    // 2. 防止tabBar切换到此页面时出现闪现黑屏
    // 3. 防止切换
    ((GosRootViewController *)self.navigationController).isHiddenNavigationBar = YES;
}

- (void)dealloc {
    GosLog(@"---------- MineViewController dealloc ----------");
}

#pragma mark - config
- (void)configComponentsAndAttributes {
    [super configComponentsAndAttributes];
    
}
- (void)configTableView {
    // tableView
    self.mineTableView.sectionFooterHeight = 10.0;
    self.mineTableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.mineTableView.showsVerticalScrollIndicator = NO;
    self.mineTableView.rowHeight = [MineTableViewCell cellHeightWithModel:nil];
    [self.view addSubview:self.mineTableView];
    // 向上偏移到statusBar的高度
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.mineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 适配设备尺寸向上偏移statusBar的高度
        make.edges.mas_equalTo(UIEdgeInsetsMake(-statusBarHeight, 0, 0, 0));
    }];
    
    // headerView
    self.mineHeaderView.frame = CGRectMake(0, 0, self.mineTableView.frame.size.width, statusBarHeight+170);
    self.mineTableView.tableHeaderView = self.mineHeaderView;
    
    // footerView
    self.mineFooterView.frame = CGRectMake(0, 0, self.mineTableView.frame.size.width, 106);
    self.mineTableView.tableFooterView = self.mineFooterView;
}
- (void)configTableDataArray:(id<MineViewModelDelegate> (^)(void))mineViewModelBlock {
    [super configTableDataArray: ^id<MineViewModelDelegate>(void){
        return [[MineViewModel alloc] init];
    }];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    MineCellModel *cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
    // 需要在此处理的model
    switch (cellModel.cellMark) {
        case MineCellMarkCloudSubscription:
            [self cloudSubscriptionCellClickAction];
            break;
            
        default:
            break;
    }
}

#pragma mark - cell extra handle
- (void)cloudSubscriptionCellClickAction {
    // 判断是否有设备
    if ([[GosDevManager deviceList] count] == 0) {
        // 弹窗提示没有设备、跳转去购买设备
        __weak typeof(self) weakself = self;
        [GosAlertView alertShowWithTitle:nil message:@"Mine_NoDeviceForCloud" cancelAction:[GosAlertAction actionWithText:@"GosComm_Cancel" style:GosAlertActionStyleCancel clickAction:nil] otherActions:[GosAlertAction actionWithText:@"Mine_GoToShop" style:GosAlertActionStyleBlue clickAction:^(GosAlertAction * _Nullable action) {
            // 跳转到商城
            [weakself.tabBarController setSelectedIndex:1];
        }],  nil];
    } else {
        [self.navigationController pushViewController:[[CloudStoreViewController alloc] init] animated:YES];
    }
}
#pragma mark - getters and setters
- (MineHeaderView *)mineHeaderView {
    if (!_mineHeaderView) {
        _mineHeaderView = [[MineHeaderView alloc] init];
    }
    return _mineHeaderView;
}
- (MineFooterView *)mineFooterView {
    if (!_mineFooterView) {
        _mineFooterView = [[MineFooterView alloc] init];
    }
    return _mineFooterView;
}
@end
