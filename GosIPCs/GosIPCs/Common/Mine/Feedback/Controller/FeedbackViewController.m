//  FeedbackViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "FeedbackViewController.h"
#import "FeedbackCallbackViewController.h"
#import "UITextView+GosPlaceHolder.h"
#import "UIColor+GosColor.h"
#import "UIButton+GosGradientButton.h"
#import "GosHUD.h"

@interface FeedbackViewController () <UITextViewDelegate>
/// 输入框，内建占位符、字数限制显示
@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
/// 提交按钮
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
/// 标记界面即将消失
@property (nonatomic, assign, getter=isViewWillDisappeared) BOOL viewWillDisappeared;
@end

@implementation FeedbackViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 标题
    self.title = DPLocalizedString(@"Mine_AdviceFeedback");
    // 输入框
    self.feedbackTextView.gosPlaceHolder = @"请输入您的宝贵意见（500字以内）";
    self.feedbackTextView.gosPlaceHolderColor = [UIColor gosLightGrayColor];
    self.feedbackTextView.textMaxLimit = 500;
    // 提交按钮
    [self.submitButton setupGradientStartColor:GOSCOM_THEME_START_COLOR endColor:GOSCOM_THEME_END_COLOR cornerRadiusFromHeightRatio:0.5 direction:GosGradientLeftToRight];
    
    // 键盘消失通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillDisappeared = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewWillDisappeared = YES;
}

#pragma mark - Notification method
// 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    // 防止键盘存在时，返回的时候，界面下移导致的一闪而过的黑屏
    if (self.isViewWillDisappeared) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-44-CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]), self.view.frame.size.width, self.view.frame.size.height);
        
    }
}
#pragma mark - events action
- (IBAction)submitButtonDidClick:(id)sender {
    [self.view endEditing:YES];
    GosLog(@"%s", __PRETTY_FUNCTION__);
    [self successAction];
}
/// 提交成功响应
- (void)successAction {
    
    [self.navigationController pushViewController:[[FeedbackCallbackViewController alloc] init] animated:YES];
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [temp removeObject:self];
    
}

@end
