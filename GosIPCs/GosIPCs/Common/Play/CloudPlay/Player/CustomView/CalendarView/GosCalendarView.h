//  GosCalendarView.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/2.
//  Copyright © 2019年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class GosCalendarView;
/**
 GosCalendarView回调代理
 */
@protocol GosCalendarViewDelegate <NSObject>
/// 选择日期已经改变
- (void)calendarView:(GosCalendarView *)calendarView selectedDateDidChanged:(NSDate *)selectedDate hasEvent:(BOOL)hasEvent;
/// 显示日期已经改变
- (void)calendarView:(GosCalendarView *)calendarView displayDateDidChanged:(NSDate *)currentDate;

@required
- (void)calendarView:(GosCalendarView *)calenderView displayDetailViewInView:(UIView **)view frame:(CGRect *)frame;
@end


/**
 日历，可左右切换日子，
 */
@interface GosCalendarView : UIView
/// 代理
@property (nonatomic, weak) id<GosCalendarViewDelegate> delegate;

/// 外部驱动当前日期改变
- (void)updateDisplayDate:(NSDate *)displayDate;
/// 需要更新事件数据
- (void)updateEventsArray:(NSArray <NSDate *> *)eventsArray;

@end

@interface GosCalendarBarView : UIView
@property (nonatomic, readonly, strong) UIButton *calenderButton;
@property (nonatomic, readonly, strong) UIButton *backwardButton;
@property (nonatomic, readonly, strong) UIButton *forwardButton;
@end

#pragma mark - GosCalendarDetailView
@class GosCalendarDetailViewCellModel;
/// 点击回调block
typedef void(^GosCalendarDetailViewSelectedBlock)(NSDate *selectedDate, BOOL hasEvent);
/**
 日历列表
 */
@interface GosCalendarDetailView : UIView
/// 事件数组
@property (nonatomic, copy) NSArray *eventsArray;
/// 当前已选择的日期
@property (nonatomic, copy) NSDate *selectedDate;
/// 当前日历列表所在的年月
@property (nonatomic, copy) NSDate *currentDate;
/// 是否允许事件传递，决定eventsArray是否能够生效
@property (nonatomic, assign, getter=isDisableEvents) BOOL disableEvents;
/// 回调
@property (nonatomic, copy) GosCalendarDetailViewSelectedBlock callback;

+ (void)showWithTargetView:(UIView *)targetView
               attachFrame:(CGRect)attachFrame
              displayframe:(CGRect)displayframe
               currentDate:(NSDate *)currentDate
               eventsArray:(NSArray <NSDate *> *_Nullable)eventsArray
      selectedDateCallBack:(GosCalendarDetailViewSelectedBlock)selectedDateCallBack;

@end


#pragma mark - GosCalendarDetailViewCellModel
/**
 cell模型
 */
@interface GosCalendarDetailViewCellModel : NSObject
/// 日期
@property (nonatomic, copy) NSDate *date;
/// 标题
@property (nonatomic, copy) NSString *text;
/// 标题颜色
@property (nonatomic, readonly, copy) UIColor *textColor;
/// 选择状态
@property (nonatomic, assign, getter=isSelected) BOOL selected;
/// 是否有事件，默认YES
@property (nonatomic, assign, getter=isHasEvent) BOOL hasEvent;
/// 是否不可选，只对cell是否可点击有效
@property (nonatomic, assign, getter=isDisable) BOOL disable;

/// 初始化
+ (instancetype)modelWithDate:(NSDate *)date
                         text:(NSString *)text
                     selected:(BOOL)selected
                     hasEvent:(BOOL)hasEvent
                      disable:(BOOL)disable;
@end


#pragma mark - GosCalendarDetailViewCell
/**
 UICollectionViewCell
 */
@interface GosCalendarDetailViewCell : UICollectionViewCell
/// 初始化
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath model:(GosCalendarDetailViewCellModel *)model;
@end


#pragma mark - GosCalenderDetailViewLayout : UICollectionViewLayout
/**
 UICollectionViewLayout
 */
@interface GosCalenderDetailViewLayout : UICollectionViewLayout
/// 当前日期
@property (nonatomic, copy) NSDate *currentDate;
@end

NS_ASSUME_NONNULL_END
