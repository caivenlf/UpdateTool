//
//  PrintCtl.h
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintCtl : UITableViewController<BleMessageCenterOut>


@property (weak, nonatomic) IBOutlet UITextView *receiveDataTextView;


@end
