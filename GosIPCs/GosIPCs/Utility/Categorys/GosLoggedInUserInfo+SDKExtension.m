//  GosLoggedInUserInfo+SDKExtension.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosLoggedInUserInfo+SDKExtension.h"

@implementation GosLoggedInUserInfo (SDKExtension)

+ (ServerAreaType)sdkServerArea {
    ServerAreaType  serverArea = ServerArea_domestic;
    switch ([self serverArea])
    {
        case LoginServerNorthAmerica:   // 北美
        {
            serverArea = ServerArea_overseas;
        }
            break;
            
        case LoginServerEuropean:       // 欧洲
        {
            serverArea = ServerArea_overseas;
        }
            break;
            
        case LoginServerChina:          // 中国
        {
            serverArea = ServerArea_domestic;
        }
            break;
            
        case LoginServerAsiaPacific:    // 亚太
        {
            serverArea = ServerArea_overseas;
        }
            break;
            
        case LoginServerMiddleEast:     // 中东
        {
            serverArea = ServerArea_overseas;
        }
            break;
            
        default:
            break;
    }
    return serverArea;
}
// FIXME: sdk账户类型算法
+ (AccountType)sdkAccountType {
    return Account_email;
}
@end
