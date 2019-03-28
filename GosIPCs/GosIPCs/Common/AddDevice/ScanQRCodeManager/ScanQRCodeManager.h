//
//  ScanQRCodeManager.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanQRCodeManager : NSObject

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)startScanQrCode;

@end
