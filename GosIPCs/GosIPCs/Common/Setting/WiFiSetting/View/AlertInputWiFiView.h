//
//  AlertInputWiFiView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertInputWiFiViewDelegate <NSObject>
@optional;
- (void)alertInputViewCallBack:(NSString *) wifiName
                      password:(NSString *) password;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AlertInputWiFiView : UIView
@property (nonatomic, weak) id <AlertInputWiFiViewDelegate> delegate;
+ (instancetype)initWithFrame:(CGRect)frame
                     SSidName:(NSString *) wifiName
                     delegate:(id<AlertInputWiFiViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
