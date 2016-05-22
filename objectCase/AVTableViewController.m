//
//  AVTableViewController.m
//  objectCase
//
//  Created by  AndyLiou on 2016/4/21.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "AVTableViewController.h"
#import "AVtableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import <AVKit/AVKit.h>

@interface AVTableViewController ()



@property(nonatomic,strong)NSMutableArray * AVurlArray;      //完整URL路徑
@property(nonatomic,strong)NSMutableArray * pathArray;       //path路徑
@property(nonatomic,strong)NSMutableArray * fileNameArray;   //檔案名稱

@end

@implementation AVTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self getFileUrl];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableView) name:@"updataTableView" object:nil];
    
}
-(NSURL *)getFileUrl{
    //取得URL
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@",path);
    
    
    
    //所有檔案名稱存到array
    NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    self.AVurlArray = [[NSMutableArray alloc] init];
    self.pathArray = [[NSMutableArray alloc]init];
    self.fileNameArray = [[NSMutableArray alloc]init];
    // 找出document mp4檔存在array
    for (NSString*url in paths) {
        if ([url hasSuffix:@".mp4"]) {
            
            NSString * dirStr = [path stringByAppendingString:@"/"];
            NSString * mp4Path = [dirStr stringByAppendingString:url];
            NSString * fileUrl = [@"file://" stringByAppendingString:mp4Path];
            NSLog(@"mp4path :    %@",mp4Path);
            NSLog(@"fuleURl:    %@",fileUrl);
            [self.pathArray addObject:mp4Path];
            [self.AVurlArray addObject:fileUrl];
            [self.fileNameArray addObject:url];
            
            
        }
        NSLog(@"avurl %@", self.AVurlArray);
    }
    
    return 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



#pragma mark - Table view data source
//Cell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.AVurlArray.count;
}
//Cell view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AVtableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    NSURL * url = [NSURL URLWithString:[self.AVurlArray objectAtIndex:indexPath.row]];
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator * generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    
    
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(40, 10) actualTime:nil error:nil];
    UIImage * image = [UIImage imageWithCGImage:cgImage];
    
    cell.imageLabel.text = [self.fileNameArray objectAtIndex:indexPath.row];
    NSLog(@"imagelabel   %@",[self.fileNameArray objectAtIndex:indexPath.row]);
    
    cell.AVImageView.image=image;
    
    
    
    return cell;
    
}



//Detailviewcontroller View
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //準備下一頁
    DetailViewController * detailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.detailArray = self.AVurlArray;         //與detailarray串接所有影片路徑
    detailVC.test = self.AVurlArray[indexPath.row]; //對應的URL
    detailVC.path = self.pathArray[indexPath.row];  //對應的Path
    detailVC.pathName = self.fileNameArray[indexPath.row];  //對應的檔名
  
    [self.navigationController pushViewController:detailVC animated:YES];
    
    
}


// reload tableview
-(void)updateTableView
{
    [self.tableView reloadData];
}
//移除聽口號
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updataTableView" object:nil];
}

@end
