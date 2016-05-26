//
//  itemViewController.m
//  objectCase
//
//  Created by  AndyLiou on 2016/5/17.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "itemViewController.h"
#import <MessageUI/MessageUI.h>
#import <DropboxSDK/DropboxSDK.h>
#import <StoreKit/StoreKit.h>
@interface itemViewController ()<MFMailComposeViewControllerDelegate,SKStoreProductViewControllerDelegate>
{
    int count;
    BOOL downloadOrload;
}
@property(nonatomic,strong)NSMutableArray * pathArray;        //全部path的路徑
@property(nonatomic,strong)UIProgressView * pv;               //上傳進度條
@property(nonatomic,strong)UILabel * myLabel;                 //檔案的label
@property(nonatomic,strong)NSMutableArray * pathNameArray;    //上傳全部檔案名稱的array
@property(nonatomic,strong)NSString * loadtmpPath;            //tmp路徑
@property(nonatomic,strong)NSString * loadDocumentPath;       // document路徑
@property(nonatomic,strong)NSMutableArray * allFolder;       //DropBox app備份的所有檔案
@end

@implementation itemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
      [self getFileUrl];
    
      count = 0;    //記錄total檔案的計步器
    
}

//寄信給我們
- (IBAction)sendMailtoTeamBtnPressed:(id)sender
{
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    
    [composeVC setToRecipients:@[@"justtryit518@gmail.com",@"h1205542@gmail.com",@"s990647@ee.yzu.edu.tw"]];
    [composeVC setSubject:@"Hello! VideoClander Team"];
    [composeVC setMessageBody:@"Hello VideoClander Team :" isHTML:NO];
    
    
    [self presentViewController:composeVC animated:YES completion:nil];
}
//寄件result判斷
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:{
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"已存入草稿" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertcontroller addAction:understand];
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
            break;
            
        }
        case MFMailComposeResultSent:{
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"感謝您的來信！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertcontroller addAction:understand];
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
            break;
            
            }
        case MFMailComposeResultFailed:{
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"寄件失敗,請重新操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertcontroller addAction:understand];
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
            break;
            
        }
            
        default:
        {
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"寄件失敗,請重新操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertcontroller addAction:understand];
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
        }
            break;
    }

  
}

//獲取 path  fileName  Url 的方法
-(NSURL *)getFileUrl{
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@",path);
    _loadDocumentPath = [path stringByAppendingString:@"/"];
    _loadtmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@""];
    NSLog(@"tmppath :   %@",_loadtmpPath);
    NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
   
    self.pathArray = [[NSMutableArray alloc]init];
    self.pathNameArray = [[NSMutableArray alloc]init];
    for (NSString*url in paths) {
        
        NSString * dirStr = [path stringByAppendingString:@"/"];
        NSString * Path = [dirStr stringByAppendingString:url];
        NSLog(@"mp4path :    %@",Path);
        [self.pathNameArray addObject:url];
        [self.pathArray addObject:Path];
    }
    return 0;
}

#pragma mark - DropBox 部分
//連線DropBox
-(DBRestClient *)restClient{
    if(!restClient){
        restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

#pragma mark - 下載部分
- (IBAction)downloadToDropBoxBtnPressed:(id)sender {
    if (![[DBSession sharedSession]isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
    
            dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(aQueue, ^{
                
                while (![[DBSession sharedSession]isLinked]) {
                    [NSThread sleepForTimeInterval:1.0];
                }
                
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    if ([[DBSession sharedSession]isLinked]) {
                        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"將會覆蓋相同的檔案" message:@"還要繼續作業嗎？" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"確認下載" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            downloadOrload = true;
                            [[self restClient]loadMetadata:@"/"];
                            
                        }];
                        UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消下載" style:UIAlertActionStyleDefault handler:nil];
                        [alertcontroller addAction:cancel];
                        [alertcontroller addAction:understand];
                        
                        [self presentViewController:alertcontroller animated:YES completion:nil];
                        
                    }
                });
            });
            
        
        NSLog(@"TESTing");

    }
    if ([[DBSession sharedSession]isLinked]) {
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"將會覆蓋相同的檔案" message:@"還要繼續作業嗎？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"確認下載" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            downloadOrload = true;
            [[self restClient]loadMetadata:@"/"];
            
        }];
        UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消下載" style:UIAlertActionStyleDefault handler:nil];
        [alertcontroller addAction:cancel];
        [alertcontroller addAction:understand];
        
        [self presentViewController:alertcontroller animated:YES completion:nil];
       
    }
}
-(void)downloadToDropBox
{
    [[self restClient]loadFile:[@"/" stringByAppendingString:[self.allFolder objectAtIndex:count]] intoPath: [_loadtmpPath stringByAppendingPathComponent:[self.allFolder objectAtIndex:count]]];
}

//download Success
-(void)restClient:(DBRestClient *)restClient loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    
    
    [[NSFileManager defaultManager]copyItemAtPath:[_loadtmpPath stringByAppendingPathComponent:[self.allFolder objectAtIndex:count]] toPath:[self.loadDocumentPath stringByAppendingString:[self.allFolder objectAtIndex:count]] error:nil];
    
    
    if (count+1 == self.allFolder.count) {
        //取消通知
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:false forKey:@"appupload"];
        [self cancelNotification];
        //如果在背景跳通知
        UILocalNotification * ln = [UILocalNotification new];
        ln.soundName = UILocalNotificationDefaultSoundName;
        ln.alertBody = @"所有檔案下載成功";
        ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
        [self dismissViewControllerAnimated:YES completion:nil];
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"下載成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertcontroller addAction:understand];
        
        
        [self presentViewController:alertcontroller animated:YES completion:nil];
        count = 0;
        
    }else{
        count = count +1;
        self.myLabel.text = [NSString stringWithFormat:@"%i/%li",count+1,self.allFolder.count];
        [self downloadToDropBox];
    }
    
    NSLog(@"Success");

}
//load Error
-(void)restClient:(DBRestClient *)restClient loadFileFailedWithError:(NSError *)error
{
    NSLog(@"ERROR");
}
-(void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    self.pv.progress = progress;
}
#pragma mark - 取出Dropbox的filename
//取出檔名  做下載動作 及 下載alert
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
     self.allFolder = [[NSMutableArray alloc]init];
    if (metadata.isDirectory) {
        
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents)
        {
            [self.allFolder addObject:file.filename];
            
        }
        
    }
    NSLog(@"allfilename:     %@" , _allFolder);
    //如果是下載
    if (downloadOrload == true) {
        [self downloadToDropBox];
        
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:true forKey:@"appupload"];
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"正在下載" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"取消下載" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //(3分鐘未下載完通知取消)
            [appupload setBool:false forKey:@"appupload"];
            [self cancelNotification];
            //上傳連結
            [[self restClient] cancelFileLoad:[self.allFolder objectAtIndex:count]];
            [[self restClient] cancelAllRequests];
            
        }];
        
        [alertcontroller addAction:understand];
        
        [self presentViewController:alertcontroller animated:YES completion:^{
            
            self.pv = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
            self.pv.frame = CGRectMake(0,60 , 270, 30);
            
            self.pv.progress = 0;
            //self.pv.backgroundColor = [UIColor greenColor];
            
            self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 50, 50)];
            
            self.myLabel.text = [NSString stringWithFormat:@"%i/%li",count+1,self.allFolder.count];
            
            [alertcontroller.view addSubview:self.pv];
            [alertcontroller.view addSubview:self.myLabel];
        }];

    }
    
    //如果是上傳
    if (downloadOrload == false) {
        NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        //所有檔案名稱存到array
        NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString*url in paths) {
            if ([self.allFolder indexOfObject:url]!=NSNotFound) {
                [[self restClient]deletePath:url];
                
            }
            
        }
        [self totalUpload];
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:true forKey:@"appupload"];
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"正在上傳" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //(3分鐘未上傳完通知取消)
            [appupload setBool:false forKey:@"appupload"];
            [self cancelNotification];
            //上傳連結
            [[self restClient] cancelFileUpload:[self.pathArray objectAtIndex:count]];
            [[self restClient] cancelAllRequests];
            
        }];
        
        [alertcontroller addAction:understand];
        
        [self presentViewController:alertcontroller animated:YES completion:^{
            
            self.pv = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
            self.pv.frame = CGRectMake(0,60 , 270, 30);
            
            self.pv.progress = 0;
            //self.pv.backgroundColor = [UIColor greenColor];
            
            self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 50, 50)];
            
            self.myLabel.text = [NSString stringWithFormat:@"%i/%li",count+1,self.pathArray.count];
            
            [alertcontroller.view addSubview:self.pv];
            [alertcontroller.view addSubview:self.myLabel];
        }];

    }
     
}

#pragma mark - 上傳部分
- (IBAction)backToDropBoxBtnPressed:(id)sender {
    
    //沒登入給使用者登入
    if (![[DBSession sharedSession]isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
        
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^{
            
            while (![[DBSession sharedSession]isLinked]) {
                [NSThread sleepForTimeInterval:1.0];
            }
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                if ([[DBSession sharedSession]isLinked]) {
                    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"將會先刪除相同的檔案" message:@"還要繼續作業嗎？" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"確認上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        downloadOrload = false;
                        [[self restClient]loadMetadata:@"/"];
                        
                    }];
                    UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:nil];
                    [alertcontroller addAction:cancel];
                    [alertcontroller addAction:understand];
                    
                    [self presentViewController:alertcontroller animated:YES completion:nil];

                    
                }
            });
        });
        

    }
    
    //如果有登入才做
     if ([[DBSession sharedSession]isLinked])
    {
        
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"將會先刪除相同的檔案" message:@"還要繼續作業嗎？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"確認上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            downloadOrload = false;
            [[self restClient]loadMetadata:@"/"];
            
        }];
        UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:nil];
        [alertcontroller addAction:cancel];
        [alertcontroller addAction:understand];
        
        [self presentViewController:alertcontroller animated:YES completion:nil];
     
      
    }
}


//所有檔案上傳的方法
-(void)totalUpload{
  
    NSString *targetPath=@"/";
    [[self restClient] uploadFile:[self.pathNameArray objectAtIndex:count]
                           toPath:targetPath
                    withParentRev:nil
                         fromPath:[self.pathArray objectAtIndex:count]];
    
}



//上傳成功
-(void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath

             from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
  
    
    
    if (count+1 == self.pathArray.count) {
        NSLog(@"File uploaded successfully: %@", metadata.path);
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:false forKey:@"appupload"];
        [self cancelNotification];
        //如果在背景跳通知
        UILocalNotification * ln = [UILocalNotification new];
        ln.soundName = UILocalNotificationDefaultSoundName;
        ln.alertBody = @"所有影片上傳成功";
        ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
        [self dismissViewControllerAnimated:YES completion:nil];
        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertcontroller addAction:understand];
        
        
        [self presentViewController:alertcontroller animated:YES completion:nil];
        count = 0;
     
    }else{
        count = count +1;
        self.myLabel.text = [NSString stringWithFormat:@"%i/%li",count+1,self.pathArray.count];
        [self totalUpload];
    }
}

//失敗
-(void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    
    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
    [appupload setBool:false forKey:@"appupload"];
    [self cancelNotification];
    NSLog(@"File upload failed - %@", error);
    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳失敗" message:@"請再試一次"preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:understand];
    
    
    [self presentViewController:alertcontroller animated:YES completion:nil];
    
    
}
//獲取進度條
-(void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    self.pv.progress = progress;
}

//當上傳成功remove掉 3分鐘提醒
-(void)cancelNotification
{
    
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //拿全部的通知出來
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    for (UILocalNotification *notify in notificaitons) {
        if ([notify.userInfo objectForKey:@"unload"]) {
            //取消一个特定的通知
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
}
- (IBAction)giveStarBtnPressed:(id)sender {
    NSString *cAppleID = @"justtryit518@gmail.com";
    
    if ([SKStoreProductViewController class] != nil) {
        SKStoreProductViewController *skpvc = [[SKStoreProductViewController alloc] init];
        skpvc.delegate = self;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:cAppleID forKey: SKStoreProductParameterITunesItemIdentifier];
        [skpvc loadProductWithParameters:dict completionBlock:nil];
        [self.navigationController presentViewController:skpvc animated: YES completion: nil];
    }
//    else {
//        static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
//        static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
//        NSString *url = [[NSString alloc] initWithFormat: ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat, cAppleID];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated: YES completion: nil];
}@end
