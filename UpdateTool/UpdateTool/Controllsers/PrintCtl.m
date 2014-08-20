//
//  PrintCtl.m
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "PrintCtl.h"

@interface PrintCtl (){
    
    NSString *printInfoStr;
}

@end

@implementation PrintCtl

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    kSaveUserSystemObject(@"myKey", @"");
    [[BluetoothMessageCenter sharedInstance] setMessageDelegate:self];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[BluetoothMessageCenter sharedInstance] setMessageDelegate:nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - BLEDelegate
-(void)scanningStart{
	
	
}
-(void)scanningFinish{
	
    
}
-(void)findPeripheral:(CBPeripheral*)peripheral{
	
	
}
-(void)receiveData:(NSData*)data{
    
    NSString *string;
    string= [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",data);

    self.receiveDataTextView.text = [kGetUserSystemObject(@"myKey") stringByAppendingString:string];
    kSaveUserSystemObject(@"myKey", self.receiveDataTextView.text);
}
-(void)connectionBuild{
    
}
-(void)connectionLost{
    
	UIAlertView *aleart =[ [UIAlertView alloc] initWithTitle:@"Lost" message:@"connectionLost" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sure", nil];
	[aleart show];
}
-(void)connecting{
	
	
}
-(void)connectingFinish{
    
    
}

@end
