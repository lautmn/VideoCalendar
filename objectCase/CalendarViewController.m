//
//  ViewController.m
//  JumpCalendar
//
//  Created by JUMP on 2016/4/13.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import "CalendarViewController.h"
#import "DayDetailViewController.h"
#import "DaySingletonManager.h"
#import "OneDayData.h"

@interface CalendarViewController () <JTCalendarDelegate>
{
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_dateSelected;
    
    DaySingletonManager *daySingleton;
    OneDayData *oneDayData;
}

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    daySingleton = [DaySingletonManager sharedData];
    [self showDayData];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    _calendarManager.settings.pageViewHaveWeekDaysView = NO;
    _calendarManager.settings.pageViewNumberOfWeeks = 0; // Automatic
    
    _weekDayView.manager = _calendarManager;
    [_weekDayView reload];
   
    
    // Generate random events sort by date using a dateformatter for the demonstration
//    [self createRandomEvents];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:[NSDate date]];
    
    _calendarMenuView.scrollView.scrollEnabled = false; // Scroll not supported with JTVerticalCalendarView
    
    //初始label顯示日期
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"dd";
    self.bigDateLable.text = [formatter stringFromDate:[NSDate date]];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.smallDateLable.text = [formatter stringFromDate:[NSDate date]];
    formatter.dateFormat = @"EEEE";
    self.smallWeekLable.text = [formatter stringFromDate:[NSDate date]];
    
    
//    開啟label作用，增加手勢
    _imgTitleLable.userInteractionEnabled = true;
    _imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClicked:)];
    UITapGestureRecognizer *imgTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClicked:)];
    [_imgTitleLable addGestureRecognizer:tapGesture];
    [_imageView addGestureRecognizer:imgTapGesture];
    
    
    //    邊寬與圓角
    _borderImageView.layer.borderWidth = 2;
    _imgTitleLable.layer.cornerRadius = 3;
    _borderImageView.layer.cornerRadius = 3;
    _imageView.layer.cornerRadius = 3;
    
    
    
}

- (void) labelClicked:(id) sender {
    
    [self performSegueWithIdentifier:@"detailSegue" sender:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    [self showDayData];
    
//    讓dotView不會慢一拍更新
    [_calendarManager reload];
}

- (IBAction)returnBtn:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{

    dayView.hidden = NO;
    [dayView.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    
    // Hide if from another month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = true;
    }
//     Today
    else if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.circleView.alpha = 0.7;
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.circleView.alpha = 0.7;
        
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    
//    if([self haveEventForDay:dayView.date]){
//        dayView.dotView.hidden = NO;
//    }
//    else{
//        dayView.dotView.hidden = YES;
//    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd";
//
    
    if([daySingleton getOneDayDataWithKey:[formatter stringFromDate:dayView.date]]){
        dayView.dotView.hidden = false;
    }
    else{
        dayView.dotView.hidden = true;
    }
    
    
}

-(void) calendar:(JTCalendarManager *)calendar
{
    [calendar reload];
}


- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    //轉換時區，並把點選到的日期show在label
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"dd";
    self.bigDateLable.text = [formatter stringFromDate:_dateSelected];
    
    formatter.dateFormat = @"yyyy-MM-dd";
    self.smallDateLable.text = [formatter stringFromDate:_dateSelected];
    
    formatter.dateFormat = @"EEEE";
    self.smallWeekLable.text = [formatter stringFromDate:_dateSelected];
    
    
    
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    [self showDayData];
    
}




#pragma mark - ShowDayData

-(void) showDayData{
    
//    load day data plist
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [docPath stringByAppendingPathComponent:@"dayData.plist"];
    
    NSMutableDictionary *allDayDatas = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    
    
   
//    oneDayData = daySingleton.allDayDatas[_smallDateLable.text];
    
     //    將plist讀取出來的資料，給當天這個物件
    oneDayData = allDayDatas[_smallDateLable.text];
    
//    第一次使用app，plist的allDayDatas是nil，如果不打if這行，會造成singleton nil
    if (allDayDatas != nil) {
        daySingleton.allDayDatas = allDayDatas;
    }
    
    //沒資料的話隱藏標籤，否則顯示出來
    if (oneDayData == nil) {
        _imgTitleLable.hidden = true;
        _imageView.hidden = true;
        _insertBtn.hidden = false;
        _borderImageView.hidden = true;
        
        return;
    }else{
        _imgTitleLable.hidden = false;
        _imageView.hidden = false;
        _insertBtn.hidden = true;
        _borderImageView.hidden = false;
    }
    
    
//    標籤內容自動換行
    _imgTitleLable.lineBreakMode = NSLineBreakByWordWrapping;
    
    _imgTitleLable.text = oneDayData.imgTitle;
    
//    doc資料夾位置會變，所以不能用存在plist裡的URL
//    _imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:oneDayData.imageURL]];
//    NSLog(@"imageURL: %@",oneDayData.imageURL);
    
    NSString *path = [docPath stringByAppendingPathComponent:[_smallDateLable.text stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    NSString *photoPath = [NSString stringWithFormat:@"%@.jpeg",path];
    
    NSLog(@"%@",photoPath);
    
    _imageView.image = [UIImage imageWithContentsOfFile:photoPath];
    
    
    
}

#pragma mark - Fake data

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
        NSLog(@"%@",_eventsByDate[key]);
    }
}

- (IBAction)insertBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"detailSegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        DayDetailViewController *DetailVC = segue.destinationViewController;
        DetailVC.bigDateStr = _bigDateLable.text;
        DetailVC.smallDateStr = _smallDateLable.text;
        DetailVC.smallWeekStr = _smallWeekLable.text;
        DetailVC.oneDayData = oneDayData;
        DetailVC.image = _imageView.image;
        
    }
    
    
}



@end



















