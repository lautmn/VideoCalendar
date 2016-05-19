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
    UIImage *resultImage;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation WaitForMakeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getMusicURL];
//    animationScaleImage = [[UIImage alloc] init];
    background = [UIImage imageNamed:@"blackBackground.jpg"];
    totalFrames = FRAMES * _imageArr.count - 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(logSomething) userInfo:nil repeats:true];
    
    [self testCompressionSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)makeImages:(int)idxx {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[_imageArr objectAtIndex:idxx]]];
    UIImage *resizeImage = [self resizeFromImage:image];
    
    return resizeImage;
    
//    for (NSURL *url in _imageArr) {
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//        UIImage *resizeImage = [self resizeFromImage:image];
//        NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1);
//        NSLog(@"%ld",imageData.length);
//        [_imageArr addObject:resizeImage];
//    }
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



- (void)getMusicURL {
    switch ([_musicType intValue]) {
        case 1:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"Animals.mp3" withExtension:nil];
            NSLog(@"ANIMALS");
            break;
        }
            
        case 2:
        {
            musicURL = [[NSBundle mainBundle] URLForResource:@"Maps.mp3" withExtension:nil];
            NSLog(@"MAPS");
            break;
        }
            
        default:
            break;
    }

}

- (void)logSomething {
    int nowProgressFrame = idx * FRAMES + frameRemainder;
    float nowProgressPercent = (float)nowProgressFrame/totalFrames;
//    NSLog(@"===================%f===================",nowProgressPercent);
    _progressView.progress = nowProgressPercent;
    _progressLabel.text = [NSString stringWithFormat:@"已完成 : %i %%",(int)(nowProgressPercent*100)];
//    NSLog(@"NOW:  : %i",nowProgressFrame);
//    NSLog(@"TOTAL : %lu",totalFrames);
    if ((int)(nowProgressPercent*100) == 100) {
        [myTimer invalidate];
        [NSThread sleepForTimeInterval:0.0005];
        [self CompileFilesToMakeMovie];
        NSLog(@"MUSIC:%i",[_musicType intValue]);
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
            if (++frame >=[_imageArr count]*FRAMES) {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            
            idx = frame/FRAMES;
            NSLog(@"idx==%d",idx);
            
            frameRemainder = frame%FRAMES;
            NSLog(@"%i",frameRemainder);
            
            switch ([_effectType intValue]) {
                case 1:
                {
                    float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                    float scaleRate = 1.0+0.1*(remainderToFloat/FRAMES);
                    animationScaleImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                    buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                    animationScaleImage = nil;
                    break;
                }
                    
                case 2:
                {
                    float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                    float scaleRate = 1.1-0.1*(remainderToFloat/FRAMES);
                    animationScaleImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                    buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                    animationScaleImage = nil;
                    break;
                }
                    
                case 3:
                {
                    if (idx%2 == 0) {
                        float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                        float scaleRate = 1.0+0.1*(remainderToFloat/FRAMES);
                        animationScaleImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                        animationScaleImage = nil;
                    } else {
                        float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                        float scaleRate = 1.1-0.1*(remainderToFloat/FRAMES);
                        animationScaleImage = [self scaleImage:[_imageArr objectAtIndex:idx] toScale:scaleRate];
                        buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                        animationScaleImage = nil;
                    }
                    break;
                }
                    
                default:
                    break;
            }
            
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,FRAMES/SEC_PER_PHOTO)]) {
                    NSLog(@"FAIL");
                } else {
                    NSLog(@"OK");
//                    CFRelease(buffer);
                }
//                CFRelease(buffer);
//                CVBufferRelease(buffer);
                CVPixelBufferRelease(buffer);
//                [NSThread sleepForTimeInterval:0.0005];
            }
            
        }
//        [self CompileFilesToMakeMovie];
    }];
}



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
    
    @autoreleasepool {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scaledImage = [self setBlackBackground:scaledImage];
    }
    
    return scaledImage;
}

- (UIImage *)setBlackBackground:(UIImage *)sourceImage {
    CGSize backgroundSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(backgroundSize);
    [background drawInRect:CGRectMake(0, 0, 640, 640)];
    [sourceImage drawInRect:CGRectMake(320-sourceImage.size.width/2, 0, sourceImage.size.width, sourceImage.size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}


-(void)CompileFilesToMakeMovie {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
