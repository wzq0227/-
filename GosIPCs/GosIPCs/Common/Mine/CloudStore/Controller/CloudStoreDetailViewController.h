//  CloudStoreDetailViewController.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/5.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CloudStoreCellModel;

/**
 设备云服务详情页
 */
@interface CloudStoreDetailViewController : UIViewController

- (instancetype)initWithCellModel:(CloudStoreCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
