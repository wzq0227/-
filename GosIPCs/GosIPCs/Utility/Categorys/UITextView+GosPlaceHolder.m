//  UITextView+GosPlaceHolder.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/24.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UITextView+GosPlaceHolder.h"
#import "objc/runtime.h"
#import "Masonry.h"

@interface UITextView ()
/// 占位
@property (nonatomic, readonly) UILabel *gosPlaceHolderLabel;
/// 限制
@property (nonatomic, readonly) UILabel *gosTextLimitLabel;
@end
@implementation UITextView (GosPlaceHolder)
+ (void)load {
    [super load];
    
    //方法交换
    method_exchangeImplementations(class_getInstanceMethod(self.class, @selector(layoutSubviews)),
                                   class_getInstanceMethod(self.class, @selector(swizzling_layoutSubviews)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self.class, @selector(swizzled_dealloc)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"setText:")),
                                   class_getInstanceMethod(self.class, @selector(swizzled_setText:)));
}


#pragma mark - swizzling
- (void)swizzled_dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self swizzled_dealloc];
}

- (void)swizzling_layoutSubviews{
    if (self.gosPlaceHolder) {
        UIEdgeInsets textContainerInset = self.textContainerInset;
        CGFloat lineFragmentPadding = self.textContainer.lineFragmentPadding;
        CGFloat x = lineFragmentPadding + textContainerInset.left + self.layer.borderWidth;
        CGFloat y = textContainerInset.top + self.layer.borderWidth;
        CGFloat width = CGRectGetWidth(self.bounds) - x - textContainerInset.right - 2*self.layer.borderWidth;
        CGFloat height = [self.gosPlaceHolderLabel sizeThatFits:CGSizeMake(width, 0)].height;
        self.gosPlaceHolderLabel.frame = CGRectMake(x, y, width, height);

    }
    if (self.gosTextLimitLabel) {
        UIEdgeInsets textContainerInset = self.textContainerInset;
        CGFloat x = 0;
        CGFloat y = CGRectGetHeight(self.bounds) + 5;
        CGFloat width = CGRectGetWidth(self.bounds) - x - textContainerInset.right - 10;
        CGFloat height = [self.gosTextLimitLabel sizeThatFits:CGSizeMake(width, 0)].height;
        self.gosTextLimitLabel.frame = CGRectMake(x, y, width, height);
    }
    [self swizzling_layoutSubviews];
}
/// 此方法理论上不会调用，但是以防万一
- (void)swizzled_setText:(NSString *)text{
    [self swizzled_setText:(self.textMaxLimit > 0 && text.length > self.textMaxLimit) ? [text substringToIndex:self.textMaxLimit] : text];
    
    if (self.gosPlaceHolder) {
        [self updatePlaceHolder];
    }
    if (self.gosTextLimitLabel) {
        [self updateTextLimit];
    }
}

#pragma mark - update
/// 统一更新自定义Label方法，响应UITextViewTextDidChangeNotification通知
- (void)updateCustomLabel {
    [self updatePlaceHolder];
    [self updateTextLimit];
}
/// 更新占位标签
- (void)updatePlaceHolder {
    // 字数为0就移除占位
    if (self.text.length) {
        [self.gosPlaceHolderLabel removeFromSuperview];
        return;
    }
    self.gosPlaceHolderLabel.font = self.font;
    self.gosPlaceHolderLabel.textAlignment = self.textAlignment;
    self.gosPlaceHolderLabel.text = self.gosPlaceHolder;
    [self insertSubview:self.gosPlaceHolderLabel atIndex:0];
    
}
/// 更新字数限制显示
- (void)updateTextLimit {
    // 超出字数限制就截掉
    if (self.text.length > self.textMaxLimit) {
        self.text = [self.text substringWithRange:NSMakeRange(0, self.textMaxLimit)];
    }
    self.gosTextLimitLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.text.length, self.textMaxLimit];
}
#pragma mark - getters and setters
- (UILabel *)gosPlaceHolderLabel {
    UILabel *placeHolderLab = objc_getAssociatedObject(self, _cmd);
    if (!placeHolderLab) {
        placeHolderLab = [[UILabel alloc] init];
        placeHolderLab.numberOfLines = 0;
        placeHolderLab.textColor = [UIColor lightGrayColor];
        objc_setAssociatedObject(self, @selector(gosPlaceHolderLabel), placeHolderLab, OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCustomLabel) name:UITextViewTextDidChangeNotification object:self];
    }
    return placeHolderLab;
}
- (void)setGosPlaceHolderLabel:(UILabel *)gosPlaceHolderLabel {
    objc_setAssociatedObject(self, @selector(gosPlaceHolderLabel), gosPlaceHolderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UILabel *)gosTextLimitLabel {
    UILabel *textLimitLab = objc_getAssociatedObject(self, _cmd);
    if (!textLimitLab) {
        textLimitLab = [[UILabel alloc] init];
        textLimitLab.numberOfLines = 0;
        textLimitLab.textColor = [UIColor blackColor];
        textLimitLab.font = GOS_FONT(12);
        textLimitLab.textAlignment = NSTextAlignmentRight;
        textLimitLab.text = [NSString stringWithFormat:@"0/%zd", self.textMaxLimit];
        objc_setAssociatedObject(self, @selector(gosTextLimitLabel), textLimitLab, OBJC_ASSOCIATION_RETAIN);
    }
    return textLimitLab;
}
- (void)setGosTextLimitLabel:(UILabel *)gosTextLimitLabel {
    objc_setAssociatedObject(self, @selector(gosTextLimitLabel), gosTextLimitLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTextLimit];
}
-(NSString *)gosPlaceHolder {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setGosPlaceHolder:(NSString *)gosPlaceHolder {
    objc_setAssociatedObject(self, @selector(gosPlaceHolder), gosPlaceHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updatePlaceHolder];
}
- (UIColor *)gosPlaceHolderColor {
    return self.gosPlaceHolderLabel.textColor;
}
- (void)setGosPlaceHolderColor:(UIColor *)gosPlaceHolderColor{
    self.gosPlaceHolderLabel.textColor = gosPlaceHolderColor;
}
- (NSString *)placeholder{
    return self.gosPlaceHolder;
}
- (void)setPlaceholder:(NSString *)placeholder{
    self.gosPlaceHolder = placeholder;
}
- (NSInteger)textMaxLimit {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (void)setTextMaxLimit:(NSInteger)textMaxLimit {
    objc_setAssociatedObject(self, @selector(textMaxLimit), @(textMaxLimit), OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 设置了最大限度就添加
    if (![self.gosTextLimitLabel superview]) {
        // 添加到父控件中去
        [self.superview addSubview:self.gosTextLimitLabel];
    }
}
- (UIColor *)textLimitColor {
    return self.gosTextLimitLabel.textColor;
}
- (void)setTextLimitColor:(UIColor *)textLimitColor {
    self.gosTextLimitLabel.textColor = textLimitColor;
}

@end
