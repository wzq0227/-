//  MineSetupViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "MineViewModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineSetupViewModel : NSObject <MineViewModelDelegate>

- (NSArray *)generateTableDataArray;

@end

NS_ASSUME_NONNULL_END
