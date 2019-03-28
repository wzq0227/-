//
//  SettingPhotoAlbumCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAlbumModel.h"
@interface SettingPhotoAlbumCell : UITableViewCell
/// cellModel
@property (nonatomic, strong) PhotoAlbumModel * cellModel;

+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(PhotoAlbumModel *) cellModel;
@end
