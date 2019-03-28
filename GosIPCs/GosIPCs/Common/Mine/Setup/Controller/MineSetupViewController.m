//  MineSetupViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineSetupViewController.h"
#import "UIViewController+MineTableExtension.h"
#import "MineSetupViewModel.h"
#import "Masonry.h"
#import "UIViewController+NavigationEdgeLayout.h"

@interface MineSetupViewController ()

@end

@implementation MineSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置所有控件
    [self configAllComponents];
}

#pragma mark - config method
- (void)configComponentsAndAttributes {
    [super configComponentsAndAttributes];
    
    self.title = DPLocalizedString(@"Mine_Setup");
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineCellModel *cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
    
    return [MineTableViewCell cellHeightWithModel:cellModel];
}
- (void)configTableView {
    [super configTableView];
    self.mineTableView.backgroundColor = [UIColor clearColor];
    self.mineTableView.scrollEnabled = NO;
    self.mineTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self.mineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}
- (void)configTableDataArray:(id<MineViewModelDelegate> (^)(void))mineViewModelBlock {
    // 配置table数据
    [super configTableDataArray: ^id<MineViewModelDelegate>(void) {
        return [[MineSetupViewModel alloc] init];
    }];
}

@end
