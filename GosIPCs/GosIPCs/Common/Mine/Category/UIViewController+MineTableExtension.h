//  UIViewController+MineTableExtension.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "MineCellModel.h"
#import "MineTableViewCell.h"
#import "MineViewModelDelegate.h"


@interface UIViewController (MineTableExtension) <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mineTableView;
@property (nonatomic, strong) NSMutableArray *mineTableDataArray;
@property (nonatomic, strong) id<MineViewModelDelegate> mineViewModel;

/// 统一配置方法
- (void)configAllComponents;
/// 配置其他控件
- (void)configComponentsAndAttributes;
/// 配置tableView
- (void)configTableView;
/// 配置table数据
- (void)configTableDataArray:(id<MineViewModelDelegate> (^)(void))mineViewModelBlock;
@end

