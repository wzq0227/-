//
//  MsgDetailViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VCDismissBlock)(BOOL isDismiss, NSUInteger curMsgIndex);

typedef void(^UpdateHasReadBlock)(NSUInteger index);

typedef void(^HasSwipBlock)(BOOL hasSwipe);

@interface MsgDetailViewController : UIViewController

@property (nonatomic, readwrite, strong) PushMessage *pushMsg;
@property (nonatomic, readwrite, copy) VCDismissBlock vcDismissBlock;
@property (nonatomic, readwrite, copy) UpdateHasReadBlock updateHasRead;
@property (nonatomic, readwrite, copy) HasSwipBlock hasSwipBlock;
/** 是否只可以切换当前设备推送消息（默认是，若否，则可以切换所有设备推送消息） */
@property (nonatomic, readwrite, assign) BOOL isOnlyShowOnDevMsg;


@end

NS_ASSUME_NONNULL_END
