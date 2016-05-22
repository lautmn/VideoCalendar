//
//  ViewController.m
//  objectCase
//
//  Created by  劉哲霖 on 2016/4/5.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "ViewController.h"
#import "DayDetailViewController.h"
#import "DaySingletonManager.h"

@interface ViewController ()
{
    DaySingletonManager *daySingleton;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    daySingleton = [DaySingletonManager sharedData];
    [self getDataPlist];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newDiaryBtnPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"newDiary" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"newDiary"]) {
        
        DayDetailViewController *DetailVC = segue.destinationViewController;

        //初始label顯示日期
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.timeZone = [NSTimeZone localTimeZone];
        
        formatter.dateFormat = @"dd";
        DetailVC.bigDateStr = [formatter stringFromDate:[NSDate date]];
        formatter.dateFormat = @"yyyy-MM-dd";
        DetailVC.smallDateStr = [formatter stringFromDate:[NSDate date]];
        formatter.dateFormat = @"EEEE";
        DetailVC.smallWeekStr = [formatter stringFromDate:[NSDate date]];
        
        
    }
}

-(void) getDataPlist {
    
    //    load day data plist
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [docPath stringByAppendingPathComponent:@"dayData.plist"];
    
    NSMutableDictionary *allDayDatas = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    if (allDayDatas != nil) {
        daySingleton.allDayDatas = allDayDatas;
    }

}




-(IBAction)exit:(UIStoryboardSegue*)sender{
}

@end











