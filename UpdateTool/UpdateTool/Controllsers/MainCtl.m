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
    
    dataSourceArray = [[ArrayDataSource alloc] initWithItems:@[@"蓝牙连接",@"2",@"3",@"4",@"5"] cellIdentifier:@"MainCell" configureCellBlock:^(id cell, id item) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSourceArray tableView:self.tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dataSourceArray tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"BleConnectIden" sender:nil];
    }
}


@end
