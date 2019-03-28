//  CloudPackageDetailVC.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/12.
//  Copyright © 2019 goscam. All rights reserved.

#import "CloudPackageDetailVC.h"
#import "PackageValidTimeApiRespModel.h"
#import "CloudServiceVC.h"
@interface CloudPackageDetailVC ()
@property (weak, nonatomic) IBOutlet UILabel *tips1Lab; // 7天云储存
@property (weak, nonatomic) IBOutlet UILabel *tips2Lab; // 有效期
@property (weak, nonatomic) IBOutlet UILabel *tips3Lab; // 视频保留时间
@property (weak, nonatomic) IBOutlet UILabel *title1Lab; // 使用中
@property (weak, nonatomic) IBOutlet UILabel *title2Lab; // 2018/10/22—2018/11/12
@property (weak, nonatomic) IBOutlet UILabel *title3Lab; // 7天
@property (weak, nonatomic) IBOutlet UIButton *renewalBtn;

@end

@implementation CloudPackageDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}
- (void)configUI{
    self.title = DPLocalizedString(@"Cloud_PackageDetails");
    self.renewalBtn.layer.cornerRadius =20.0f;
    self.renewalBtn.clipsToBounds = YES;
    self.tips2Lab.text = DPLocalizedString(@"Cloud_PackageValidTime");
    self.tips3Lab.text = DPLocalizedString(@"Cloud_VideoReservedTime");
    [self.renewalBtn setTitle:DPLocalizedString(@"Cloud_PackageRenew") forState:UIControlStateNormal];
}

- (void)setPackageModel:(PackageValidTimeApiRespModel *)PackageModel{
    _PackageModel = PackageModel;
    NSString * startTime = [self getTimeFromTimesTamp:PackageModel.startTime];
    NSString * endTime = [self getTimeFromTimesTamp:PackageModel.dataExpiredTime];
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        strongSelf.tips1Lab.text = PackageModel.planName;
        strongSelf.title2Lab.text = [NSString stringWithFormat:@"%@——%@",startTime,endTime];
        strongSelf.title3Lab.text = [NSString stringWithFormat:@"%@%@",PackageModel.dataLife,DPLocalizedString(@"CS_PackageType_Days")];
        switch (PackageModel.cloudServicePackageStatusType) {
            case CloudServicePackageStatusTypeInUse:{
                strongSelf.title1Lab.text = DPLocalizedString(@"Mine_InUse");
            }break;
            case CloudServicePackageStatusTypeUnbind:{
                strongSelf.title1Lab.text = DPLocalizedString(@"Mine_Unpurchased");
            }break;
            case CloudServicePackageStatusTypeUnused:{
                strongSelf.title1Lab.text = DPLocalizedString(@"Mine_Unuse");
            }break;
            case CloudServicePackageStatusTypeExpired:{
                strongSelf.title1Lab.text = DPLocalizedString(@"Mine_Expired");
            }break;
            case CloudServicePackageStatusTypeForbidden:{
                strongSelf.title1Lab.text = DPLocalizedString(@"Mine_Unpurchased");
            }break;
            default:
                break;
        }
    });
}
#pragma mark - 续费点击
- (IBAction)actionRenewalClick:(UIButton *)sender {
    CloudServiceVC * vc = [[CloudServiceVC alloc] init];
    vc.dataModel = self.dataModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 将某个时间戳转化成 时间
- (NSString *)getTimeFromTimesTamp:(NSString *)timeStr{
    long long time = [timeStr longLongValue];
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY/MM/dd"];
     NSString *timeS = [formatter stringFromDate:myDate];
    return timeS;
}
@end
