//
//  SelectImageCollectionViewController.m
//  FinalProject
//
//  Created by lautmn on 2016/4/29.
//  Copyright © 2016年 lautmn. All rights reserved.
//

#import "SelectImageCollectionViewController.h"
#import "SelectImageCollectionViewCell.h"
#import "VideoMakerViewController.h"

@interface SelectImageCollectionViewController () {
    NSString *startDateSting;
    NSString *endDateSting;
}

@end

@implementation SelectImageCollectionViewController

static NSString * const reuseIdentifier = @"SelectImageCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@",_startDate);
//    NSLog(@"%@",_endDate);
    
    NSArray *startDateArray = [_startDate componentsSeparatedByString:@"/"];
    NSArray *endDateArray = [_endDate componentsSeparatedByString:@"/"];
    
    startDateSting = [NSString stringWithFormat:@"%@%@%@", startDateArray[0], startDateArray[1], startDateArray[2]];
    endDateSting = [NSString stringWithFormat:@"%@%@%@", endDateArray[0], endDateArray[1], endDateArray[2]];

    int startDateInt = [startDateSting intValue];
    int endDateInt = [endDateSting intValue];
    
    
    _imageURLArray = [[NSMutableArray alloc] init];
    _imageSelected = [[NSMutableArray alloc] init];
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSLog(@"Documents: %@",documentsURL.absoluteString);
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *url in paths) {
        if ([[url componentsSeparatedByString:@"."].lastObject isEqualToString:@"jpeg"]) {
            NSString *fileName = [url componentsSeparatedByString:@"."].firstObject;
            int fileNameInt = [fileName intValue];
            if (fileNameInt >= startDateInt && fileNameInt <= endDateInt) {
                NSString *fullPath = [NSString stringWithFormat:@"%@/%@",path,url];
//                NSURL *fullURL = [documentsURL URLByAppendingPathComponent:url];
//                [_imageURLArray addObject:fullURL];
                [_imageURLArray addObject:fullPath];
                [_imageSelected addObject:@(true)];
            }
        }
    }
    
    if (_imageURLArray.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"所選的時間範圍內沒有照片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
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

#pragma mark <UICollectionViewDataSource>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width-30;
    return CGSizeMake(screenWidth*(1.0/3), screenWidth*(1.0/3));
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_imageURLArray[indexPath.row]]];
    UIImage *image = [UIImage imageWithContentsOfFile:_imageURLArray[indexPath.row]];
    
    cell.photoImageView.image = [self resizeFromImage:image];
    
    if ([_imageSelected[indexPath.row]  isEqual: @(true)]) {
        cell.checkedImageView.image = [UIImage imageNamed:@"selected.png"];
    }
    else {
        cell.checkedImageView.image = nil;
    }
    
//    NSLog(@"%@",_imageSelected[indexPath.row]);

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
//    UICollectionViewCell *selectedCell =[collectionView cellForItemAtIndexPath:indexPath];
    
    SelectImageCollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([_imageSelected[indexPath.row]  isEqual: @(true)]) {
        [_imageSelected replaceObjectAtIndex:indexPath.row withObject:@(false)];
        selectedCell.checkedImageView.image = nil;
    } else {
        [_imageSelected replaceObjectAtIndex:indexPath.row withObject:@(true)];
        selectedCell.checkedImageView.image = [UIImage imageNamed:@"selected.png"];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *datasetCell =[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.selected = true;
    
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (UIImage *)resizeFromImage:(UIImage *)sourceImage {
    
    CGFloat maxValue = 200.0;
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
    
    return resultImage;
}

/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"gotoMakeMovie"]){
        NSMutableArray *imageArr = [[NSMutableArray alloc] init];
        VideoMakerViewController *vc = segue.destinationViewController;
        for (int i=0; i<_imageSelected.count; i++) {
            if ([_imageSelected[i]  isEqual: @(true)]) {
                [imageArr addObject:self.imageURLArray[i]];
            }
        }
        vc.imageArray  = imageArr;
    }
}
*/


- (IBAction)okBtnPressed:(id)sender {
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    VideoMakerViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoMakerViewController"];
    for (int i=0; i<_imageSelected.count; i++) {
        if ([_imageSelected[i]  isEqual: @(true)]) {
            [imageArr addObject:self.imageURLArray[i]];
        }
    }
    
    if (imageArr.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"請至少選擇一張相片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
    }
    
    vc.imageArray  = imageArr;
    [self showViewController:vc sender:nil];
    
}



@end
