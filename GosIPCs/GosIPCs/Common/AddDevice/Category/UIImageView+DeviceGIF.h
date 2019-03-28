//
//  UIImageView+DeviceGIF.h
//  Goscom
//
//  Created by 罗乐 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (DeviceGIF)
- (BOOL)playGIFWithDeviceID:(NSString *)devID;
@end

NS_ASSUME_NONNULL_END
