//
//  MsgListTableViewCell.h
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/17.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushMessage.h"


typedef void(^SelectedBtnActionBlock)(BOOL isSeleted);


@interface MsgListTableViewCell : UITableViewCell

@property (nonatomic, readwrite, strong) PushMessage *msgListCellData;
@property (nonatomic, readwrite, assign) BOOL isEditing;    // 是否正在编辑
@property (nonatomic, readwrite, assign) BOOL hasSelected;  // 是否已选中
@property (nonatomic, readwrite, assign) BOOL hiddenSeperateLine;
@property (nonatomic, readwrite, assign) BOOL isShowIndicatorView;  // 是否显示‘高亮提示view’
@property (nonatomic, readwrite, copy) SelectedBtnActionBlock selectedBtnAction;

@end
