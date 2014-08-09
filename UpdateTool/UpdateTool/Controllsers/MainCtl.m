//
//  MainCtl.m
//  UpdateTool
//
//  Created by Vincent on 14-8-7.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "MainCtl.h"
#import "MainCell.h"
#import "ArrayDataSource.h"
@interface MainCtl (){

    id dataSourceArray;
}

@end

@implementation MainCtl

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
    
    dataSourceArray = [[ArrayDataSource alloc] initWithItems:@[@"蓝牙连接",@"打印信息",@"固件升级"] cellIdentifier:@"MainCell" configureCellBlock:^(id cell, id item) {
        [(MainCell*)cell titleLabel].text = item;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSourceArray tableView:self.tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dataSourceArray tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *ctlIden = @[@"BleConnectIden",@"MonitoringReportIden",@"UpdateFileIden"];
    [self performSegueWithIdentifier:[ctlIden objectAtIndex:indexPath.row] sender:nil];
}


@end
