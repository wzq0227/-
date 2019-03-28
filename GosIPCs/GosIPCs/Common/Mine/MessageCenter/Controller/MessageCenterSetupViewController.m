//  MessageCenterSetupViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/26.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterSetupViewController.h"
#import "UIViewController+MineTableExtension.h"
#import "MessageCenterSetupViewModel.h"
#import "MessageCenterSetupCellModel.h"
#import "MessageCenterSetupTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"

@interface MessageCenterSetupViewController () <UITableViewDelegate, UITableViewDataSource, MessageCenterSetupTableViewCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/// tableview
@property (weak, nonatomic) IBOutlet UITableView *setupTableView;
/// tableView数据
@property (nonatomic, strong) NSArray *tableDataArray;
/// viewModel;
@property (nonatomic, strong) MessageCenterSetupViewModel *setupViewModel;
@end

@implementation MessageCenterSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = DPLocalizedString(@"Mine_MessageCenterSetup");
    
    // 空数据页面dataSource,delegate
    self.setupTableView.emptyDataSetSource = self;
    self.setupTableView.emptyDataSetDelegate = self;
    // 避免出现空数据时，有横线
    self.setupTableView.tableFooterView = [[UIView alloc] init];
}


//- (void)getDevPushState
//{
//    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
////    NSString *uuidStr = [SYDeviceInfo identifierForVender];
//    NSDictionary *postDict = @{
//                               @"MessageType":@"GetDevicePushStateRequest",
//                               @"Body":
//                                   @{
//                                       @"Terminal":@"iphone", //终端系统类型
//                                       @"UserName":[SaveDataModel getUserName],//app就填账户名，dev就填ID
//                                       @"Token":@"test",  //对于APP没有token的就填写mac地址，对于camera写DEVICE ID,token是唯一的
//                                       @"AppId":bundleId,//APP唯一表示符号
//                                       @"UUID":uuidStr //手机唯一标识
//                                       }
//                               };
//
//    //    NSData *reqData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
//
//    [[NetSDK sharedInstance] net_sendCBSRequestWithData:postDict timeout:15000 responseBlock:^(int result, NSDictionary *dict) {
//        GosLog(@"开关设置状态%@",dict[@"Body"][@"DeviceList"]);
//        for (NSDictionary * dic in dict[@"Body"][@"DeviceList"] ) {
//            PushDevSetingStateModel * md = [[PushDevSetingStateModel alloc]initWithDict:dic];
//            [self.devPushArr addObject:md];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.pushSettingTableView reloadData];
//        });
//    }];
//
//}



- (void)dealloc {
    GosLog(@"PushSettingViewController --- dealloc ---");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return GOS_IMAGE(@"img_blankpage_camera");
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:DPLocalizedString(@"Mine_NoDevices") attributes:@{NSForegroundColorAttributeName:GOS_COLOR_RGB(0xCCCCCC), NSFontAttributeName:GOS_FONT(14)}];
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -100;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MessageCenterSetupTableViewCell cellWithTableView:tableView model:self.tableDataArray[indexPath.row] target:self];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MessageCenterSetupTableViewCell cellHeightWithModel:self.tableDataArray[indexPath.row]];
}

#pragma mark - getters and setters
- (NSArray *)tableDataArray {
    if (!_tableDataArray) {
        _tableDataArray = [[self.setupViewModel generateTableDataArray] copy];
    }
    return _tableDataArray;
}
- (MessageCenterSetupViewModel *)setupViewModel {
    if (!_setupViewModel) {
        _setupViewModel = [[MessageCenterSetupViewModel alloc] init];
    }
    return _setupViewModel;
}

@end
