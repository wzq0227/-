//  ADDIotProtocol.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADDIotProtocolDelegate <NSObject>
@optional;
-(void) callBackState:(AddIOTStatus) callBackState
           gosIOTType:(GosIOTType) gosIOTType
          sensorId:(NSString *) sensorId;

@end

@interface ADDIotProtocol : NSObject

@end

NS_ASSUME_NONNULL_END
