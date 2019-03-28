//
//  UIViewController+CommonExtension.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "UIViewController+CommonExtension.h"

@implementation UIViewController (CommonExtension)
#pragma mark - 初始化导航栏右边标题
- (void) configRightBtnTitle:(NSString *) title
                   titleFont:(UIFont *) font
                  titleColor:(UIColor *) titleColor{
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [rightBtn setAttributedTitle:string forState:UIControlStateNormal];
    
    rightBtn.frame = CGRectMake(0.0, 0.0, 40, 40);
    
    if (font) {
        rightBtn.titleLabel.font = font;
    }else{
        rightBtn.titleLabel.font = GOS_FONT(14);
    }
    
    if (titleColor) {
        [rightBtn setTitleColor:titleColor forState:UIControlStateNormal];
    }else{
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}
#pragma mark - 初始化导航栏右边图片
- (void)configRightBtnImg:(NSString *)imgStr{
    UIImage *addDevImg = [[UIImage imageNamed:imgStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightBarItem =  [[UIBarButtonItem alloc] initWithImage:addDevImg
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(rightBtnClicked)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void) rightBtnClicked{
    
}
@end
