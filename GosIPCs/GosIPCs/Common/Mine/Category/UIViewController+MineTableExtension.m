//  UIViewController+MineTableExtension.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIViewController+MineTableExtension.h"
#import "objc/runtime.h"
#import "UIColor+GosColor.h"
#import "MessageListViewController.h"

@implementation UIViewController (MineTableExtension)

- (void)configAllComponents {
    [self configComponentsAndAttributes];
    
    [self configTableDataArray:nil];
    
    [self configTableView];
    
}
/// 配置其他控件
- (void)configComponentsAndAttributes {
    // hook
    self.view.backgroundColor = [UIColor gosGrayColor];
}
/// 配置tableView
- (void)configTableView {
    
    [self.view addSubview:self.mineTableView];
    
}
/// 配置table数据
- (void)configTableDataArray:(id<MineViewModelDelegate> (^)(void))mineViewModelBlock {
    self.mineViewModel = mineViewModelBlock();
    self.mineTableDataArray = self.mineViewModel?[[self.mineViewModel generateTableDataArray] mutableCopy]:[NSMutableArray array];
    [self.mineTableView reloadData];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [self.mineTableDataArray count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:section] count] : [self.mineTableDataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineCellModel *cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
    return [MineTableViewCell cellWithTableView:tableView model:cellModel];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    id<MineCellModelProtocol> cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
        
    if (cellModel.cellClickActionBlock) {
        // 存在点击
        id obj = cellModel.cellClickActionBlock(nil);
        if ([obj isKindOfClass:[UIViewController class]]) {
            
            // 存在跳转
            [self.navigationController pushViewController:obj animated:YES];
        }
    }
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    id<MineCellModelProtocol> cellModel = [[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]] ? [[self.mineTableDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] : [self.mineTableDataArray objectAtIndex:indexPath.row];
//
//    return [MineTableViewCell cellHeightWithModel:cellModel];
//}

#pragma mark - getters and setters
- (UITableView *)mineTableView {
    UITableView *tempTableView = objc_getAssociatedObject(self, _cmd);
    if (!tempTableView) {
        tempTableView = [[UITableView alloc] initWithFrame:CGRectZero style:[[self.mineTableDataArray firstObject] isKindOfClass:[NSArray class]]?UITableViewStyleGrouped:UITableViewStylePlain];
        tempTableView.backgroundColor = [UIColor gosGrayColor];
        tempTableView.dataSource = self;
        tempTableView.delegate = self;
        tempTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        objc_setAssociatedObject(self, @selector(mineTableView), tempTableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tempTableView;
}
- (void)setMineTableView:(UITableView *)mineTableView {
    objc_setAssociatedObject(self, @selector(mineTableView), mineTableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)mineTableDataArray {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setMineTableDataArray:(NSMutableArray *)mineTableDataArray {
    objc_setAssociatedObject(self, @selector(mineTableDataArray), mineTableDataArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<MineViewModelDelegate>)mineViewModel {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setMineViewModel:(id<MineViewModelDelegate>)mineViewModel {
    objc_setAssociatedObject(self, @selector(mineViewModel), mineViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
