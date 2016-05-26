//
//  DetailViewController.m
//  objectCase
//
//  Created by  AndyLiou on 2016/4/24.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "DetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AVTableViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()
{
    AVPlayerLayer * playerLayer;           //播放影片的layer
    
}
@property (nonatomic,strong) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UISlider *AVSlider;          //進度條
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;  //播放暫停鈕
@property(nonatomic,strong)UIProgressView * pv;                   //上傳進度條
@property(nonatomic,strong)NSMutableArray * allFolder; //dropbox上所有檔案



@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playImageView.hidden = true;
    //Slider圖片改成透明
    [self.AVSlider setThumbImage:[UIImage imageNamed:@"uncolorslider.png"] forState:UIControlStateNormal];
}

-(void)dealloc{
    //remove聆聽
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setupUI];
    [self.player play];
    [self addNotification];
    
}
//離開頁面後
-(void)viewWillDisappear:(BOOL)animated
{
    //離開頁面砍掉layer且暫停
    if (_player != nil) {
        _player.rate = 0.0;
        [playerLayer removeFromSuperlayer];
        _player = nil;
        playerLayer = nil;
    }
    //重整tableview
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updataTableView" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 私有方法
-(void)setupUI{
    //播放器Layer
    playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=self.AVMovieImage.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.needsDisplayOnBoundsChange = YES;
    [self.AVMovieImage.layer addSublayer:playerLayer];
}
//Player加入播放資訊
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}
//獲取要播放的路徑
-(AVPlayerItem *)getPlayItem{
    
    NSURL *url=[NSURL URLWithString:self.test];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

#pragma mark - 通知
//播放器通知
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//播放完通知
-(void)playbackFinished:(NSNotification *)notification{
    
    _AVSlider.value = 0;
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player pause];
    self.playImageView.hidden = false;
    
    
}

#pragma mark - 監控
//監控播放進度
-(void)addProgressObserver{
    
    AVPlayerItem *playerItem=self.player.currentItem;
    
    UISlider * slider = self.AVSlider;
    //每1/20秒執行一次   可用 id timeObsever = 去接 在removeTimeObserve
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 20) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        
        if (current) {
            [slider setValue:(current/total) animated:YES];
        }
    }];
    
}

//Slider
- (IBAction)AVSliderBt:(id)sender {
    if (self.player.rate==0)  //暫停狀態
    {
        AVPlayerItem *playerItem=_player.currentItem;
        CGFloat current = self.AVSlider.value;
        float total = CMTimeGetSeconds([playerItem duration]);
        [_player seekToTime:CMTimeMake(current*total, 1) toleranceBefore:CMTimeMake(1, 100) toleranceAfter:CMTimeMake(1, 100)];
    }else{                        //播放中的無狀態
        [_player pause];
        AVPlayerItem *playerItem=_player.currentItem;
        //從這裡開始播放
        CGFloat current = self.AVSlider.value;
        //獲取總時長
        float total = CMTimeGetSeconds([playerItem duration]);
        //獲取進度 and刻度
        [_player seekToTime:CMTimeMake(current*total, 1) toleranceBefore:CMTimeMake(1, 100) toleranceAfter:CMTimeMake(1, 100)];
        //播放
        [_player play];
    }
}


#pragma mark - 監控

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //監控加載
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if (self.player.rate==1) {
        self.playImageView.hidden = true;
    }else{
        self.playImageView.hidden = false;
    }
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正播放:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//緩衝範圍
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//緩衝長度
        NSLog(@"共緩衝：%.2f",totalBuffer);
        
    }
}

#pragma mark - play or pause
- (IBAction)touchImageView:(id)sender {
    
    if(self.player.rate==0)             //如果是暫停 就播放
    {
        [self.player play];
        self.playImageView.hidden = true;
    }else if(self.player.rate==1)       //正在播放 就暫停
    {
        [self.player pause];
        self.playImageView.hidden = false;
    }
}



#pragma mark - Delete movie
- (IBAction)deleteBtnPressed:(id)sender {
    [self.player pause];
    //取得plist檔案路徑
    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"確認要刪除影片？" message:@""preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * determine = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //停止影片
        if (_player != nil) {
            _player.rate = 0.0;
            [playerLayer removeFromSuperlayer];
            _player = nil;
            playerLayer = nil;
        }
        //刪除陣列中路徑
        [self.detailArray removeObject:self.test];
        [self.pathArray removeObject:self.path];
        [self.fileNameArray removeObject:self.pathName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL * url = [NSURL URLWithString:self.test];
        [fileManager removeItemAtURL:url error:nil];
        
        
        //跳轉 回 tableview
        AVTableViewController * tableVC =[self.storyboard instantiateViewControllerWithIdentifier:@"AVTableViewController"];
        [self.navigationController pushViewController:tableVC animated:YES];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_player play];
    }];
    //將按鈕加到提示視窗
     [alertcontroller addAction:cancel];
    [alertcontroller addAction:determine];
   
    
    
    [self presentViewController:alertcontroller animated:YES completion:nil];
}


#pragma mark - 存入手機
- (IBAction)saveToPhoneBtnPressed:(id)sender {
    NSURL * movieURL = [NSURL URLWithString:self.test];
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"儲存失敗" message:@""preferredStyle:UIAlertControllerStyleAlert];
            //準備按鈕
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            //將按鈕加到提示視窗
            [alertcontroller addAction:understand];
            
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
            
            
        }else{
            UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"儲存完畢" message:@""preferredStyle:UIAlertControllerStyleAlert];
            //準備按鈕
            UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            //將按鈕加到提示視窗
            [alertcontroller addAction:understand];
            
            
            [self presentViewController:alertcontroller animated:YES completion:nil];
            
        }
        
    }];
    
   
}




#pragma mark - 上傳DropBox
//連線DropBox
-(DBRestClient *)restClient{
    if(!restClient){
        restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
     [self.player pause];
        self.playImageView.hidden = false;
    self.allFolder = [[NSMutableArray alloc]init];
    if (metadata.isDirectory)
    {
      
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents)
        {
            [self.allFolder addObject:file.filename];
            
        }
      
        //如有相同檔名
            if ([self.allFolder indexOfObject:self.pathName]!=NSNotFound) {

                UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"已有相同檔案在您的DropBox中" message:@"確定要覆蓋嗎？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*understand=[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [[self restClient]deletePath:self.pathName];
                    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
                    [appupload setBool:true forKey:@"appupload"];
                    
                    
                    
                    NSString *targetPath=@"/";
                    
                    [[self restClient] uploadFile:self.pathName
                                           toPath:targetPath
                                    withParentRev:nil
                                         fromPath:self.path];
                    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳中" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //取消通知動作
                        [appupload setBool:false forKey:@"appupload"];
                        [self cancelNotification];
                        //取消上傳動作
                        [[self restClient] cancelFileUpload:self.path];
                        [[self restClient] cancelAllRequests];
                        
                    }];
                    [alertcontroller addAction:understand];
                    
                    
                    [self presentViewController:alertcontroller animated:YES completion:^{
                        
                        self.pv = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
                        self.pv.frame = CGRectMake(0,60 , 270, 30);
                        
                        self.pv.progress = 0;
            
                        self.pv.tintColor = [UIColor greenColor];
                        
                        
                        
                        
                        [alertcontroller.view addSubview:self.pv];
                    }];

                    
                }];
                    
               
                UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                [alertcontroller addAction:cancel];

                [alertcontroller addAction:understand];
                
                [self presentViewController:alertcontroller animated:YES completion:nil];
            
            }else{
                {
                    
                        NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
                        [appupload setBool:true forKey:@"appupload"];
                        
                        
                        
                        NSString *targetPath=@"/";
                        
                        [[self restClient] uploadFile:self.pathName
                                               toPath:targetPath
                                        withParentRev:nil
                                             fromPath:self.path];
                        UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳中" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction*understand=[UIAlertAction actionWithTitle:@"取消上傳" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            //取消通知動作
                            [appupload setBool:false forKey:@"appupload"];
                            [self cancelNotification];
                            //取消上傳動作
                            [[self restClient] cancelFileUpload:self.path];
                            [[self restClient] cancelAllRequests];
                            
                        }];
                        [alertcontroller addAction:understand];
                        
                        
                        [self presentViewController:alertcontroller animated:YES completion:^{
                            
                            self.pv = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
                            self.pv.frame = CGRectMake(0,60 , 270, 30);
                            
                            self.pv.progress = 0;
                            
                            self.pv.tintColor = [UIColor greenColor];
                            
                            
                            
                            
                            [alertcontroller.view addSubview:self.pv];
                        }];
                        
                        
                
                    
                }
            }
            
    }

}
- (IBAction)uploadButton:(id)sender {
    [self.player pause];
    self.playImageView.hidden = false;
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
                  
                 [[self restClient]loadMetadata:@"/"];
                    
                }
            });
        });

        
        
    }
    if ([[DBSession sharedSession]isLinked]) {
        
     [[self restClient]loadMetadata:@"/"];
   
    
    }
}


//上傳成功
-(void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath

             from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    //如果在背景跳通知
    //先取消背景上傳超時提醒
    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
    [appupload setBool:false forKey:@"appupload"];
    [self cancelNotification];
    UILocalNotification * ln = [UILocalNotification new];
    ln.soundName = UILocalNotificationDefaultSoundName;
    ln.alertBody = @"影片已上傳成功";
    ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    [[UIApplication sharedApplication] presentLocalNotificationNow:ln];

    NSLog(@"File uploaded successfully: %@", metadata.path);
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertController * alertcontroller=[UIAlertController alertControllerWithTitle:@"上傳成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction*understand=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertcontroller addAction:understand];
        [self presentViewController:alertcontroller animated:YES completion:nil];
}

//失敗
-(void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    //如果在背景跳通知
    //先取消背景上傳超時提醒
    NSUserDefaults*appupload=[NSUserDefaults standardUserDefaults];
    [appupload setBool:false forKey:@"appupload"];
    [self cancelNotification];
    UILocalNotification * ln = [UILocalNotification new];
    ln.soundName = UILocalNotificationDefaultSoundName;
    ln.alertBody = @"上傳失敗請取消OR選擇重新上傳";
    ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
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



@end
