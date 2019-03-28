//  NetCheckViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2019/1/18.
//  Copyright © 2019 goscam. All rights reserved.

#import "NetCheckViewModel.h"
#import "CheckNetResultModel.h"
#import "iOSConfigSDKModel.h"

@implementation NetCheckViewModel
#pragma mark -- 处理请求到要检测的地址
+ (NSArray<CheckNetResultModel *> *)handleTableArr:(NSArray<ServerAddressInfo *> *)normalArr{
    NSMutableArray * dataArr = [NSMutableArray new];
    [normalArr enumerateObjectsUsingBlock:^(ServerAddressInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CheckNetResultModel * model = [CheckNetResultModel new];
        model.checkNwtstate = checkNetState_Detecting;
        model.serverType = obj.serverType;
        model.serverIp = obj.serverIp;
        model.serverPort = obj.serverPort;
        model.sentPack = arc4random_uniform(10)+1;  //  随机数
        [dataArr addObject:model];
    }];
    return dataArr;
}
#pragma mark -- 处理检测到的结果给table数组
+ (void)handleCheckState:(BOOL)isReachable
          withCheckModel:(ServerAddressInfo *) checkModel
            withTableArr:(NSMutableArray <CheckNetResultModel *>*) tableArr{
    [tableArr enumerateObjectsUsingBlock:^(CheckNetResultModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.serverType == checkModel.serverType &&
            obj.serverPort == checkModel.serverPort &&
            obj.serverIp == checkModel.serverIp) {
            obj.checkNwtstate = isReachable?checkNetState_Success:checkNetState_Fail;
        }
    }];
}
@end
