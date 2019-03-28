//  CheckNetworkCell.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import "CheckNetworkCell.h"
#import "CheckNetResultModel.h"
@interface CheckNetworkCell()
@property (weak, nonatomic) IBOutlet UIImageView *markImage;        //  ✘√图
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView; //  菊花
@property (weak, nonatomic) IBOutlet UILabel *leftLab;  //  左边label
@property (weak, nonatomic) IBOutlet UILabel *middleLab;    //  中间的Label
@property (weak, nonatomic) IBOutlet UILabel *rightLab; //  右边label


@end

@implementation CheckNetworkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(nonnull CheckNetResultModel *)cellModel{
    [tableView registerNib:[UINib nibWithNibName:@"CheckNetworkCell" bundle:nil] forCellReuseIdentifier:@"CheckNetworkCell"];
    CheckNetworkCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CheckNetworkCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    return cell;
}

- (void)setCellModel:(CheckNetResultModel *)cellModel{
    
    self.leftLab.text = [self backInterceptIP:cellModel.serverIp serverPort:cellModel.serverPort];
    self.middleLab.text = [NSString stringWithFormat:@"%@%d",DPLocalizedString(@"Network_Sent"),cellModel.sentPack];
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        switch (cellModel.checkNwtstate) {
            case checkNetState_Detecting:{  //    检测中
                [strongSelf.activityView startAnimating];
                self.rightLab.text = @"";
            }break;
                
            case checkNetState_Success:{    //    网络良好
                [strongSelf.activityView stopAnimating];
                strongSelf.activityView.hidden = YES;
                strongSelf.markImage.image = [UIImage imageNamed:@"addev_success"];
                self.rightLab.text = [NSString stringWithFormat:@"%@%d",DPLocalizedString(@"Network_Received"),cellModel.sentPack];
            }break;
                
            case checkNetState_Fail:{       // 网络不通
                [strongSelf.activityView stopAnimating];
                strongSelf.activityView.hidden = YES;
                strongSelf.markImage.image = [UIImage imageNamed:@"icon_fault_network"];
                self.rightLab.text = [NSString stringWithFormat:@"%@%d",DPLocalizedString(@"Network_Received"),cellModel.sentPack -1];
            }break;
                
            default:
                break;
        }
    });
}

- (NSString *)backInterceptIP:(NSString *) serverIp
                   serverPort:(NSInteger) serverPort{
    NSArray *array = [serverIp componentsSeparatedByString:@"."]; //从字符A中分隔成2个元素的数组
    NSInteger serverPortStr = serverPort / 100;
    if (array.count == 4) {
        return [NSString stringWithFormat:@"***.%@.%@.%@ : %d**",[array objectAtIndex:1],[array objectAtIndex:2],[array lastObject],serverPortStr];
    }
    return @"serverIP error";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
