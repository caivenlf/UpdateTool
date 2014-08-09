//
//  Setting.h
//  UpdateTool
//
//  Created by Vincent on 14-8-8.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#ifndef UpdateTool_Setting_h
#define UpdateTool_Setting_h

    #define         OTAServiceType          @"OTASERVICE"
    #define         NormalServiceType       @"NORMALSERVICE"

    /**
     @para   NSUserDefault
     */
    #define kGetUserSystemObject(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

    #define kSaveUserSystemObject(key, value) \
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key]; \
    [[NSUserDefaults standardUserDefaults] synchronize]

#endif


#define PeripheralKey               @"ble"
#define PeripheralRssiKey           @"bleRssi"