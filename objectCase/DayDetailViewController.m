//
//  DetailViewController.m
//  JumpCalendar
//
//  Created by JUMP on 2016/4/18.
//  Copyright © 2016年 Jump. All rights reserved.
//

#import "DayDetailViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DaySingletonManager.h"
#import "ImageBrowser.h"


#define kAnimationDuration 0.2
#define kViewHeight 56

@interface DayDetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>
{
    DaySingletonManager *daySingleton;
    ImageBrowser * browser;
    __weak IBOutlet NSLayoutConstraint *deleteLayout;
}

@end

@implementation DayDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //lable的值，等於上一頁segue傳過來的值，這頁有設string，才能傳值
    _bigDateLable.text = _bigDateStr;
    _smallDateLable.text = _smallDateStr;
    _smallWeekLable.text = _smallWeekStr;
    _dayDetailTextView.delegate = self;
    
    
    daySingleton = [DaySingletonManager sharedData];
    
    //    預設隱藏刪除鍵，有資料才顯示
    _deleteBtn.hidden = true;
    
    _oneDayData = [daySingleton getOneDayDataWithKey:_smallDateLable.text];
    
    //    如果當天資料存在的話，顯示出當天資料
    if (_oneDayData != nil) {
        
        
        
        _imgTitleTextView.text = _oneDayData.imgTitle;
        _dayDetailTextView.text = _oneDayData.dayDetail;
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [docPath stringByAppendingPathComponent:[_smallDateLable.text stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        
        NSString *photoPath = [NSString stringWithFormat:@"%@.jpeg",path];
        
        _imageView.image = [UIImage imageWithContentsOfFile:photoPath];;
        
        _deleteBtn.hidden = false;
        
        

        
    }
    
//        增加imageView觸碰手勢
    _imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage)];
    
    [_imageView addGestureRecognizer:tap];
    
    NSLog(@"oneDayData: %@",_oneDayData);
    
//    邊寬與圓角
    _insertImgBtn.layer.borderWidth = 2.0f;
    _insertImgBtn.layer.cornerRadius = 3.0f;
    _dayDetailTextView.layer.borderWidth = 2.0f;
    _dayDetailTextView.layer.cornerRadius = 3.0f;
    _imgTitleTextView.layer.borderWidth = 2.0f;
    _imgTitleTextView.layer.cornerRadius = 3.0f;
    _imageView.layer.cornerRadius = 3.0f;
    _deleteBtn.layer.borderWidth = 2.0f;
    _deleteBtn.layer.cornerRadius = 10.0f;
    _saveBtn.layer.borderWidth = 2.0f;
    _saveBtn.layer.cornerRadius = 10.0f;
//    _deleteBtn.layer.borderColor = [[UIColor redColor] CGColor];
}

- (void)magnifyImage
{
    if (_imageView.image != nil) {
        browser = [[ImageBrowser alloc] init];
        [browser showImage:self.imageView];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)insertImgBtnPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Image Source" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
    
}

-(void) launchImagePickerWithSourceType:(UIImagePickerControllerSourceType) sourceType {
    
    
    //    檢查硬體是否有此裝置
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
        NSLog(@"SourceType is not supported.");
        return;
    }
    
    //Prepare UIImagePickerContorller
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = sourceType;
    //    imagePicker.mediaTypes = @[@"public.image"];
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *type = info[UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:(NSString*)kUTTypeImage]) {
        //Image
        
//        _imageView.image = info[UIImagePickerControllerOriginalImage];
        
//        NSData *jpegData = UIImageJPEGRepresentation(_imageView.image, 0.6);
        
        NSData *jpegData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.6);
        NSLog(@"PhotoSize: %fx%f (%ld bytes)",_imageView.image.size.width,_imageView.image.size.height,(unsigned long)jpegData.length);
        
        _imageView.image = [UIImage imageWithData:jpegData];
        
    }
    //    選取完dismiss掉
    [picker dismissViewControllerAnimated:true completion:nil];
 
    
}

#pragma mark - Btn Pressed
- (IBAction)backBtnPressed:(id)sender {
    [_imgTitleTextView resignFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveBtnPressed:(id)sender {
    
//    初始化"當天資料"這個物件
    _oneDayData = [OneDayData new];
    
    
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    
//    將yyyy-MM-dd這種格式轉成yyyyMMdd
    NSString *fileNameFormat = [_smallDateLable.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.jpeg",fileNameFormat];
    
    NSURL *fullImagePath = [documentsURL URLByAppendingPathComponent:imageName];
    
//    NSLog(@"Documents: %@",documentsURL.absoluteString);
//    NSLog(@"Documents2: %@",documentsURL.absoluteURL); 與上面的差別？
    
    NSData *data = UIImageJPEGRepresentation(_imageView.image, 0.5);
    [data writeToURL:fullImagePath atomically:true];
    
    //將當天資料存到daySingleton，key是 2016-04-25這種格式
    _oneDayData.imgTitle = _imgTitleTextView.text;
    _oneDayData.dayDetail = _dayDetailTextView.text;
    _oneDayData.imageURL = fullImagePath;
    [daySingleton setObject:_oneDayData forKey:_smallDateLable.text];
    
//    建立plist
    
    
//    NSURL *fullPlistURL = [documentsURL URLByAppendingPathComponent:@"dayData.plist"];
//    
//    NSString *plistPath = fullPlistURL.path;
//    
//    NSLog(@"plistPath: %@",plistPath);
//    
//    
//    [NSKeyedArchiver archiveRootObject:daySingleton.allDayDatas toFile:plistPath];
    
    [self savePlistToFile];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void) savePlistToFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *plistPath = [docDir stringByAppendingPathComponent:@"dayData.plist"];
    
    
    [NSKeyedArchiver archiveRootObject:daySingleton.allDayDatas toFile:plistPath];

}


- (IBAction)deleteBtnPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"確認刪除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"刪除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        刪除singleton的資料
        [daySingleton deleteDayData:_smallDateLable.text];
        
        //刪除document檔案
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *imageName = [NSString stringWithFormat:@"%@.jpeg",[_smallDateLable.text stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:imageName] error:nil];
        
        [self savePlistToFile];
        
        [self dismissViewControllerAnimated:true completion:nil];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];

    
    
    
    
    
    
}



#pragma mark - TextView Edit
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat tvY = _dayDetailTextView.frame.origin.y;
        
        CGFloat viewY = self.view.frame.origin.y;
        
        self.view.frame = CGRectMake(0, viewY - tvY + 40, self.view.frame.size.width, self.view.frame.size.height);
        
//        _deleteBtn.translatesAutoresizingMaskIntoConstraints = false;

        deleteLayout.constant = 50;

        
        
    }];
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        deleteLayout.constant = 20;
        
    }];
    
    
}

- (IBAction)detailVCTapped:(id)sender {
    [_imgTitleTextView resignFirstResponder];
    [_dayDetailTextView resignFirstResponder];
}

-(void)viewDidLayoutSubviews{
//    CGPoint btnOrigin = _deleteBtn.frame.origin;
//    
//    _deleteBtn.frame = CGRectMake(btnOrigin.x, btnOrigin.y - 20, 40, 36);
}

@end












