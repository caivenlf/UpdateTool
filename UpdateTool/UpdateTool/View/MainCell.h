//
//  BleCell.h
//  UpdateTool
//
//  Created by Vincent on 14-8-7.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *bleNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
