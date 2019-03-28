//
//  VoiceMonitonModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/12/3.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"
NS_ASSUME_NONNULL_BEGIN

@interface VoiceMonitonModel : NSObject
@property (nonatomic, strong) NSString * iconImgStr;   // logo名
@property (nonatomic, strong) NSString * titleStr;   // 标题文字
@property (nonatomic, assign) BOOL isON;   // 开关
@property (nonatomic, assign) DetectLevel dLevel;   // 声音灵敏度
@end

NS_ASSUME_NONNULL_END
