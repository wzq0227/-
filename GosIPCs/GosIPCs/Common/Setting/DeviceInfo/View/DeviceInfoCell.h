//
//  DeviceInfoCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeviceInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *dataLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (nonatomic, strong) DeviceInfoModel * cellModel;   // 数据模型

+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        infoModel:(DeviceInfoModel *) infoModel;

@end

NS_ASSUME_NONNULL_END
