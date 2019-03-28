//
//  TFCRMediaListTableViewCell.h
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFCRMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 结束下载原因类型 枚举 */
typedef NS_ENUM(NSInteger, StopDowloadReasonType) {
    StopDowloadReason_cancel            = -2,       // 取消失败
    StopDowloadReason_failure           = -1,       // 下载失败
    StopDowloadReason_notYet            = 0,        // 还未下载
    StopDowloadReason_success           = 1,        // 下载成功
};

typedef void(^SelectedBtnActionBlock)(BOOL isSeleted);

@interface TFCRMediaListTableViewCell : UITableViewCell

@property (nonatomic, readwrite, strong) TFCRMediaModel *mediaData;
@property (nonatomic, readwrite, assign) BOOL isEditing;    // 是否正在编辑
@property (nonatomic, readwrite, assign) BOOL hasSelected;  // 是否已选中
@property (nonatomic, readwrite, copy) SelectedBtnActionBlock selectedBtnActionBlock;

/*
 开始下载
 */
- (void)startDownload;

/*
 下载中
 
 @param progress 下载进度
 */
- (void)downloading:(float)progress;

/*
 结束下载
 
 @param result 结束下载下载；YES：是，NO：下载失败
 */
- (void)endDownload:(StopDowloadReasonType)result;

@end

NS_ASSUME_NONNULL_END
