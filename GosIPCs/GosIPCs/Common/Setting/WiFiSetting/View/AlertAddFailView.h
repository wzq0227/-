//
//  AlertAddFailView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSInteger, BackType){
    BackType_DeviceList,        // 返回设备列表界面
    BackType_WiFiSetting,       // 返回配置WiFi界面
};

@protocol AlertAddFailViewDelegate <NSObject>

- (void)AlertAddFailClick:(BackType) backType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AlertAddFailView : UIView
/// 返回类型
@property (nonatomic, assign) BackType backType;
/// 代理
@property (nonatomic, weak) id<AlertAddFailViewDelegate> delegate;
+ (instancetype)initWithDelegate:(id<AlertAddFailViewDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
