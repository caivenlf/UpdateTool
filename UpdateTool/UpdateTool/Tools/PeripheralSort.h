//
//  PeripheralSort.h
//  YFWatch_LF
//
//  Created by Vincent on 14-4-29.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralSort : NSObject

@property (nonatomic,strong) NSMutableArray *getArray;
@property (nonatomic,strong) NSMutableArray *sortArray;

+ (id)sharedInstance;

-(id)getPeripheralArray:(NSMutableArray*)array;

@end
