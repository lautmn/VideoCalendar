//
//  OneDayData.h
//  JumpCalendar
//
//  Created by JUMP on 2016/4/23.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OneDayData : NSObject

@property NSString *imgTitle;
@property NSString *dayDetail;
@property NSURL *imageURL;

-(id)initWithCoder:(NSCoder*) coder;

-(void) encodeWithCoder:(NSCoder*) coder;

@end
