//
//  AppDelegate.m
//  objectCase
//
//  Created by  劉哲霖 on 2016/4/5.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "itemViewController.h"
@interface AppDelegate ()
{
    
    UIBackgroundTaskIdentifier bgTask;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings * settings= [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:settings];
    
    DBSession * session = [[DBSession alloc]initWithAppKey:@"aqf7x7bmxpj6wty" appSecret:@"hue5fkfolovx394" root:kDBRootAppFolder];
    session.delegate = self;
    [DBSession setSharedSession:session];
    
    
    return YES;
}

-(void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    NSLog(@"認證錯誤");
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBSession sharedSession]handleOpenURL:url]) {
        if ([[DBSession sharedSession]isLinked]) {
            NSLog(@"SUCCESS");
        }
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    _alertDate=[[NSDate date] dateByAddingTimeInterval:60*60*24*7];
    NSLog(@"%@",_alertDate);
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
<<<<<<< HEAD

=======
    UILocalNotification* notifyAlarm2 = [[UILocalNotification alloc] init];
    notifyAlarm2.fireDate=[[NSDate date] dateByAddingTimeInterval:10];
    notifyAlarm2.alertBody=@"請打開App,讓上傳作業繼續進行";
    notifyAlarm2.timeZone=[NSTimeZone defaultTimeZone];
    
>>>>>>> 38907258389ae2e752c32d0b86938f610722b179
    notifyAlarm.fireDate = _alertDate;
    notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
    notifyAlarm.repeatInterval = 0;
    notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
    notifyAlarm.alertBody = [NSString stringWithFormat: @"已經有7天以上沒有開啟影音日記了！趕快來紀錄您的生活點滴吧！"];
    notifyAlarm.applicationIconBadgeNumber=1;
    [app scheduleLocalNotification:notifyAlarm];
    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
      
    
    if ([appupload boolForKey:@"appupload"] == true) {
        [app scheduleLocalNotification:notifyAlarm2];
    }
    
    
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}


- (void)addNewSchedult:(NSDate *)date {
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
    
    notifyAlarm.fireDate = date;
    notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
    notifyAlarm.repeatInterval = 0;
    notifyAlarm.soundName = @"";
    notifyAlarm.alertBody = [NSString stringWithFormat: @"上傳完成"];
    notifyAlarm.applicationIconBadgeNumber=1;
    [app scheduleLocalNotification:notifyAlarm];
    
    
}

#pragma mark - 判斷前景or背景
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([AppDelegate runningInForeground]) {
        return;
    }
}
//背景
+(BOOL)runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}
//前景
+(BOOL)runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateActive);
    
    return result;
}
-(void)endBackgroundTask{
    UIApplication * application = [UIApplication sharedApplication];
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

@end
