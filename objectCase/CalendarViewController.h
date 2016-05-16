//
//  ViewController.h
//  JumpCalendar
//
//  Created by JUMP on 2016/4/13.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTCalendar/JTCalendar.h>

@interface CalendarViewController : UIViewController

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarWeekDayView *weekDayView;
@property (weak, nonatomic) IBOutlet JTVerticalCalendarView *calendarContentView;
@property (weak, nonatomic) IBOutlet UILabel *bigDateLable;
@property (weak, nonatomic) IBOutlet UILabel *smallDateLable;
@property (weak, nonatomic) IBOutlet UILabel *smallWeekLable;
@property (weak, nonatomic) IBOutlet UILabel *imgTitleLable;
@property (weak, nonatomic) IBOutlet UIButton *insertBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *borderImageView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@end

