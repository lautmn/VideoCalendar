//
//  DetailViewController.h
//  objectCase
//
//  Created by  AndyLiou on 2016/4/24.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DetailViewController : UIViewController<DBRestClientDelegate>
{
    DBRestClient * restClient;
}
@property (weak, nonatomic) IBOutlet UIImageView *AVMovieImage;
@property (weak, nonatomic) IBOutlet UIButton *backUpBtnpressed;
@property(nonatomic,strong)NSString * test;
@property(nonatomic,strong)NSMutableArray * detailArray;
@property(nonatomic,strong)NSString * path;
@property(nonatomic,strong)NSString * pathName;
-(DBRestClient *)restClient;
@end
