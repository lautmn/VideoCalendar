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
@interface itemViewController ()<MFMailComposeViewControllerDelegate>
{   BOOL cancelDB;
    int count;
}
@property(nonatomic,strong)NSMutableArray * pathArray;
@property(nonatomic,strong)UIProgressView * pv;
@property(nonatomic,strong)UILabel * myLabel;
@end

@implementation itemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getFileUrl];
    count = 0;
    cancelDB = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendMailtoTeamBtnPressed:(id)sender
{
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    
    [composeVC setToRecipients:@[@"h1205542@gmail.com"]];
    [composeVC setSubject:@"Hello!"];
    [composeVC setMessageBody:@"Hello VideoClander Team" isHTML:NO];
    
    
    [self presentViewController:composeVC animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




-(NSURL *)getFileUrl{
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@",path);
    
    
    
    NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    self.pathArray = [[NSMutableArray alloc]init];
    
    for (NSString*url in paths) {
        if ([url hasSuffix:@".mp4"]) {
            NSString * dirStr = [path stringByAppendingString:@"/"];
            NSString * mp4Path = [dirStr stringByAppendingString:url];
            NSLog(@"mp4path :    %@",mp4Path);
            [self.pathArray addObject:mp4Path];
            
        }
    }
    
    return 0;
}
- (IBAction)backToDropBoxBtnPressed:(id)sender {
    if (![[DBSession sharedSession]isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
    }
    [self totalUpload];
    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
    [appupload setBool:true forKey:@"appupload"];
    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"正在上傳" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[self restClient] cancelFileUpload:[self.pathArray objectAtIndex:count]];
        [[self restClient] cancelAllRequests];
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:false forKey:@"appupload"];
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
-(void)totalUpload{
    NSString *fileName=[NSString stringWithFormat:@"%@.mp4",[[NSDate date] description]];
    
    NSString *targetPath=@"/";
    [[self restClient] uploadFile:fileName
                           toPath:targetPath
                    withParentRev:nil
                         fromPath:[self.pathArray objectAtIndex:count]];
    
    
}
#pragma mark - Upload DropBox
//連線DropBox
-(DBRestClient *)restClient{
    if(!restClient){
        restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
//上傳成功
-(void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath

             from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    NSLog(@"File uploaded successfully: %@", metadata.path);
    
    
    
    if (count+1 == self.pathArray.count) {
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
        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
        [appupload setBool:false forKey:@"appupload"];
    }else{
        count = count +1;
        self.myLabel.text = [NSString stringWithFormat:@"%i/%li",count+1,self.pathArray.count];
        [self totalUpload];
    }
}

//失敗
-(void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    
    NSLog(@"File upload failed - %@", error);
    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳失敗" message:@"請再試一次"preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:understand];
    
    
    [self presentViewController:alertcontroller animated:YES completion:nil];
    
    
}
-(void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    self.pv.progress = progress;
}
@end
