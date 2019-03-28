//
//  LightDurationVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
typedef NS_ENUM(NSInteger, OnOffTimeType) {
    OnOffTimeType_ON,       //  当前选中的是开
    OnOffTimeType_OFF,      //  当前选中的是关
};
NS_ASSUME_NONNULL_BEGIN

/**
 灯照时长界面
 */
@interface LightDurationVC : UIViewController
/// 模型
@property (nonatomic, strong) DevDataModel * dataModel;
@end

NS_ASSUME_NONNULL_END
