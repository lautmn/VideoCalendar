//
//  ImageBrowser.m
//  objectCase
//
//  Created by JUMP on 2016/5/13.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "ImageBrowser.h"

static CGRect oldframe;

@implementation ImageBrowser

//改用物件方法，使用類別方法的話，delegate無法使用
-(void) showImage:(UIImageView*)oldImageView{
    
    UIImage *image = oldImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    
    
    
    oldframe = [oldImageView convertRect:oldImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0.1; //沒反應？
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    
    imageView.image=image;
    imageView.tag=1;
    
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        
              //        全螢幕
        imageView.frame = backgroundView.frame;
        
        
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSLog(@"imageView.width: %f",imageView.frame.size.width);
        NSLog(@"image.width: %f",imageView.image.size.width);
        NSLog(@"imageView.height: %f",imageView.frame.size.height);
        NSLog(@"image.height: %f",imageView.image.size.height);
        
        
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:imageView.frame];
//        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    scrollView.contentSize = imageView.frame.size;
    
    scrollView.maximumZoomScale = 3.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.zoomScale = 1.0;
    
    scrollView.delegate = self;
    
    [scrollView addSubview:imageView];
    [backgroundView addSubview:scrollView];
    [window addSubview:backgroundView];
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return [[scrollView subviews] objectAtIndex:0];
    
}

-(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

@end















