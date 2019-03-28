//  AboutViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AboutViewModel : NSObject <MineViewModelDelegate>

- (NSArray *)generateTableDataArray;

@end

NS_ASSUME_NONNULL_END
