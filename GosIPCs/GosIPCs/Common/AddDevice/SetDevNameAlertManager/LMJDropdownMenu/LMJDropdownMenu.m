//
//  LMJDropdownMenu.m
//
//  Version:1.0.0
//
//  Created by MajorLi on 15/5/4.
//  Copyright (c) 2015年 iOS开发者公会. All rights reserved.
//
//  iOS开发者公会-技术1群 QQ群号：87440292
//  iOS开发者公会-技术2群 QQ群号：232702419
//  iOS开发者公会-议事区  QQ群号：413102158
//

#import "LMJDropdownMenu.h"
#import "DropdownMenuCell.h"


#define VIEW_CENTER(aView)       ((aView).center)
#define VIEW_CENTER_X(aView)     ((aView).center.x)
#define VIEW_CENTER_Y(aView)     ((aView).center.y)

#define FRAME_ORIGIN(aFrame)     ((aFrame).origin)
#define FRAME_X(aFrame)          ((aFrame).origin.x)
#define FRAME_Y(aFrame)          ((aFrame).origin.y)

#define FRAME_SIZE(aFrame)       ((aFrame).size)
#define FRAME_HEIGHT(aFrame)     ((aFrame).size.height)
#define FRAME_WIDTH(aFrame)      ((aFrame).size.width)



#define VIEW_BOUNDS(aView)       ((aView).bounds)

#define VIEW_FRAME(aView)        ((aView).frame)

#define VIEW_ORIGIN(aView)       ((aView).frame.origin)
#define VIEW_X(aView)            ((aView).frame.origin.x)
#define VIEW_Y(aView)            ((aView).frame.origin.y)

#define VIEW_SIZE(aView)         ((aView).frame.size)
#define VIEW_HEIGHT(aView)       ((aView).frame.size.height)
#define VIEW_WIDTH(aView)        ((aView).frame.size.width)


#define VIEW_X_Right(aView)      ((aView).frame.origin.x + (aView).frame.size.width)
#define VIEW_Y_Bottom(aView)     ((aView).frame.origin.y + (aView).frame.size.height)






#define AnimateTime 0.25f   // 下拉动画时间



@implementation LMJDropdownMenu
{
    UIImageView * _arrowMark;   // 尖头图标
    UIView      * _listView;    // 下拉列表背景View
    UITableView * _tableView;   // 下拉列表
    
    NSArray     * _titleArr;    // 选项数组
    CGFloat       _rowHeight;   // 下拉列表行高
}

static  NSString * const cellIdentifier = @"DropdownMenuCellID";

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createMainBtnWithFrame:frame];
    }
    return self;
} 

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];

    [self createMainBtnWithFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutMainBtn];
    [self layoutListView];
    if (self.isNeedShowDropMenuAfterInit) {
        [self showDropDown];
    }
}

- (void)layoutMainBtn {
    [_mainBtn setFrame:self.bounds];
    _mainBtn.hidden = YES;
//    _mainBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, (self.frame.size.width - _mainBtn.titleLabel.width) / 2, 0, 0);
//    [_arrowMark setFrame:CGRectMake((self.frame.size.width + _mainBtn.titleLabel.frame.size.width) / 2 + 10, 0, 12, 12)];
//    _arrowMark.center = CGPointMake(VIEW_CENTER_X(_arrowMark), VIEW_HEIGHT(_mainBtn)/2);
}

- (void)layoutListView {
    _listView.frame = CGRectMake(VIEW_X(self) , VIEW_Y_Bottom(self), VIEW_WIDTH(self),  0);
    _tableView.frame = CGRectMake(0, 0,VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
}

- (void)createMainBtnWithFrame:(CGRect)frame{
    
    [_mainBtn removeFromSuperview];
    _mainBtn = nil;
    
    // 主按钮 显示在界面上的点击按钮
    // 样式可以自定义
    _mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_mainBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [_mainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_mainBtn setTitle:@"my_device" forState:UIControlStateNormal];
    [_mainBtn addTarget:self action:@selector(clickMainBtn:) forControlEvents:UIControlEventTouchUpInside];
//    _mainBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    _mainBtn.titleLabel.font    = [UIFont systemFontOfSize:14.f];
    _mainBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    _mainBtn.titleLabel.backgroundColor = [UIColor redColor];
//    _mainBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, 15, 0, 0);
    _mainBtn.selected           = NO;
    _mainBtn.backgroundColor    = [UIColor clearColor];
//    _mainBtn.layer.borderColor  = [UIColor blackColor].CGColor;
//    _mainBtn.layer.borderWidth  = 1;

    [self addSubview:_mainBtn];
    
    
    // 旋转尖头
//    _arrowMark = [[UIImageView alloc] init];
//                  initWithFrame:CGRectMake(_mainBtn.frame.size.width - 15, 0, 9, 9)];
//    _arrowMark.center = CGPointMake(VIEW_CENTER_X(_arrowMark), VIEW_HEIGHT(_mainBtn)/2);
//    _arrowMark.image  = [UIImage imageNamed:@"dropdownMenu_cornerIcon.png"];
//    [_mainBtn addSubview:_arrowMark];

}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//
//    if (self.userInteractionEnabled == NO && self.alpha <= 0.01 && self.hidden == YES) {
//        return nil;
//    }
//
//
//    for (UIView * subview in self.subviews.reverseObjectEnumerator) {
//
//        CGPoint converP = [subview convertPoint:point fromView:self];
//        UIView *suitableView = [subview hitTest:converP withEvent:event];
//
//        if (suitableView) {
//            return suitableView;
//        }
//    }
//
//    return view;
//}

- (void)setMenuTitles:(NSArray *)titlesArr rowHeight:(CGFloat)rowHeight{
    
    if (self == nil) {
        return;
    }
    
    _titleArr  = [NSArray arrayWithArray:titlesArr];
    _rowHeight = rowHeight;

    
    // 下拉列表背景View
    _listView = [[UIView alloc] init];
//    _listView.frame = CGRectMake(VIEW_X(self) , VIEW_Y_Bottom(self), VIEW_WIDTH(self),  0);
    _listView.clipsToBounds       = YES;
    _listView.layer.masksToBounds = NO;
//    _listView.layer.borderColor   = [UIColor lightTextColor].CGColor;
//    _listView.layer.borderWidth   = 0.5f;

    
    // 下拉列表TableView
    _tableView = [[UITableView alloc] init];
//                  WithFrame:CGRectMake(0, 0,VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView))];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.bounces         = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    UINib *nib = [UINib nibWithNibName:@"DropdownMenuCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [_listView addSubview:_tableView];
    [self.superview addSubview:_listView];
}

- (void)clickMainBtn:(UIButton *)button{
    
//    [self.superview addSubview:_listView]; // 将下拉视图添加到控件的俯视图上
    
    if(button.selected == NO) {
        [self showDropDown];
    }
    else {
        [self hideDropDown];
    }
}

- (void)changeMenuStatus {
    [self clickMainBtn:_mainBtn];
}

- (BOOL)isMenuDrop {
    return _mainBtn.selected;
}

- (void)showDropDown{   // 显示下拉列表
    _mainBtn.hidden = NO;
    [_listView.superview bringSubviewToFront:_listView]; // 将下拉列表置于最上层
    
    
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuWillShow:)]) {
        [self.delegate dropdownMenuWillShow:self]; // 将要显示回调代理
    }
    
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
//        _arrowMark.transform = CGAffineTransformMakeRotation(M_PI);
        _listView.frame  = CGRectMake(VIEW_X(_listView), VIEW_Y(_listView), VIEW_WIDTH(_listView), _rowHeight *_titleArr.count);
        _tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
        
    }completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
            [self.delegate dropdownMenuDidShow:self]; // 已经显示回调代理
        }
    }];
    
    
    
    _mainBtn.selected = YES;
}
- (void)hideDropDown{  // 隐藏下拉列表
    _mainBtn.hidden = YES;
    [self.superview addSubview:_listView];
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuWillHidden:)]) {
        [self.delegate dropdownMenuWillHidden:self]; // 将要隐藏回调代理
    }
    
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
//        _arrowMark.transform = CGAffineTransformIdentity;
        _listView.frame  = CGRectMake(VIEW_X(_listView), VIEW_Y(_listView), VIEW_WIDTH(_listView), 0);
        _tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
        
    }completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenuDidHidden:)]) {
            [self.delegate dropdownMenuDidHidden:self]; // 已经隐藏回调代理
        }
    }];
    
    
    
    _mainBtn.selected = NO;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        //---------------------------下拉选项样式，可在此处自定义-------------------------
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        cell.textLabel.font          = [UIFont systemFontOfSize:11.f];
//        cell.textLabel.textColor     = [UIColor blackColor];
//        cell.selectionStyle          = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
//
//        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, _rowHeight -0.5, VIEW_WIDTH(cell), 0.5)];
//        line.backgroundColor = [UIColor whiteColor];
//        [cell addSubview:line];
//        //---------------------------------------------------------------------------
//    }
//
//    cell.textLabel.text =[_titleArr objectAtIndex:indexPath.row];
    
    DropdownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = (NSString *)[_titleArr objectAtIndex:indexPath.row];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    DropdownMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [_mainBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//    [_mainBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//    [_mainBtn.titleLabel setNeedsLayout];
//    [self layoutMainBtn];
//    [_mainBtn setNeedsLayout];
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:selectedCellNumber:)]) {
        [self.delegate dropdownMenu:self selectedCellNumber:indexPath.row]; // 回调代理
    }
    
    [self hideDropDown];
}
@end
