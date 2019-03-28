//  ExperienceCenterViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ExperienceCenterViewController.h"
#import "ExperienceCenterTableViewCell.h"
#import "ExperienceCenterViewModel.h"
#import "ExperienceCenterCellModel.h"
#import "UIColor+GosColor.h"

@interface ExperienceCenterViewController () <UITableViewDelegate, UITableViewDataSource>
/// tableview
@property (nonatomic, strong) UITableView *experienceTableView;
/// table数据
@property (nonatomic, copy) NSArray *tableDataArray;
/// viewModel
@property (nonatomic, strong) id<MineViewModelDelegate> experienceViewModel;

@end

@implementation ExperienceCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Mine_ExperienceCenter");
    // tableview
    [self.view addSubview:self.experienceTableView];
    [self.experienceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.tableDataArray firstObject] isKindOfClass:[NSArray class]] ? [self.tableDataArray count] : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.tableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.tableDataArray objectAtIndex:section] count] : [self.tableDataArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExperienceCenterCellModel *cellModel = [[self.tableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.tableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.tableDataArray objectAtIndex:indexPath.row];
    return [ExperienceCenterTableViewCell cellWithTableView:tableView model:cellModel];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ExperienceCenterCellModel *cellModel = [[self.tableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.tableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.tableDataArray objectAtIndex:indexPath.row];
    
    if (cellModel.cellTurnToVCBlock) {
        // 存在跳转
        [self.navigationController pushViewController:cellModel.cellTurnToVCBlock() animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExperienceCenterCellModel *cellModel = [[self.tableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.tableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.tableDataArray objectAtIndex:indexPath.row];
    return  [ExperienceCenterTableViewCell cellHeightWithModel:cellModel];
}

#pragma mark - getters and setters
- (UITableView *)experienceTableView {
    if (!_experienceTableView) {
        _experienceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:[[self.tableDataArray firstObject] isKindOfClass:[NSArray class]]?UITableViewStyleGrouped:UITableViewStylePlain];
        _experienceTableView.backgroundColor = [UIColor gosGrayColor];
        _experienceTableView.dataSource = self;
        _experienceTableView.delegate = self;
        _experienceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _experienceTableView.sectionHeaderHeight = CGFLOAT_MIN;
        _experienceTableView.sectionFooterHeight = 10.0;
    }
    return _experienceTableView;
}
- (id<MineViewModelDelegate>)experienceViewModel {
    if (!_experienceViewModel) {
        _experienceViewModel = [[ExperienceCenterViewModel alloc] init];
    }
    return _experienceViewModel;
}
- (NSArray *)tableDataArray {
    if (!_tableDataArray) {
        _tableDataArray = [[self.experienceViewModel generateTableDataArray] copy];
    }
    return _tableDataArray;
}


@end
