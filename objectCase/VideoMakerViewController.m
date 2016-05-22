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
#import "OneDayData.h"
#import "DaySingletonManager.h"

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
    OneDayData *oneDayData;
    DaySingletonManager *daySingleton;
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
    CGFloat screenHeight = screenSize.height;
    CGFloat screenLeftHeight = screenHeight-screenWidth-60;
    
    NSLog(@"HEIGHT : %f",screenHeight);
    
    videoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth)];
//    videoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-65)];
    videoPreview.contentMode = UIViewContentModeScaleAspectFit;
    videoPreview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:videoPreview];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Resize all photo to 640*640, and add into imageArr
    
    //開背景執行緒
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //派工到背景執行緒上
    dispatch_async(aQueue, ^{
//        for (NSURL *url in _imageArray) {
        for (NSString *url in _imageArray) {
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            UIImage *resizeImage = [self resizeFromImage:url];
            NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1);
            NSLog(@"%ld",imageData.length);
            [imageArr addObject:resizeImage];
        }
        //切回主執行緒
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });
    });

//    UIView *musicOrEffect = [[UIView alloc] initWithFrame:CGRectMake(0, screenWidth, screenWidth, 60)];
    UIView *musicOrEffect = [[UIView alloc] initWithFrame:CGRectMake(0, screenWidth, screenWidth, 0.35*screenLeftHeight)];
    musicOrEffect.backgroundColor = [UIColor blackColor];
    [self.view addSubview:musicOrEffect];
    
    UIButton *musicMode = [UIButton buttonWithType:UIButtonTypeCustom];
    musicMode.backgroundColor = [UIColor blackColor];
    [musicMode addTarget:self action:@selector(musicMode) forControlEvents:UIControlEventTouchUpInside];
    [musicMode setImage:[UIImage imageNamed:@"music.png"] forState:UIControlStateNormal];
//    musicMode.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 60);
    musicMode.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 0.35*screenLeftHeight);
    [musicOrEffect addSubview:musicMode];
    
    UIButton *effectMode = [UIButton buttonWithType:UIButtonTypeCustom];
    effectMode.backgroundColor = [UIColor blackColor];
    [effectMode addTarget:self action:@selector(effectMode) forControlEvents:UIControlEventTouchUpInside];
    [effectMode setImage:[UIImage imageNamed:@"effect.png"] forState:UIControlStateNormal];
//    effectMode.frame = CGRectMake(0, 0, screenWidth/2, 60);
    effectMode.frame = CGRectMake(0, 0, screenWidth/2, 0.35*screenLeftHeight);
    [musicOrEffect addSubview:effectMode];
    
    replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replayBtn.backgroundColor = [UIColor blackColor];
    [replayBtn addTarget:self action:@selector(replayBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [replayBtn setImage:[UIImage imageNamed:@"effect.png"] forState:UIControlStateNormal];
    replayBtn.frame = CGRectMake(0, 0, screenWidth/2, 60);
    [self.view addSubview:replayBtn];
    replayBtn.hidden = true;
    
//    musicSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,60+screenWidth,screenWidth,120)];
    musicSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,screenWidth+0.35*screenLeftHeight,screenWidth,0.65*screenLeftHeight)];
    musicSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    musicSelect.showsVerticalScrollIndicator=YES;
    musicSelect.scrollEnabled=YES;
    musicSelect.userInteractionEnabled=YES;
    [self.view addSubview:musicSelect];
    musicSelect.contentSize = CGSizeMake(580,0.65*screenLeftHeight);
    musicSelect.hidden = true;
    
    //======================================================================
    
    UIButton *music1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [music1 addTarget:self  action:@selector(music1) forControlEvents:UIControlEventTouchUpInside];
    [music1 setImage:[UIImage imageNamed:@"original.png"] forState:UIControlStateNormal];
    music1.frame = CGRectMake(5.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [musicSelect addSubview:music1];
    
    UIButton *music2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [music2 addTarget:self  action:@selector(music2) forControlEvents:UIControlEventTouchUpInside];
    [music2 setImage:[UIImage imageNamed:@"instant.png"] forState:UIControlStateNormal];
    music2.frame = CGRectMake(120.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [musicSelect addSubview:music2];
    
    UIButton *music3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [music3 addTarget:self  action:@selector(music3) forControlEvents:UIControlEventTouchUpInside];
    [music3 setImage:[UIImage imageNamed:@"process.png"] forState:UIControlStateNormal];
    music3.frame = CGRectMake(235.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [musicSelect addSubview:music3];
    
    UIButton *music4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [music4 addTarget:self  action:@selector(music4) forControlEvents:UIControlEventTouchUpInside];
    [music4 setImage:[UIImage imageNamed:@"linear.png"] forState:UIControlStateNormal];
    music4.frame = CGRectMake(350.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [musicSelect addSubview:music4];
    
    UIButton *music5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [music5 addTarget:self  action:@selector(music5) forControlEvents:UIControlEventTouchUpInside];
    [music5 setImage:[UIImage imageNamed:@"chrome.png"] forState:UIControlStateNormal];
    music5.frame = CGRectMake(465.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [musicSelect addSubview:music5];
    
    
    
    
    
//    effectSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,60+screenWidth,screenWidth,120)];
    effectSelect = [[UIScrollView alloc]initWithFrame:CGRectMake(0,screenWidth+0.35*screenLeftHeight,screenWidth,0.65*screenLeftHeight)];
    effectSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    effectSelect.showsVerticalScrollIndicator=YES;
    effectSelect.scrollEnabled=YES;
    effectSelect.userInteractionEnabled=YES;
    [self.view addSubview:effectSelect];
    effectSelect.contentSize = CGSizeMake(810,120);
    
    UIButton *effect1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect1 addTarget:self  action:@selector(effect1) forControlEvents:UIControlEventTouchUpInside];
    [effect1 setImage:[UIImage imageNamed:@"original.png"] forState:UIControlStateNormal];
    effect1.frame = CGRectMake(5.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect1];
    
    UIButton *effect2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect2 addTarget:self  action:@selector(effect2) forControlEvents:UIControlEventTouchUpInside];
    [effect2 setImage:[UIImage imageNamed:@"instant.png"] forState:UIControlStateNormal];
    effect2.frame = CGRectMake(120.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect2];
    
    UIButton *effect3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect3 addTarget:self  action:@selector(effect3) forControlEvents:UIControlEventTouchUpInside];
    [effect3 setImage:[UIImage imageNamed:@"process.png"] forState:UIControlStateNormal];
    effect3.frame = CGRectMake(235.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect3];
    
    UIButton *effect4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect4 addTarget:self  action:@selector(effect4) forControlEvents:UIControlEventTouchUpInside];
    [effect4 setImage:[UIImage imageNamed:@"linear.png"] forState:UIControlStateNormal];
    effect4.frame = CGRectMake(350.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect4];
    
    UIButton *effect5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect5 addTarget:self  action:@selector(effect5) forControlEvents:UIControlEventTouchUpInside];
    [effect5 setImage:[UIImage imageNamed:@"chrome.png"] forState:UIControlStateNormal];
    effect5.frame = CGRectMake(465.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect5];
    
    UIButton *effect6 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect6 addTarget:self  action:@selector(effect6) forControlEvents:UIControlEventTouchUpInside];
    [effect6 setImage:[UIImage imageNamed:@"fade.png"] forState:UIControlStateNormal];
    effect6.frame = CGRectMake(580.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect6];
    
    UIButton *effect7 = [UIButton buttonWithType:UIButtonTypeCustom];
    [effect7 addTarget:self  action:@selector(effect7) forControlEvents:UIControlEventTouchUpInside];
    [effect7 setImage:[UIImage imageNamed:@"transfer.png"] forState:UIControlStateNormal];
    effect7.frame = CGRectMake(695.0, 5.0, 110.0, 0.65*screenLeftHeight-15);
    [effectSelect addSubview:effect7];

}

//- (void) dealloc {
//    
//    NSLog(@"VideoMakerViewController dealloc.");
//    
//}

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

- (UIImage *)resizeFromImage:(NSString *)url {

    UIImage *sourceImage = [UIImage imageWithContentsOfFile:url];
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
    
    scaledImage = [self setBlackBackground:scaledImage withCount:photoCount];
    return scaledImage;
}

- (UIImage *)setBlackBackground:(UIImage *)sourceImage withCount:(int)fileCount{
    NSString *filePath = _imageArray[fileCount];
//    NSLog(@"%@",fileName);
    //    UIImage *sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    NSString *fileName = [filePath componentsSeparatedByString:@"/"].lastObject;
    //    NSString *fileNameWithoutExtension = [fileName componentsSeparatedByString:@"."].firstObject;
    NSString *year = [fileName substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [fileName substringWithRange:NSMakeRange(4, 2)];
    NSString *date = [fileName substringWithRange:NSMakeRange(6, 2)];
    
    NSString *fileNameWithDash = [NSString stringWithFormat:@"%@-%@-%@",year,month,date];
//    NSLog(@"%@",fileNameWithDash);
    
    NSString *imageTitle = [self showDayData:fileNameWithDash];
    
    NSInteger lineCount = [imageTitle componentsSeparatedByString:@"\n"].count;
    NSData *labelData = [imageTitle dataUsingEncoding:NSUTF8StringEncoding];
    
    UILabel *imageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 640, 64)];
    [imageTitleLabel setNumberOfLines:0];
    imageTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    imageTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    imageTitleLabel.text = imageTitle;
    imageTitleLabel.textColor = [UIColor whiteColor];

    
    if ((long)lineCount>1 || labelData.length >50) {
        imageTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    } else {
        imageTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:32.0];
    }
    
    UIImage *background = [UIImage imageNamed:@"blackBackground.jpg"];
    CGSize backgroundSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(backgroundSize);
    [background drawInRect:CGRectMake(0, 0, 640, 640)];
    [sourceImage drawInRect:CGRectMake(320-sourceImage.size.width/2, 0, sourceImage.size.width, sourceImage.size.height)];
    [background drawInRect:CGRectMake(0, 576, 640, 64)];
    [imageTitleLabel drawTextInRect:CGRectMake(0, 576, 640, 64)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}










- (void)showVideoPreView {
//    NSLog(@"updating");
    if (photoCount < imageArr.count) {
        if (photoFrame<FRAMES) {
            float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
            float scaleRate = 1.2+0.1*(frameToFloat/FRAMES);
            switch (effectType) {
                case 1:
                {
                    videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    break;
                }
                case 2:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                case 3:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                case 4:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                case 5:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                case 6:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                    
                case 7:
                {
                    UIImage *animationImage = [self scaleImage:imageArr[photoCount] toScale:scaleRate];
                    CIImage *ciImage = [[CIImage alloc] initWithImage:animationImage];
                    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciImage, nil];
                    [filter setDefaults];
                    CIContext *context = [CIContext contextWithOptions:nil];
                    CIImage *outputImage = [filter outputImage];
                    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                    videoPreview.image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    break;
                }
                    
                default:
                    break;
            }
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
//        [musicPlayer play];
        [previewTimer invalidate];
        replayBtn.hidden = false;
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
//    [previewTimer invalidate];
    WaitForMakeVideoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WaitForMakeVideoViewController"];
    vc.effectType = [NSNumber numberWithInt:effectType];
    vc.musicType = [NSNumber numberWithInt:musicType];
    vc.imageArr = imageArr;
    vc.imagePathArr = _imageArray;
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

- (void)effect4 {
    effectType = 4;
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

- (void)effect5 {
    effectType = 5;
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

- (void)effect6 {
    effectType = 6;
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

- (void)effect7 {
    effectType = 7;
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
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"(happy)Jolly_Old_St_Nicholas_Instrumental.mp3" withExtension:nil];
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
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"(happy2)How_About_It.mp3" withExtension:nil];
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

- (void)music3 {
    musicType = 3;
    replayBtn.hidden = true;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"(rockSweet)Sunflower.mp3" withExtension:nil];
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

- (void)music4 {
    musicType = 4;
    replayBtn.hidden = true;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"(soso)Where_I_am_From.mp3" withExtension:nil];
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

- (void)music5 {
    musicType = 5;
    replayBtn.hidden = true;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"(sweet)Sweet_as_Honey.mp3" withExtension:nil];
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




-(NSString *) showDayData:(NSString *)dateWithDash {
    
    //    load day data plist
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [docPath stringByAppendingPathComponent:@"dayData.plist"];
    
    NSMutableDictionary *allDayDatas = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    
    
    
    //    oneDayData = daySingleton.allDayDatas[_smallDateLable.text];
    
    //    將plist讀取出來的資料，給當天這個物件
    oneDayData = allDayDatas[dateWithDash];
    
    //    第一次使用app，plist的allDayDatas是nil，如果不打if這行，會造成singleton nil
    if (allDayDatas != nil) {
        daySingleton.allDayDatas = allDayDatas;
    }
    
    //沒資料的話隱藏標籤，否則顯示出來
    if (oneDayData == nil) {
        
        return nil;
    }
    
    
    //    標籤內容自動換行
    
    NSString *imageTitle = oneDayData.imgTitle;
    
    //    doc資料夾位置會變，所以不能用存在plist裡的URL
    //    _imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:oneDayData.imageURL]];
    //    NSLog(@"imageURL: %@",oneDayData.imageURL);
    
    
    return imageTitle;
 
}


@end



