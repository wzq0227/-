//
//  SettingPhotoAlbumVC.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//  相册界面

#import "SettingPhotoAlbumVC.h"
#import "SettingPhotoVC.h"
#import "SettingVideoVC.h"
#import "iOSConfigSDKModel.h"
#import "SettingPhotoAlbumCell.h"
#import "PhotoAlbumModel.h"
#import "MessageCenterToolBar.h"
#import "PhotoAlbumViewModel.h"
#import "UIScrollView+EmptyDataSet.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GosPhotoHelper.h"

typedef NS_ENUM(NSInteger, PhotoAlbumState) {
    PhotoAlbumState_Empty,          // 无视频或图片状态
    PhotoAlbumState_Default,        // 默认状态
    PhotoAlbumState_Editing,        // 编辑状态
};
typedef NS_ENUM(NSInteger,PhotoAlbumType) {
    PhotoAlbumType_Photo,       //  图片
    PhotoAlbumType_Video,       //  视频
};
@interface SettingPhotoAlbumVC ()
<UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>
///  滚动视图
@property (nonatomic, strong) UIScrollView * scrollView;
/// 视频Tableview
@property (nonatomic, strong) UITableView * VideoTableView;
/// 图片TableView
@property (nonatomic, strong) UITableView * PhotoTableView;
/// segControl
@property (nonatomic, strong) UISegmentedControl * segControl;
/// 视频数组
@property (nonatomic, strong) NSMutableArray <PhotoAlbumModel*>* videoMutArr;
/// 图片数组
@property (nonatomic, strong) NSMutableArray <PhotoAlbumModel*>* photoMutArr;
/// 编辑工具
@property (nonatomic, strong) MessageCenterToolBar *editToolBar;
/// 当前选中的album类型
@property (nonatomic, assign) PhotoAlbumType selectType;
/// 页面状态
@property (nonatomic, assign) __block PhotoAlbumState viewState;
/// 右侧按钮
@property (nonatomic, strong) UIButton * rightBtn;
@end

@implementation SettingPhotoAlbumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self configDefault];
}
#pragma mark -- config
- (void)configUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.titleView = self.segControl;
    [self.view addSubview:self.scrollView];
    // 配置底部编辑视图
    [self.view addSubview:self.editToolBar];
    [self.editToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin);
        make.height.mas_equalTo(40);
    }];
    
    // 右上角设置为空的
    UIButton * tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [tempBtn setAttributedTitle:string forState:UIControlStateNormal];
    tempBtn.frame = CGRectMake(0.0, 0.0, 40, 40);
    tempBtn.titleLabel.font = GOS_FONT(14);
    [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   
    [tempBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = tempBtn;
    
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
    
}
- (void)configDefault{
    // 默认设置页面为无视频图片
    self.viewState = PhotoAlbumState_Empty;
    // 默认选中左边的视频
    self.selectType = PhotoAlbumType_Video;
    // 观察tableDataArray
    [self addObserver:self forKeyPath:@"videoMutArr" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"photoMutArr" options:NSKeyValueObservingOptionNew context:nil];
    
    [self willChangeValueForKey:@"videoMutArr"];
    self.videoMutArr = [PhotoAlbumViewModel getDefaultVideoTableArr:self.dataModel];
    [self didChangeValueForKey:@"videoMutArr"];
    
    [self willChangeValueForKey:@"photoMutArr"];
    self.photoMutArr = [PhotoAlbumViewModel getDefaultPhotoTableArr:self.dataModel];
    [self didChangeValueForKey:@"photoMutArr"];
}

#pragma mark - observer method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"videoMutArr"]  && PhotoAlbumType_Video == self.selectType) {
        /// 非编辑状态下检查是否存在有效数据，从而改变页面状态
        if (self.viewState != PhotoAlbumState_Editing) {
            self.viewState = (self.videoMutArr.count>0)?PhotoAlbumState_Default:PhotoAlbumState_Empty;
        }
    }else if([keyPath isEqualToString:@"photoMutArr"] && PhotoAlbumType_Photo == self.selectType){
        if (self.viewState != PhotoAlbumState_Editing) {
            self.viewState = (self.photoMutArr.count>0)?PhotoAlbumState_Default:PhotoAlbumState_Empty;
        }
    }
}
#pragma mark -- function
/// 编辑/取消按钮响应
- (void)rightBtnClicked:(UIButton *) sender{
    if (sender.titleLabel.text.length < 1) {
        return;
    }
    /// 取相反状态
    self.viewState = self.viewState == PhotoAlbumState_Editing ? PhotoAlbumState_Default : PhotoAlbumState_Editing;
    
    /// NOTE:动态改变按钮的宽度
    NSString *content = sender.titleLabel.text;
    UIFont *font = sender.titleLabel.font;
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    CGSize buttonSize = [content boundingRectWithSize:size
                                              options:options
                                           attributes:@{ NSFontAttributeName:font}
                                              context:nil].size;
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    });
}
#pragma mark - segment点击相应
- (void)segmentValueChanged:(UISegmentedControl *)seg{
    NSUInteger segIndex = [seg selectedSegmentIndex];
    if (segIndex == 0) {        // 视频
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.selectType = PhotoAlbumType_Video;
        self.viewState = (self.videoMutArr.count>0)?PhotoAlbumState_Default:PhotoAlbumState_Empty;
    }else{          //  图片
        [self.scrollView setContentOffset:CGPointMake(GOS_SCREEN_W, 0) animated:YES];
        self.selectType = PhotoAlbumType_Photo;
        self.viewState = (self.photoMutArr.count>0)?PhotoAlbumState_Default:PhotoAlbumState_Empty;
    }
}

#pragma mark - getters and setters
- (void)setViewState:(PhotoAlbumState)viewState {
    _viewState = viewState;
    self.editToolBar.hidden = viewState != PhotoAlbumState_Editing;
    
    // 设置右上角按钮
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        switch (viewState) {
            case PhotoAlbumState_Empty:{
                [strongSelf.rightBtn setTitle:@"" forState:UIControlStateNormal];
            }break;
            case PhotoAlbumState_Default:{
                [strongSelf.rightBtn setTitle:DPLocalizedString(@"GosComm_Edit") forState:UIControlStateNormal];
            }break;
            case PhotoAlbumState_Editing:{
                [strongSelf.rightBtn setTitle:DPLocalizedString(@"GosComm_Cancel") forState:UIControlStateNormal];
            }break;
            default:
                break;
        }
    });
    // 为cell状态设置editing，selected
    [PhotoAlbumViewModel modifyEditWithDataArray:self.selectType==PhotoAlbumType_Video?self.videoMutArr:self.photoMutArr
                                         editing:self.viewState == PhotoAlbumState_Editing
                                        selected:NO];
    self.editToolBar.checkAllButton.selected = NO;
    [self refreshTableView];
}
#pragma mark - actionFunction
#pragma mark - 全选点击
- (void)checkAllButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    // 设置cellModel selected状态
    [PhotoAlbumViewModel modifySelectStateWithDataArray:self.selectType==PhotoAlbumType_Video?self.videoMutArr:self.photoMutArr selectd:sender.selected];
    [self refreshTableView];
    [self refreshToolBar];
}
/// 删除按钮响应
- (void)deleteButtonDidClick:(UIButton *)sender {
    if(![PhotoAlbumViewModel checkIsExistDeletableWithDataArray:PhotoAlbumType_Video==self.selectType?self.videoMutArr:self.photoMutArr]){
        // 没有可删除的项，不执行操作
        return ;
    }
    /// 删除操作提醒
    __weak typeof(self) weakself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:DPLocalizedString(@"Mine_Tip") message:DPLocalizedString(@"photo_DeletePhotoTips") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakself coverWillChangeValueForKey];
        // 删除数据
        [PhotoAlbumViewModel deleteDataWithArray:PhotoAlbumType_Photo == self.selectType?self.photoMutArr:self.videoMutArr];
        // 先默认为存在数据状态
        weakself.viewState = PhotoAlbumState_Default;
        [weakself coverDidChangeValueForKey];
        [weakself refreshTableView];
        [weakself refreshToolBar];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}
#pragma mark - 覆盖系统 will&didChangeValue
- (void) coverWillChangeValueForKey{
    [self willChangeValueForKey:@"photoMutArr"];
    [self willChangeValueForKey:@"videoMutArr"];
}
- (void) coverDidChangeValueForKey{
    [self didChangeValueForKey:@"photoMutArr"];
    [self didChangeValueForKey:@"videoMutArr"];
}
#pragma mark - 主线程刷新Tableview
- (void) refreshTableView{
    GOS_WEAK_SELF;
    if (PhotoAlbumType_Video == self.selectType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.VideoTableView reloadData];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.PhotoTableView reloadData];
        });
    }
}
- (void) refreshToolBar{
    GOS_WEAK_SELF;
    if (self.selectType == PhotoAlbumType_Photo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            GOS_STRONG_SELF;
            strongSelf.editToolBar.checkAllButton.selected = [PhotoAlbumViewModel checkIsAllBeingSelectedWithDataArray:strongSelf.photoMutArr];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            strongSelf.editToolBar.checkAllButton.selected = [PhotoAlbumViewModel checkIsAllBeingSelectedWithDataArray:strongSelf.videoMutArr];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.editToolBar.deleteButton setTitleColor:GOS_COLOR_RGB(0x1A1A1A) forState:UIControlStateNormal];
        strongSelf.editToolBar.deleteButton.enabled = NO;
    });
    /// 如有选中，删除变红
    if ([PhotoAlbumViewModel checkIsExistDeletableWithDataArray:PhotoAlbumType_Video==self.selectType?self.videoMutArr:self.photoMutArr]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GOS_STRONG_SELF;
            [strongSelf.editToolBar.deleteButton setTitleColor:GOS_COLOR_RGB(0xFF2424) forState:UIControlStateNormal];
            strongSelf.editToolBar.deleteButton.enabled = YES;
        });
    }
}
#pragma mark - 播放本地视频
- (void)playRecordVideoWithPath:(NSString*)filePath{
    if (!filePath || 0 >= filePath){
        return;
    }
    MPMoviePlayerViewController * mediaVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
    [self presentViewController:mediaVC animated:YES completion:^{}];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:mediaVC.moviePlayer];
}
- (void)movieFinishedCallback:(NSNotification*)notify{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    MPMoviePlayerController* theMovie = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    [theMovie.view removeFromSuperview];
}

#pragma mark - tableView&delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ///  非编辑状态
    if ([tableView isEqual:self.PhotoTableView] && PhotoAlbumState_Default == self.viewState) {
        SettingPhotoVC * vc = [[SettingPhotoVC alloc] init];
        PhotoAlbumModel * model = [self.photoMutArr objectAtIndex:indexPath.row];
        vc.dataModel = model;
        vc.photoMutArr = self.photoMutArr;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tableView isEqual:self.VideoTableView] && PhotoAlbumState_Default == self.viewState){
        PhotoAlbumModel * model = [self.videoMutArr objectAtIndex:indexPath.row];
        [self playRecordVideoWithPath:model.filePath];
    }
    
    /// 编辑状态
    else if ([tableView isEqual:self.PhotoTableView] && PhotoAlbumState_Editing == self.viewState) {
        PhotoAlbumModel * model = [self.photoMutArr objectAtIndex:indexPath.row];
        model.selected =! model.selected;
        [self refreshToolBar];
    }else if([tableView isEqual:self.VideoTableView] && PhotoAlbumState_Editing == self.viewState){
        PhotoAlbumModel * model = [self.videoMutArr objectAtIndex:indexPath.row];
        model.selected =! model.selected;
        [self refreshToolBar];
    }
    [self refreshTableView];
    
}
#pragma mark - 侧滑删除方法
/// 1
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
/// 2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DPLocalizedString(@"GosComm_Delete");
}
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumModel * model = nil;
    if (PhotoAlbumType_Photo == self.selectType) {
        model = [self.photoMutArr objectAtIndex:indexPath.row];
    }else{
        model = [self.videoMutArr objectAtIndex:indexPath.row];
    }
    //在这里实现删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.viewState = PhotoAlbumState_Default;
        [self coverWillChangeValueForKey];
        [PhotoAlbumViewModel deleteDataWithModel:model tableDataArr:PhotoAlbumType_Photo == self.selectType?self.photoMutArr:self.videoMutArr];
        [self coverDidChangeValueForKey];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    //删除
    PhotoAlbumModel * model = nil;
    if (PhotoAlbumType_Photo == self.selectType) {
        model = [self.photoMutArr objectAtIndex:indexPath.row];
    }else{
        model = [self.videoMutArr objectAtIndex:indexPath.row];
    }
    GOS_WEAK_SELF;
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:DPLocalizedString(@"GosComm_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GOS_STRONG_SELF;
        strongSelf.viewState = PhotoAlbumState_Default;
        [strongSelf coverWillChangeValueForKey];
        [PhotoAlbumViewModel deleteDataWithModel:model tableDataArr:PhotoAlbumType_Photo == strongSelf.selectType?strongSelf.photoMutArr:strongSelf.videoMutArr];
        [strongSelf coverDidChangeValueForKey];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    return @[deleteRowAction];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.PhotoTableView]) {
        return [SettingPhotoAlbumCell cellWithTableView:tableView cellModel:[self.photoMutArr objectAtIndex:indexPath.row]];
    }else{
        return [SettingPhotoAlbumCell cellWithTableView:tableView cellModel:[self.videoMutArr objectAtIndex:indexPath.row]];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.PhotoTableView]) {
        return self.photoMutArr.count;
    }
    return self.videoMutArr.count;
}
#pragma mark - emptyDataDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:self.selectType==PhotoAlbumType_Video?@"img_blankpage_video":@"img_blankpage_photo"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString * title = DPLocalizedString(@"no_pic");
    if (self.selectType == PhotoAlbumType_Video) {
        title = DPLocalizedString(@"no_Video");
    }
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:GOS_COLOR_RGBA(198, 198, 198, 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

#pragma mark -- lifestyle
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"videoMutArr"];
    [self removeObserver:self forKeyPath:@"photoMutArr"];
    GosLog(@"----  %s ----", __PRETTY_FUNCTION__);
}
#pragma mark -- lazy
- (UISegmentedControl *)segControl{
    if (!_segControl) {
        NSArray * titleArr = @[DPLocalizedString(@"Video"),DPLocalizedString(@"pic")];
        _segControl = [[UISegmentedControl alloc] initWithItems:titleArr];
        _segControl.frame = CGRectMake(0, 0, 140, 30);
        _segControl.layer.cornerRadius = 15.0f;
        _segControl.clipsToBounds = YES;
        _segControl.backgroundColor =GOS_COLOR_RGBA(104, 165, 251, 1);
        _segControl.layer.borderWidth = 1.0;
        _segControl.layer.borderColor = [UIColor whiteColor].CGColor;
        _segControl.tintColor = [UIColor whiteColor];
        _segControl.selectedSegmentIndex = 0;
        [_segControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.contentSize = CGSizeMake(GOS_SCREEN_W * 2, GOS_SCREEN_H);
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
        _scrollView.delegate = self;
        [_scrollView addSubview:self.VideoTableView];
        [_scrollView addSubview:self.PhotoTableView];
    }
    return _scrollView;
}
- (UITableView *)VideoTableView{
    if (!_VideoTableView) {
        _VideoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, GOS_SCREEN_W, GOS_SCREEN_H -64)];
        _VideoTableView.delegate             = self;
        _VideoTableView.dataSource           = self;
        _VideoTableView.emptyDataSetSource   = self;
        _VideoTableView.emptyDataSetDelegate = self;
        _VideoTableView.backgroundColor      = GOS_COLOR_RGB(0xF7F7F7);
        _VideoTableView.tableFooterView      = [UIView new];
        _VideoTableView.rowHeight            = 65.0f;
        _VideoTableView.bounces              = NO;
    }
    return _VideoTableView;
}
- (UITableView *)PhotoTableView{
    if (!_PhotoTableView) {
        _PhotoTableView = [[UITableView alloc] initWithFrame:CGRectMake(GOS_SCREEN_W, 0, GOS_SCREEN_W, GOS_SCREEN_H -64)];
        _PhotoTableView.delegate = self;
        _PhotoTableView.dataSource = self;
        _PhotoTableView.emptyDataSetSource = self;
        _PhotoTableView.emptyDataSetDelegate = self;
        _PhotoTableView.backgroundColor = GOS_COLOR_RGB(0xF7F7F7);
        _PhotoTableView.tableFooterView = [UIView new];
        _PhotoTableView.rowHeight = 65.0f;
        _PhotoTableView.bounces = NO;
    }
    return _PhotoTableView;
}

- (MessageCenterToolBar *)editToolBar {
    if (!_editToolBar) {
        _editToolBar = [[MessageCenterToolBar alloc] initWithFrame:CGRectZero];
        [_editToolBar.deleteButton addTarget:self
                                      action:@selector(deleteButtonDidClick:)
                            forControlEvents:UIControlEventTouchUpInside];
        [_editToolBar.deleteButton setTitleColor:GOS_COLOR_RGB(0x1A1A1A) forState:UIControlStateNormal];
        _editToolBar.deleteButton.enabled = NO;
        [_editToolBar.checkAllButton addTarget:self
                                        action:@selector(checkAllButtonDidClick:)
                              forControlEvents:UIControlEventTouchUpInside];
    }
    return _editToolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
