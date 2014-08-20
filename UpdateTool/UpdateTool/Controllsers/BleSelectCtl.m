//
//  BleSelectCtl.m
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "BleSelectCtl.h"
#import "ArrayDataSource.h"
#import "PeripheralSort.h"

@interface BleSelectCtl (){
    
    id dataSourceArray;
    NSArray *sortArray;
    NSMutableArray *usableBle;
}

@end

@implementation BleSelectCtl

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[BluetoothMessageCenter sharedInstance] setBleTableDelegate:nil];
    [[BluetoothMessageCenter sharedInstance] stopScanning];
    [[[BluetoothMessageCenter sharedInstance] foundPeripherals] removeAllObjects];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self scanBle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addRefreshCtl];
    
    usableBle = [[NSMutableArray alloc] initWithCapacity:10];
    [[BluetoothMessageCenter sharedInstance] setBleTableDelegate:self];
}

- (void)addRefreshCtl{
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(scanBle) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)scanBle{
    [[BluetoothMessageCenter sharedInstance] scanningForDevice];
    [NSTimer scheduledTimerWithTimeInterval:10 target: self selector:@selector(stopScanning) userInfo:nil repeats:NO];
}

- (void)stopScanning{
    [[BluetoothMessageCenter sharedInstance] stopScanning];
    [self.refreshControl endRefreshing];
}

- (void)tableDataSource{
    
    [usableBle removeAllObjects];
    [usableBle addObjectsFromArray:[[BluetoothMessageCenter sharedInstance] foundPeripherals]];
    sortArray = [[PeripheralSort sharedInstance] getPeripheralArray:usableBle];
    dataSourceArray = [[ArrayDataSource alloc] initWithItems:sortArray cellIdentifier:@"BleCell" configureCellBlock:^(id cell, id item) {
        
        [(MainCell*)cell rssiLabel].text = [item objectForKey:PeripheralRssiKey];
        [(MainCell*)cell bleNameLabel].text =  [(CBPeripheral*)[item objectForKey:PeripheralKey] name];
    }];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [dataSourceArray tableView:self.tableView numberOfRowsInSection:0];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [dataSourceArray tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CBPeripheral	*peripheral;
    NSArray			*devices;
    NSInteger		row	= [indexPath row];
    
    devices = sortArray;
    peripheral = (CBPeripheral*)[[devices objectAtIndex:row] objectForKey:PeripheralKey];
    
    if (![peripheral state]) {
        [[BluetoothMessageCenter sharedInstance] connectPeripheral:peripheral];
    }
}



#pragma mark-
#pragma mark BLETABLEDelegate

-(void)scanningFinish{
    
}

-(void)scanningStart{
    
}

-(void)findPeripheral:(CBPeripheral*)peripheral{
    
    [self tableDataSource];
}
-(void)connectionBuild{

    [self tableDataSource];
}
-(void)connectionLost{
    
    [self tableDataSource];
}


@end
