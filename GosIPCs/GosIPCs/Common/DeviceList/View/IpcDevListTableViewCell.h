//
//  IpcDevListTableViewCell.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDKModel.h"
#import "UITableViewCell+DeviceListENUM.h"

NS_ASSUME_NONNULL_BEGIN

@interface IpcDevListTableViewCell : UITableViewCell
/** Cell 数据 */
@property (nonatomic, strong) DevDataModel *ipcDevListTBCellData;
/** Cell 事件回调 */
@property (nonatomic, readwrite, copy) CellClickActionBlock cellActionBlock;
@end

NS_ASSUME_NONNULL_END
