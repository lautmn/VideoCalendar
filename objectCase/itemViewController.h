//
//  itemViewController.h
//  objectCase
//
//  Created by  AndyLiou on 2016/5/17.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
@interface itemViewController : UIViewController<DBRestClientDelegate>
{
    DBRestClient * restClient;
}
-(DBRestClient *)restClient;

@end
