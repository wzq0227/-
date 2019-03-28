//
//  TableViewHeadView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewHeadView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (nonatomic, strong) NSString * titleStr;   // 文字
@end

NS_ASSUME_NONNULL_END
