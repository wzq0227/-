//  MessageCenterViewController.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterViewController.h"
#import "MessageCenterCellModel.h"
#import "MessageCenterTableViewCell.h"
#import "MessageCenterToolBar.h"
#import "MessageCenterViewModel.h"

typedef NS_ENUM(NSInteger, MessageCenterViewState) {
    MessageCenterViewStateEmptyMessage, // 无消息状态
    MessageCenterViewStateExistMessage, // 有消息状态
    MessageCenterViewStateEditing,      // 编辑状态
};

@interface MessageCenterViewController () <UITableViewDelegate, UITableViewDataSource>

/// 空页面的占位图
@property (weak, nonatomic) IBOutlet UIImageView *emptyImageView;
/// 空页面的标签
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
/// tableView
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
/// table数据
@property (nonatomic, strong) NSMutableArray *tableDataArray;
/// 编辑工具
@property (nonatomic, strong) MessageCenterToolBar *editToolBar;
/// viewModel
@property (nonatomic, strong) MessageCenterViewModel *messageViewModel;
/// 页面状态
@property (nonatomic, assign) __block MessageCenterViewState viewState;

/// 设备ID
@property (nonatomic, copy) NSString *deviceId;
/**云存储服务是否在有效期内*/
@property(nonatomic,assign) BOOL csValid;
/** 请求CS状态失败 重新请求 */
@property(nonatomic,assign) BOOL requestCSStatusSuccesfully;

@end

@implementation MessageCenterViewController
#pragma mark - initialization
- (instancetype)initWithDeviceID:(nullable NSString *)deviceId {
    if (self = [super init]) {
        _deviceId = deviceId;
    }
    return self;
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DPLocalizedString(@"Mine_MessageCenter");
    
    // 配置默认显示数据
    [self configDefault];
    
}


- (void)configDefault {
    // 默认设置页面为空消息状态
    self.viewState = MessageCenterViewStateEmptyMessage;
    
    // 空视图的显示
    self.emptyLabel.text = DPLocalizedString(@"Mine_NoMessage");
    // 配置底部编辑视图
    [self.view addSubview:self.editToolBar];
    [self.editToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin);
        make.height.mas_equalTo(40);
    }];
    
    // 右上角设置为空的
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(editBarButtonDidClick:)];
    
    // tableview section height
    self.messageTableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.messageTableView.sectionFooterHeight = 10.0;
    
    // 观察tableDataArray
    [self addObserver:self forKeyPath:@"tableDataArray" options:NSKeyValueObservingOptionNew context:nil];
    
    // 更新数据
    [self updateDataArrayFromDataBase];
    
    // FIXME: 确定接收新消息的通知名
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasNewMessageReceived:) name:@"接收到新推送消息时" object:nil];
}
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"tableDataArray"];
}
#pragma mark - observer method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tableDataArray"]) {
        /// 非编辑状态下检查是否存在有效数据，从而改变页面状态
        if (self.viewState != MessageCenterViewStateEditing) {
            self.viewState = [self.messageViewModel checkIsValidDataExistedWithDataArray:self.tableDataArray] ? MessageCenterViewStateExistMessage : MessageCenterViewStateEmptyMessage;
        }
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableDataArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MessageCenterTableViewCell cellWithTableView:tableView model:self.tableDataArray[indexPath.section][indexPath.row]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MessageCenterTableViewCell cellHeightWithModel:self.tableDataArray[indexPath.section][indexPath.row]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCenterCellModel *model = self.tableDataArray[indexPath.section][indexPath.row];
    
    if (!model.isEditable) {
        // 不可编辑项
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // 响应点击事件
        if (model.cellClickActionBlock) {
            id obj = model.cellClickActionBlock(nil);
            if ([obj isKindOfClass:[UIViewController class]]) {
                [self.navigationController pushViewController:obj animated:YES];
            }
        }
    } else if (model.isEditable && model.isEditing) {
        // 可编辑项并正在编辑
        model.selected = !model.isSelected;
        
        // 判断是否所有的已经被选择了
        self.editToolBar.checkAllButton.selected = [self.messageViewModel checkIsAllBeingSelectedWithDataArray:self.tableDataArray];
        
    } else if (model.isEditable && !model.isEditing) {
        // TODO: 可编辑项并未编辑ing
        
    }
    [tableView reloadData];
}

#pragma mark - events response
/// 删除按钮响应
- (void)deleteButtonDidClick:(id)sender {
    if (![self.messageViewModel checkIsExistDeletableWithDataArray:self.tableDataArray]) {
        // 没有可删除的项，不执行操作
        return ;
    }
    
    // 删除操作提醒
    __weak typeof(self) weakself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:DPLocalizedString(@"Mine_Tip") message:DPLocalizedString(@"Mine_DeleteMessageTips") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakself willChangeValueForKey:@"tableDataArray"];;
        // 删除数据
        [weakself.messageViewModel deleteWithDataArray:weakself.tableDataArray deviceID:weakself.deviceId];
        // 先默认为存在数据状态
        weakself.viewState = MessageCenterViewStateExistMessage;
        [weakself didChangeValueForKey:@"tableDataArray"];
        [weakself.messageTableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DPLocalizedString(@"GosComm_Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
/// 全选/取消全选按钮响应
- (void)checkAllButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    // 设置cellModel selected状态
    [self.messageViewModel modifyWithDataArray:self.tableDataArray selected:sender.isSelected];
    [self.messageTableView reloadData];
}
/// 编辑/取消按钮响应
- (void)editBarButtonDidClick:(id)sender {
    // 取相反状态
    self.viewState = self.viewState == MessageCenterViewStateEditing ? MessageCenterViewStateExistMessage : MessageCenterViewStateEditing;
}
/// 接收到新消息推送
- (void)hasNewMessageReceived:(NSNotification *)sender {
    // 编辑状态下不显示新消息
    if (self.viewState == MessageCenterViewStateEditing) {
        GosLog(@"正在执行删除操作，新推送消息不展示！");
        return ;
    }
    [self willChangeValueForKey:@"tableDataArray"];
    // FIXME: 如果新的通知未直接添加到数据库中，就新写个方法，不过最好不要~
    [self.messageViewModel updateFromDataBaseWithDataArray:self.tableDataArray deviceID:self.deviceId];
    [self didChangeValueForKey:@"tableDataArray"];
    //直接重新刷新
    [self.messageTableView reloadData];
}

#pragma mark - private method
- (void)updateDataArrayFromDataBase {
    [self willChangeValueForKey:@"tableDataArray"];
    // 从数据库更新数组
    [self.messageViewModel updateFromDataBaseWithDataArray:self.tableDataArray deviceID:self.deviceId];
    [self didChangeValueForKey:@"tableDataArray"];
}

#pragma mark - getters and setters
- (void)setViewState:(MessageCenterViewState)viewState {
    _viewState = viewState;
    
    self.emptyImageView.hidden = viewState != MessageCenterViewStateEmptyMessage;
    self.emptyLabel.hidden = viewState != MessageCenterViewStateEmptyMessage;
    
    self.editToolBar.hidden = viewState != MessageCenterViewStateEditing;
    
    // 设置右上角按钮
    switch (viewState) {
        case MessageCenterViewStateEmptyMessage:
            [self.navigationItem.rightBarButtonItem setTitle:nil];
            break;
        case MessageCenterViewStateExistMessage:
            [self.navigationItem.rightBarButtonItem setTitle:DPLocalizedString(@"GosComm_Edit")];
            break;
        case MessageCenterViewStateEditing:
            [self.navigationItem.rightBarButtonItem setTitle:DPLocalizedString(@"GosComm_Cancel")];
            break;
        default:
            break;
    }
    
    // 为cell状态设置editing， selected
    [self.messageViewModel modifyWithDataArray:self.tableDataArray editing:viewState == MessageCenterViewStateEditing selected:NO];
    
    [self.messageTableView reloadData];
}
- (NSMutableArray *)tableDataArray {
    if (!_tableDataArray) {
        // 由viewModel生产默认数组
        _tableDataArray = [[self.messageViewModel generateDefaultTableDataArray] mutableCopy];
    }
    return _tableDataArray;
}
- (MessageCenterViewModel *)messageViewModel {
    if (!_messageViewModel) {
        _messageViewModel = [[MessageCenterViewModel alloc] init];
    }
    return _messageViewModel;
}
- (MessageCenterToolBar *)editToolBar {
    if (!_editToolBar) {
        _editToolBar = [[MessageCenterToolBar alloc] initWithFrame:CGRectZero];
        [_editToolBar.deleteButton addTarget:self action:@selector(deleteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editToolBar.checkAllButton addTarget:self action:@selector(checkAllButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editToolBar;
}


@end
