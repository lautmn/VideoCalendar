//
//  AppDelegate.h
//  objectCase
//
//  Created by  劉哲霖 on 2016/4/5.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,DBSessionDelegate>{
  
}

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)NSDate * alertDate;

@end

