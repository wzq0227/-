//
//  AddSensorCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IotSensorModel;

@protocol addSensorCellDelegate  <NSObject>
@optional;
- (void) modifySensorName:(IotSensorModel *) cellModel;
- (void) modifySensorSwitch:(IotSensorModel *) cellModel;

@end
NS_ASSUME_NONNULL_BEGIN

@interface AddSensorCell : UITableViewCell
/// 代理
@property (nonatomic, weak) id <addSensorCellDelegate> delegate;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSensorModel *) cellModel
                          delegate:(id<addSensorCellDelegate>) delegate;
/// 模型数据
@property (nonatomic, strong) IotSensorModel * cellModel;
@end

NS_ASSUME_NONNULL_END
