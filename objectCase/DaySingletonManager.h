//
//  DaySingletonManager.h
//  JumpCalendar
//
//  Created by JUMP on 2016/4/21.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneDayData.h"

@interface DaySingletonManager : NSObject


@property (nonatomic, strong)NSMutableDictionary *allDayDatas;


+(instancetype) sharedData;

-(void) setObject:()oneDaydata forKey:()aKey;

-(OneDayData*)getOneDayDataWithKey:()aKey;

-(void) deleteDayData:()key;

//-(id)initWithCoder:(NSCoder*) coder;
//
//-(void) encodeWithCoder:(NSCoder*) coder;

@end
