//
//  TFCRMediaListViewController.h
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFCRMediaListViewController : UIViewController

@property (nonatomic, readwrite, strong) DevDataModel *devModel;
@property (nonatomic, readwrite, copy) NSString *recordDateStr;

@end

NS_ASSUME_NONNULL_END
