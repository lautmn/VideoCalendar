//
//  OneDayData.m
//  JumpCalendar
//
//  Created by JUMP on 2016/4/23.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import "OneDayData.h"


NSString *const KAImgTitle = @"imgTitle";
NSString *const KADayDetail = @"dayDetail";
NSString *const KAImageURL = @"imageURL";

@implementation OneDayData


//解封
-(id)initWithCoder:(NSCoder*) coder {
    
    self = [super init];
    
    if (self) {
        _imgTitle = [coder decodeObjectForKey:KAImgTitle];
        _dayDetail = [coder decodeObjectForKey:KADayDetail];
        _imageURL = [coder decodeObjectForKey:KAImageURL];
    }
    
    
    return self;
}

//封裝
-(void) encodeWithCoder:(NSCoder*) coder {
    
    if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
        [coder encodeObject:_imgTitle forKey:KAImgTitle];
        [coder encodeObject:_dayDetail forKey:KADayDetail];
        [coder encodeObject:_imageURL forKey:KAImageURL];
        
    }else{
        [NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
    }
}


@end
