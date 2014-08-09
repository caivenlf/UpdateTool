//
//  UpdateFileCtl.h
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateFileCtl : UITableViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

- (IBAction)testOtaFileUpdate:(id)sender;

- (IBAction)watchOtaUpdate:(id)sender;

@end
