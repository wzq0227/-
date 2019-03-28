//
//  ChooseAddMethodViewController.m
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/14.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import "ChooseAddMethodViewController.h"

@interface ChooseAddMethodViewController ()<UITableViewDelegate,
                                            UITableViewDataSource
                                            >
@property (weak, nonatomic) IBOutlet UITableView *addMethodTableView;

@end

@implementation ChooseAddMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    self.title = DPLocalizedString(@"AddDEV_ChooseAddMethod_title");
}

#pragma mark - tableView
static NSString *const CELL_ID = @"cell";

- (void)initTableView {
    self.addMethodTableView.delegate = self;
    self.addMethodTableView.dataSource = self;
    [self.addMethodTableView registerNib:[UINib nibWithNibName:@"DeviceAddtionMethodTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ID];
}

#pragma mark -- tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addMethodArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.height * 9.f/37; // 9 / (1 + 4 * 9)
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DeviceAddtionMethodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    cell.isNeedResetFrame = YES;
    cell.isArrowHidden = NO;
    NSNumber *addTypeNum = self.addMethodArr[indexPath.row];
    cell.addType = addTypeNum.integerValue;
    return cell;
}

#pragma mark -- tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DeviceAddtionMethodTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.resultBlock(cell.addType);
    [self.navigationController popViewControllerAnimated:YES];
}


@end
