//
//  PeripheralSort.m
//  YFWatch_LF
//
//  Created by Vincent on 14-4-29.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "PeripheralSort.h"

@implementation PeripheralSort
@synthesize sortArray,getArray;

+ (id) sharedInstance
{
	static PeripheralSort *this	= nil;
	
	if (!this)
		
		this = [[PeripheralSort alloc] init];
	
	return this;
}

-(id)init{
    
    self = [super init];
    if(self){
        
        sortArray = [[NSMutableArray alloc] init];
        getArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)getPeripheralArray:(NSMutableArray*)array{
    
    [getArray removeAllObjects];
    [getArray addObjectsFromArray:array];
    
    for (int i=0; i<[getArray count]; i++) {
        
        for (int j=i+1; j<[getArray count]; j++) {
            
            int a = fabs([[[getArray objectAtIndex:i] objectForKey:PeripheralRssiKey] intValue]);
            int b = fabs([[[getArray objectAtIndex:j] objectForKey:PeripheralRssiKey] intValue]);
            id aPeripheral = [getArray objectAtIndex:i];
            id bPeripheral = [getArray objectAtIndex:j];
            
            if (a>b) {
                
                [getArray replaceObjectAtIndex:i withObject:bPeripheral];
                [getArray replaceObjectAtIndex:j withObject:aPeripheral];
            }
        }
    }
    
    return getArray;
}
@end
