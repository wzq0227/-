//
//  UIViewController+GosHiddenNavBar.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "UIViewController+GosHiddenNavBar.h"

@implementation UIViewController (GosHiddenNavBar)

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if(viewController == self)
    {
        [navigationController setNavigationBarHidden:YES
                                            animated:YES];
    }
    else
    {
        [navigationController setNavigationBarHidden:NO
                                            animated:YES];
    }
}

@end
