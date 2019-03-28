//
//  CountrySelectViewController.h
//  ULife3.5
//
//  Created by 罗乐 on 2019/1/22.
//  Copyright © 2019 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectResultBlock)(NSString *country,NSString *num);

@interface CountrySelectViewController : UIViewController

@property (nonatomic, strong) SelectResultBlock resultBlock;

@end

NS_ASSUME_NONNULL_END
