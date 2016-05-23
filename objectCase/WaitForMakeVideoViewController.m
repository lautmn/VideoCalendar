//
//  WaitForMakeVideoViewController.m
//  objectCase
//
//  Created by lautmn on 2016/5/15.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "WaitForMakeVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "OneDayData.h"
#import "DaySingletonManager.h"


#define FRAMES 60
#define SEC_PER_PHOTO 3.0

@interface WaitForMakeVideoViewController () {
    int idx;
    int frameRemainder;
    NSTimer *myTimer;
    unsigned long totalFrames;
    NSString *myMoviePath;
    NSURL *musicURL;
    UIImage *animationScaleImage;
    UIImage *scaledImage;
    UIImage *background;
    BOOL didCancelVideo;
    float nowProgressPercent;
    OneDayData *oneDayData;
    DaySingletonManager *daySingleton;
    BOOL mergeMovieFinished;

}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation WaitForMakeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mergeMovieFinished = false;
    // Do any additional setup after loading the view.
    [self getMusicURL];
    didCancelVideo = false;
//    animationScaleImage = [[UIImage alloc] init];
    self.navigationItem.hidesBackButton = YES;
    background = [UIImage imageNamed:@"blackBackground.jpg"];
    totalFrames = FRAMES * _imageArr.count - 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(logSomething) userInfo:nil repeats:true];

    
    [self testCompressionSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelVidio:(id)sender {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"停止製作影片" message:@"確定要停止嗎?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"停止製作" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        didCancelVideo = true;
        
        [myTimer invalidate];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:myMoviePath])
            [[NSFileManager defaultManager] removeItemAtPath:myMoviePath error:nil];
        
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"繼續製作" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ((int)(nowProgressPercent*100) == 100) {
            UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"完成" message:@"影片製作已完成" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok2 = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:true completion:nil];
            }];
            [alert2 addAction:ok2];
            [self presentViewController:alert2 animated:true completion:nil];
        }
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
    
}


- (void)getMusicURL {
    switch ([_musicType intValue]) {
        case 1:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"(happy)Jolly_Old_St_Nicholas_Instrumental.mp3" withExtension:nil];
            
            break;
        }
            
        case 2:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"(happy2)How_About_It.mp3" withExtension:nil];
            break;
        }
            
        case 3:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"(rockSweet)Sunflower.mp3" withExtension:nil];
            break;
        }
            
        case 4:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"(soso)Where_I_am_From.mp3" withExtension:nil];
            break;
        }
            
        case 5:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"(sweet)Sweet_as_Honey.mp3" withExtension:nil];
            break;
        }
            
        default:
            break;
    }

}

- (void)logSomething {
    int nowProgressFrame = idx * FRAMES + frameRemainder;
    nowProgressPercent = (float)nowProgressFrame/totalFrames;
    _progressView.progress = nowProgressPercent;
    _progressLabel.text = [NSString stringWithFormat:@"已完成 : %i %%",(int)(nowProgressPercent*100)];
//    NSLog(@"NOW:  : %i",nowProgressFrame);
//    NSLog(@"TOTAL : %lu",totalFrames);
//    NSLog(@"NOW:  : %f",nowProgressPercent);
    if ((int)(nowProgressPercent*100) == 100) {
        [myTimer invalidate];
        while (mergeMovieFinished == false) {
            [NSThread sleepForTimeInterval:0.1];
        }
        [self CompileFilesToMakeMovie];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"完成" message:@"影片製作已完成" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:true completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
    }
}


- (void)testCompressionSession {
    //    NSLog(@"開始");
    //    NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",dateString]];
    myMoviePath = moviePath;
    
    CGSize size =CGSizeMake(640,640);//定義影片大小
    
    NSError *error =nil;
    
    unlink([moviePath UTF8String]);
    //    NSLog(@"path->%@",moviePath);
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
    NSParameterAssert(videoWriter);
    if(error) NSLog(@"error =%@", [error localizedDescription]);
    
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]) NSLog(@"Add Input Success");
    else NSLog(@"Add Input Fail");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //將照片合成影片
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame = 0;
    
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]) {

            if (didCancelVideo) {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"did Cancel");
                }];
                break;
            }
            
            
            if (++frame >=[_imageArr count]*FRAMES) {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"finish");
                    mergeMovieFinished = true;
                }];
                break;
            }
            
            
            CVPixelBufferRef buffer = NULL;
            
            idx = frame/FRAMES;
            NSLog(@"idx==%d",idx);
            
            frameRemainder = frame%FRAMES;
            NSLog(@"%i",frameRemainder);
            
            float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
            float scaleRate = 1.2+0.1*(remainderToFloat/FRAMES);
            
            
            
            @autoreleasepool {
                switch ([_effectType intValue]) {
                    case 1:
                    {
                        animationScaleImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        break;
                    }
                    case 2:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }
                        
                    case 3:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }

                    case 4:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }
                        
                    case 5:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }

                    case 6:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }
                        
                    case 7:
                    {
                        UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
                        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciImage, nil];
                        [filter setDefaults];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CIImage *outputImage = [filter outputImage];
                        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                        animationScaleImage = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        break;
                    }
                        
                        
                        
                    default:
                        break;
                }
            }
            
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
            animationScaleImage = nil;

            
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,FRAMES/SEC_PER_PHOTO)]) {
                    NSLog(@"FAIL");
                } else {
                    NSLog(@"OK");
                }
                CVPixelBufferRelease(buffer);
            }
        }
    }];
}


/*
- (NSString*)getTheEffect:(int)effectType {
    
    float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
    float scaleRate = 1.0+0.1*(remainderToFloat/FRAMES);
    UIImage *originalImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
    CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    animationScaleImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return nil;
}
*/


- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}




- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
//    @autoreleasepool {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scaledImage = [self setBlackBackground:scaledImage];
//    }
    
    return scaledImage;
}

- (UIImage *)setBlackBackground:(UIImage *)sourceImage {
    
    
    NSString *filePath = _imagePathArr[idx];
    NSString *fileName = [filePath componentsSeparatedByString:@"/"].lastObject;
    NSString *year = [fileName substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [fileName substringWithRange:NSMakeRange(4, 2)];
    NSString *date = [fileName substringWithRange:NSMakeRange(6, 2)];
    NSString *fileNameWithDash = [NSString stringWithFormat:@"%@-%@-%@",year,month,date];
    
    NSString *imageTitle = [self showDayData:fileNameWithDash];
    
    NSInteger lineCount = [imageTitle componentsSeparatedByString:@"\n"].count;
    NSData *labelData = [imageTitle dataUsingEncoding:NSUTF8StringEncoding];
    
    UILabel *imageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 640, 40)];
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


-(void)CompileFilesToMakeMovie {
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL *audio_inputFileUrl = musicURL;
    NSURL *video_inputFileUrl = [NSURL fileURLWithPath:myMoviePath];
    
    NSURL *outputFileUrl = video_inputFileUrl;
//    NSString* outputFileName = @"outputFile.mp4";
//    NSString *outputFilePath = [NSString stringWithFormat:@"%@/%@",path,outputFileName];
//    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    // Audio
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audio_inputFileUrl options:nil];
    // Video
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:video_inputFileUrl options:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    CMTime audioStartTime = kCMTimeZero;
    
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    CMTimeRange videoView_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *mixCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [mixCompositionTrack insertTimeRange:videoView_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVMutableCompositionTrack *mixAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [mixAudioTrack insertTimeRange:audio_timeRange ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:audioStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:myMoviePath])
        [[NSFileManager defaultManager] removeItemAtPath:myMoviePath error:nil];
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        switch (_assetExport.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporter Failed");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporter Completed");

                break;
        }
    }];
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





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
