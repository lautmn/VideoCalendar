//
//  VideoMakerViewController.m
//  FinalProject
//
//  Created by lautmn on 2016/4/7.
//  Copyright © 2016年 lautmn. All rights reserved.
//

#import "VideoMakerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SelectImageCollectionViewController.h"
#import "WaitForMakeVideoViewController.h"

// Frames per Photo
#define FRAMES 60
// Sec per Photo
#define SEC_PER_PHOTO 3.0
// FPS = FRAMES / SEC_PER_PHOTO

@interface VideoMakerViewController () {
    NSMutableArray *imageArr;
    NSString *theVideoPath;
    NSTimer *previewTimer;
    int photoCount;
    int photoFrame;
    UIImageView *videoPreview;
    int effectType;
    int musicType;
    //    NSMutableArray *imageWithEffects;
    UIScrollView *effectSelect;
    UIScrollView *musicSelect;
    AVAudioPlayer *musicPlayer;
    UIButton *replayBtn;
}


@end

@implementation VideoMakerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self music1];
    photoCount = 0;
    photoFrame = 0;
    effectType = 1;
    musicType = 1;
    imageArr = [[NSMutableArray alloc] init];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width;
    
    videoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth)];
    videoPreview.contentMode = UIViewContentModeScaleAspectFit;
    videoPreview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:videoPreview];
    
    
    // Resize all photo to 640*640, and add into imageArr
    
    //開背景執行緒
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //派工到背景執行緒上
    dispatch_async(aQueue, ^{
        for (NSURL *url in _imageArray) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            UIImage *resizeImage = [self resizeFromImage:image];
            NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1);
            NSLog(@"%ld",imageData.length);
            [imageArr addObject:resizeImage];
        }
        //切回主執行緒
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
        });
    });

    UIView *musicOrEffect = [[UIView alloc] initWithFrame:CGRectMake(0, screenWidth, screenWidth, 60)];
    musicOrEffect.backgroundColor = [UIColor blackColor];
    [self.view addSubview:musicOrEffect];
    
    UIButton *musicMode = [UIButton buttonWithType:UIButtonTypeCustom];
    musicMode.backgroundColor = [UIColor blackColor];
    [musicMode addTarget:self action:@selector(musicMode) forControlEvents:UIControlEventTouchUpInside];
    [musicMode setImage:[UIImage imageNamed:@"music.png"] forState:UIControlStateNormal];
    musicMode.frame = CGRectMake(0, 0, screenWidth/2, 60);
    [musicOrEffect addSubview:musicMode];
    
    UIButton *effectMode = [UIButton buttonWithType:UIButtonTypeCustom];
    effectMode.backgroundColor = [UIColor blackColor];
    [effectMode addTarget:self action:@selector(effectMode) forControlEvents:UIControlEventTouchUpInside];
    [effectMode setImage:[UIImage imageNamed:@"effect.png"] forState:UIControlStateNormal];
    effectMode.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 60);
    [musicOrEffect addSubview:effectMode];
    
    replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replayBtn.backgroundColor = [UIColor blackColor];
    [replayBtn addTarget:self action:@selector(replayBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [replayBtn setImage:[UIImage imageNamed:@"effect.png"] forState:UIControlStateNormal];
    replayBtn.frame = CGRectMake(0, 0, screenWidth/2, 60);
    [self.view addSubview:replayBtn];
    replayBtn.hidden = true;
    
    musicSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,60+screenWidth,screenWidth,120)];
    musicSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    musicSelect.showsVerticalScrollIndicator=YES;
    musicSelect.scrollEnabled=YES;
    musicSelect.userInteractionEnabled=YES;
    [self.view addSubview:musicSelect];
    musicSelect.contentSize = CGSizeMake(960,120);
    musicSelect.hidden = true;
    
    UIButton *music1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    music1.backgroundColor = [UIColor redColor];
    [music1 addTarget:self action:@selector(music1) forControlEvents:UIControlEventTouchUpInside];
    [music1 setTitle:@"Music1" forState:UIControlStateNormal];
    music1.frame = CGRectMake(5.0, 5.0, 110.0, 110.0);
    [musicSelect addSubview:music1];
    
    UIButton *music2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    music2.backgroundColor = [UIColor blueColor];
    [music2 addTarget:self action:@selector(music2) forControlEvents:UIControlEventTouchUpInside];
    [music2 setTitle:@"Music2" forState:UIControlStateNormal];
    music2.frame = CGRectMake(120.0, 5.0, 110.0, 110.0);
    [musicSelect addSubview:music2];
    
    effectSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,60+screenWidth,screenWidth,120)];
    effectSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    effectSelect.showsVerticalScrollIndicator=YES;
    effectSelect.scrollEnabled=YES;
    effectSelect.userInteractionEnabled=YES;
    [self.view addSubview:effectSelect];
    effectSelect.contentSize = CGSizeMake(960,120);
    
    UIButton *effect1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect1.backgroundColor = [UIColor blueColor];
    [effect1 addTarget:self  action:@selector(effect1) forControlEvents:UIControlEventTouchUpInside];
    [effect1 setTitle:@"Effect1" forState:UIControlStateNormal];
    effect1.frame = CGRectMake(5.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect1];
    
    UIButton *effect2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect2.backgroundColor = [UIColor yellowColor];
    [effect2 addTarget:self  action:@selector(effect2) forControlEvents:UIControlEventTouchUpInside];
    [effect2 setTitle:@"Effect2" forState:UIControlStateNormal];
    effect2.frame = CGRectMake(120.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect2];
    
    UIButton *effect3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect3.backgroundColor = [UIColor greenColor];
    [effect3 addTarget:self  action:@selector(effect3) forControlEvents:UIControlEventTouchUpInside];
    [effect3 setTitle:@"Effect3" forState:UIControlStateNormal];
    effect3.frame = CGRectMake(235.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect3];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    [self music1];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:true];
    [previewTimer invalidate];
    previewTimer = nil;
}

- (UIImage *)resizeFromImage:(UIImage *)sourceImage {
    
    // Check sourceImage's size
    CGFloat maxValue = 640.0;
    CGSize originalSize = sourceImage.size;
    if (originalSize.width <= maxValue && originalSize.height <= maxValue) {
        return sourceImage;
    }
    // Decide final size
    
    CGSize targetSize;
    if (originalSize.width >= originalSize.height) {
        CGFloat ratio = originalSize.width/maxValue;
        targetSize = CGSizeMake(maxValue, originalSize.height/ratio);
    } else { // height > width
        CGFloat ratio = originalSize.width/originalSize.height;
        targetSize = CGSizeMake(maxValue *ratio, maxValue);
    }
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    resultImage = [self setBlackBackground:resultImage];
    
    return resultImage;
}

- (UIImage *)setBlackBackground:(UIImage *)sourceImage {
    UIImage *background = [UIImage imageNamed:@"blackBackground.jpg"];
    CGSize backgroundSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(backgroundSize);
    [background drawInRect:CGRectMake(0, 0, 640, 640)];
    [sourceImage drawInRect:CGRectMake(320-sourceImage.size.width/2, 0, sourceImage.size.width, sourceImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scaledImage = [self setBlackBackground:scaledImage];
    
    return scaledImage;
}


- (void)showVideoPreView {
//    NSLog(@"updating");
    
    switch (effectType) {
        case 1:
        {
            if (photoCount < imageArr.count) {
                if (photoFrame<FRAMES) {
                    float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                    videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.0+0.1*(frameToFloat/FRAMES)];
                } else {
                    photoFrame = 0;
                    photoCount++;
                }
                photoFrame++;
            } else {
                NSLog(@"photo:%i , imageArr:%lu",photoCount,(unsigned long)imageArr.count);
                photoFrame = 0;
                photoCount = 0;
                [musicPlayer pause];
                musicPlayer.currentTime = 0.0;
//                [musicPlayer play];
                [previewTimer invalidate];
                replayBtn.hidden = false;
            }
            break;
        }
            
        case 2:
        {
            if (photoCount < imageArr.count) {
                if (photoFrame<FRAMES){
                    float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                    videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.1-0.1*(frameToFloat/FRAMES)];
                } else {
                    photoFrame = 0;
                    photoCount++;
                }
                photoFrame++;
            } else {
                photoFrame = 0;
                photoCount = 0;
                [musicPlayer pause];
                musicPlayer.currentTime = 0.0;
//                [musicPlayer play];
                [previewTimer invalidate];
                replayBtn.hidden = false;
            }
            break;
        }
            
        case 3:
        {
            if (photoCount < imageArr.count) {
                if (photoCount%2==0) {
                    if (photoFrame<FRAMES){
                        float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                        videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.0+0.1*(frameToFloat/FRAMES)];
                    } else {
                        photoFrame = 0;
                        photoCount++;
                    }
                    photoFrame++;
                } else {
                    if (photoFrame<FRAMES){
                        float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                        videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.1-0.1*(frameToFloat/FRAMES)];
                    } else {
                        photoFrame = 0;
                        photoCount++;
                    }
                    photoFrame++;
                }
            } else {
                photoFrame = 0;
                photoCount = 0;
                [musicPlayer pause];
                musicPlayer.currentTime = 0.0;
//                [musicPlayer play];
                [previewTimer invalidate];
                replayBtn.hidden = false;
            }
            break;
        }
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)saveBtnPressed:(id)sender {
    [musicPlayer stop];
    WaitForMakeVideoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WaitForMakeVideoViewController"];
    vc.effectType = [NSNumber numberWithInt:effectType];
    vc.musicType = [NSNumber numberWithInt:musicType];
    vc.imageArr = imageArr;
//    vc.imageArr = _imageArray;
    [self showViewController:vc sender:nil];
}

- (void)effect1 {
    effectType = 1;
    photoCount = 0;
    photoFrame = 0;
    [musicPlayer pause];
    musicPlayer.currentTime = 0.0;
    [musicPlayer play];
    replayBtn.hidden = true;
    if (!previewTimer.valid) {
        previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    }
}

- (void)effect2 {
    effectType = 2;
    photoCount = 0;
    photoFrame = 0;
    [musicPlayer pause];
    musicPlayer.currentTime = 0.0;
    [musicPlayer play];
    replayBtn.hidden = true;
    if (!previewTimer.valid) {
        previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    }
}

- (void)effect3 {
    effectType = 3;
    photoCount = 0;
    photoFrame = 0;
    [musicPlayer pause];
    musicPlayer.currentTime = 0.0;
    [musicPlayer play];
    replayBtn.hidden = true;
    if (!previewTimer.valid) {
        previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    }
}

- (void)musicMode {
    effectSelect.hidden = true;
    musicSelect.hidden = false;
}

- (void)effectMode {
    effectSelect.hidden = false;
    musicSelect.hidden = true;
}

- (void)music1 {
    musicType = 1;
    replayBtn.hidden = true;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Animals.mp3" withExtension:nil];
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    musicPlayer.numberOfLoops = 0;
    [musicPlayer prepareToPlay];
    [musicPlayer play];
    photoFrame = 0;
    photoCount = 0;
    if (!previewTimer.valid) {
        previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    }
}

- (void)music2 {
    musicType = 2;
    replayBtn.hidden = true;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Maps.mp3" withExtension:nil];
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    musicPlayer.numberOfLoops = 0;
    [musicPlayer prepareToPlay];
    [musicPlayer play];
    photoFrame = 0;
    photoCount = 0;
    if (!previewTimer.valid) {
        previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    }
}

- (void)replayBtnPressed {
    NSLog(@"Pressed");
    previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    [musicPlayer play];
    replayBtn.hidden = true;
}

@end



