//
//  DetailViewController.h
//  JumpCalendar
//
//  Created by JUMP on 2016/4/18.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarViewController.h"
#import "OneDayData.h"

@interface DayDetailViewController : UIViewController

@property OneDayData *oneDayData;

@property (weak, nonatomic) IBOutlet UILabel *bigDateLable;
@property (weak, nonatomic) IBOutlet UILabel *smallDateLable;
@property (weak, nonatomic) IBOutlet UILabel *smallWeekLable;
@property (weak, nonatomic) IBOutlet UIButton *insertImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *imgTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *dayDetailTextView;

@property NSString *bigDateStr;
@property NSString *smallDateStr;
@property NSString *smallWeekStr;
@property (nonatomic,strong) UIImage *image;


@end
