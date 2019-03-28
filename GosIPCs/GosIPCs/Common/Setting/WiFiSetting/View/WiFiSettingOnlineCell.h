//
//  WiFiSettingOnlineCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SsidInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface WiFiSettingOnlineCell : UITableViewCell

@property (nonatomic, strong) SsidInfoModel * cellModel;   // <#describtion#>
+ (instancetype)cellWithTableView:(UITableView *) tableView
                         indexPath:(NSIndexPath *) indexPath
                         cellModel:(SsidInfoModel *) cellModel;
@end

NS_ASSUME_NONNULL_END
