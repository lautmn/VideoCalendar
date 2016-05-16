//
//  DaySingletonManager.m
//  JumpCalendar
//
//  Created by JUMP on 2016/4/21.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import "DaySingletonManager.h"

NSString *const KADUserAllDatas = @"allDayDatas";

@implementation DaySingletonManager



static DaySingletonManager *_DaySingletonManager;



+(instancetype) sharedData{
    
    if (_DaySingletonManager == nil) {
        _DaySingletonManager = [DaySingletonManager new];
        _DaySingletonManager.allDayDatas = [NSMutableDictionary new];
    }
    
    return _DaySingletonManager;
    
}

-(void) setObject:()oneDaydata forKey:(nonnull id<NSCopying>)aKey{
    
    [_DaySingletonManager.allDayDatas setObject:oneDaydata forKey:aKey];
    
}

-(OneDayData*)getOneDayDataWithKey:(nonnull id<NSCopying>)key{
    
    return [_DaySingletonManager.allDayDatas objectForKey:key];
    
}

-(void) deleteDayData:()key {
    
    [_DaySingletonManager.allDayDatas removeObjectForKey:key];
    
}






@end











