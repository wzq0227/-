//  FeedbackCallbackViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "FeedbackCallbackViewController.h"

@interface FeedbackCallbackViewController ()
//@property (nonatomic, copy) NSTimer *waitterTimer;
@end

@implementation FeedbackCallbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = DPLocalizedString(@"Mine_AdviceFeedback");
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.waitterTimer fire];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    _waitterTimer = nil;
//    [_waitterTimer invalidate];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self waitterTimerDidTimesUp:nil];
}

- (void)waitterTimerDidTimesUp:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//- (NSTimer *)waitterTimer {
//    if (!_waitterTimer) {
//        _waitterTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(waitterTimerDidTimesUp:) userInfo:nil repeats:NO];
//    }
//    return _waitterTimer;
//}
@end
