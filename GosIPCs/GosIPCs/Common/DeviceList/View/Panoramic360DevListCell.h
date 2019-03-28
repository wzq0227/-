//  Panoramic360DevListCell.h
//  Goscom
//
//  Create by 匡匡 on 2019/2/19.
//  Copyright © 2019 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "UITableViewCell+DeviceListENUM.h"
@class DevDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface Panoramic360DevListCell : UITableViewCell
/** Cell 数据 */
@property (nonatomic, strong) DevDataModel *PanoramicDevListTBCellData;
/** Cell 事件回调 */
@property (nonatomic, readwrite, copy) CellClickActionBlock cellActionBlock;
@end

NS_ASSUME_NONNULL_END
