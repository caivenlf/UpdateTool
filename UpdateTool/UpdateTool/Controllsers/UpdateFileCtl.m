//
//  UpdateFileCtl.m
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "UpdateFileCtl.h"
#import "OTAUpdateSys.h"

@interface UpdateFileCtl ()

@end

@implementation UpdateFileCtl

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (IBAction)testOtaFileUpdate:(id)sender {
    
    [[OTAUpdateSys shareInstance] updateSystem:@"ble_app_ancs_test"];
}

- (IBAction)watchOtaUpdate:(id)sender {
    
    [[OTAUpdateSys shareInstance] updateSystem:@"ble_app_ancs"];
}
@end
