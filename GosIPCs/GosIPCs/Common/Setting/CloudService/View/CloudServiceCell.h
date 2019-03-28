//
//  CloudServiceCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CloudServiceModel;
@interface CloudServiceCell : UITableViewCell
/// cell模型
@property (nonatomic, strong) CloudServiceModel * cellModel;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                     andCellModel:(CloudServiceModel *) cellModel;
@end
