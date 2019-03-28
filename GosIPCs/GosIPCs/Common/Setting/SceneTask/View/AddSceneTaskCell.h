//  AddSceneTaskCell.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class IotSensorModel;
NS_ASSUME_NONNULL_BEGIN

@interface AddSceneTaskCell : UITableViewCell
/// cell数组模型
@property (nonatomic, strong) IotSensorModel * cellModel;
+ (instancetype) cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSensorModel *) cellModel;
@end

NS_ASSUME_NONNULL_END
