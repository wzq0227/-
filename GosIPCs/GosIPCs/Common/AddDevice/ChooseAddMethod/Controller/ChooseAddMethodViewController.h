//
//  ChooseAddMethodViewController.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/14.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceAddtionMethodTableViewCell.h"

typedef void (^ChooseAddMethodResultBlock)(SupportAddStyle addType);

@interface ChooseAddMethodViewController : UIViewController

@property (nonatomic, strong) ChooseAddMethodResultBlock resultBlock;

@property (nonatomic, strong) NSArray<NSNumber *> *addMethodArr;

@end
