//
//  CloudOrderInfoCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CloudOrderModel;
NS_ASSUME_NONNULL_BEGIN

@interface CloudOrderInfoCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(CloudOrderModel *) cellModel
                        indexPath:(NSIndexPath *) indexPath;
@end

NS_ASSUME_NONNULL_END
