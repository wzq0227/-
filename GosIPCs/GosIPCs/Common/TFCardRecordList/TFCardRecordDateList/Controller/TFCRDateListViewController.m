//
//  TFCRDateListViewController.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "TFCRDateListViewController.h"
#import "TFCRDateListTableViewCell.h"
#import "TFCRMediaListViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface TFCRDateListViewController () <
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            iOSConfigSDKDMDelegate,
                                            DZNEmptyDataSetSource,
                                            DZNEmptyDataSetDelegate
                                         >
@property (weak, nonatomic) IBOutlet UIImageView *noFileImgView;
@property (weak, nonatomic) IBOutlet UILabel *noFileLabel;
@property (weak, nonatomic) IBOutlet UITableView *dateListTableView;
@property (weak, nonatomic) IBOutlet UIView *noTFCardView;
@property (weak, nonatomic) IBOutlet UILabel *noTFCardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noTFCardTipsLabel1;
@property (weak, nonatomic) IBOutlet UILabel *noTFCardTipsLabel2;
@property (weak, nonatomic) IBOutlet UILabel *noTFCardTipsLabel3;
@property (weak, nonatomic) IBOutlet UILabel *noTFCardTipsLabel4;
@property (nonatomic, readwrite, strong) NSMutableArray<RecMonthDataModel*> *recordDateList;
@property (nonatomic, readwrite, weak) iOSConfigSDK *configSdk;

@end

@implementation TFCRDateListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configUI];
    [self configTableView];
    
    dispatch_async([QueueManager bgQueue], ^{
        
        [self loadTFCRecordDateList];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    GosLog(@"---------- TFCRDateListViewController dealloc ----------");
}

- (void)configUI
{
    self.title                   = DPLocalizedString(@"TFCR_Title");
    self.noFileLabel.text        = DPLocalizedString(@"TFCR_NoFiles");
    self.noTFCardTitleLabel.text = DPLocalizedString(@"TFCR_NoTFCardTitle");
    self.noTFCardTipsLabel1.text = DPLocalizedString(@"TFCR_NoTFCardTips1");
    self.noTFCardTipsLabel2.text = DPLocalizedString(@"TFCR_NoTFCardTips2");
    self.noTFCardTipsLabel3.text = DPLocalizedString(@"TFCR_NoTFCardTips3");
    self.noTFCardTipsLabel4.text = DPLocalizedString(@"TFCR_NoTFCardTips4");
}

- (void)configTableView
{
    self.dateListTableView.backgroundColor = GOS_VC_BG_COLOR;
    self.dateListTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.dateListTableView.rowHeight       = 50.0f;
    self.dateListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dateListTableView.bounces         = NO;
}

#pragma mark -- 设置’没有文件提示‘是否隐藏
- (void)configNoFileTipsHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.noFileImgView.hidden     = isHidden;
        self.noFileLabel.hidden       = isHidden;
    });
}

#pragma mark -- 设置’没有 TF 卡提示‘是否隐藏
- (void)configNoTFCardViewHidden:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.noTFCardView.hidden = isHidden;
    });
}

#pragma mark -- 加载 TF 卡录像日期列表
- (void)loadTFCRecordDateList
{
    [SVProgressHUD showWithStatus:DPLocalizedString(@"SVPLoading")];
    [self.configSdk reqMothRecListWithDevId:self.devModel.DeviceId];
}

#pragma mark -- 刷新列表
- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.dateListTableView reloadData];
    });
}

#pragma mark - 懒加载
- (NSMutableArray<RecMonthDataModel *> *)recordDateList
{
    if (!_recordDateList)
    {
        _recordDateList = [NSMutableArray arrayWithCapacity:0];
    }
    return _recordDateList;
}

- (iOSConfigSDK *)configSdk
{
    if (!_configSdk)
    {
        _configSdk = [iOSConfigSDK shareCofigSdk];
        _configSdk.dmDelegate = self;
    }
    return _configSdk;
}


#pragma mark - TableView Datasource & Delegate
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.recordDateList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tfCardRecordDateListCellId = @"TFCardRecordDateListCellId";
    NSUInteger rowIndex = indexPath.row;
    TFCRDateListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tfCardRecordDateListCellId];
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TFCRDateListTableViewCell class])
                                             owner:self
                                           options:nil][0];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.recordDateList.count > rowIndex)
    {
        cell.recordDateStr = self.recordDateList[rowIndex].dateStr;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIndex = indexPath.row;
    if (self.recordDateList.count <= rowIndex)
    {
        return;
    }
    TFCRMediaListViewController *mediaListVC = [[TFCRMediaListViewController alloc] init];
    mediaListVC.devModel                     = self.devModel;
    mediaListVC.recordDateStr                = self.recordDateList[rowIndex].dateStr;
    [self.navigationController pushViewController:mediaListVC
                                         animated:YES];
}

#pragma mark - emptyDataDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"img_blankpage_file"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString * title = DPLocalizedString(@"TFCR_NoFiles");
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:GOS_COLOR_RGBA(198, 198, 198, 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}


#pragma mark - iOSConfigSDKDMDelegate
- (void)reqMoth:(BOOL)isSuccess
     recordList:(NSArray <RecMonthDataModel*>*)dateList
      errorCode:(ReqRecListErrType)eType
{
    [SVProgressHUD dismiss];
    if (NO == isSuccess)
    {
        switch (eType)
        {
            case ReqRecListErr_unknow:      // 未知错误
            {
                GosLog(@"获取 TF 卡录像r日期列表失败：%ld", (long)eType);
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
            }
                break;
                
            case ReqRecListErr_param:       // 参数错误
            {
                GosLog(@"获取 TF 卡录像r日期列表失败：%ld", (long)eType);
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
            }
                break;
                
            case ReqRecListErr_noFiles:     // 没有录像文件
            {
                [self configNoFileTipsHidden:NO];
            }
                break;
                
            case ReqRecListErr_noSDCard:    // 没有插 TF 卡
            {
                [self configNoTFCardViewHidden:NO];
            }
                break;
                
            default:
            {
                GosLog(@"获取 TF 卡录像r日期列表失败：%ld", (long)eType);
                [SVProgressHUD showErrorWithStatus:DPLocalizedString(@"GosComm_getData_fail")];
            }
                break;
        }
    }
    else
    {
        GosLog(@"获取 TF 卡录像r日期列表成功，列表数量：%ld", (long)dateList.count);
        GOS_WEAK_SELF;
        dispatch_async([QueueManager bgQueue], ^{
            
            GOS_STRONG_SELF;
            strongSelf.recordDateList = [dateList mutableCopy];
            [strongSelf refreshTableView];
        });
    }
}

@end
