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
@property(nonatomic,strong)NSMutableArray * detailArray;   //串接用URLarray
@property(nonatomic,strong)NSMutableArray * fileNameArray; //串接用檔名array
@property(nonatomic,strong)NSMutableArray * pathArray;     //串接用path array
@property(nonatomic,strong)NSString * test;    //URL
@property(nonatomic,strong)NSString * path;    //path路徑
@property(nonatomic,strong)NSString * pathName;  //檔名
-(DBRestClient *)restClient;
@end
