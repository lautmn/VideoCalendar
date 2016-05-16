//
//  SelectImageCollectionViewController.h
//  FinalProject
//
//  Created by lautmn on 2016/4/29.
//  Copyright © 2016年 lautmn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectImageCollectionViewController : UICollectionViewController

@property (nonatomic,strong) NSMutableArray *imageSelected;
@property (nonatomic,strong) NSMutableArray *imageURLArray;
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;

@end
