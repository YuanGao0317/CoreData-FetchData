//
//  FilterTableViewController.h
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/3.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataStackInObjC.h"

@protocol FilterTableViewControllerDelegate <NSObject>

@required
-(void) filterViewController:(UITableViewController *)filterVC didSelectPredicates:(NSMutableArray <NSPredicate *> *)predicates sortDescriptors:(NSMutableArray <NSSortDescriptor *> *)sortDescriptors;

@end


@interface FilterTableViewController : UITableViewController

// Labels
@property (weak, nonatomic) IBOutlet UILabel *firstPriceCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondPriceCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdPriceCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDealsLabel;

@property (nonatomic,strong) CoreDataStackInObjC *coreDataStack;
@property (nonatomic,strong) NSMutableArray <NSSortDescriptor *> *selectedSortDescriptors;
@property (nonatomic,strong) NSMutableArray <NSPredicate *> *selectedPredicates;

@property (nonatomic,assign) __unsafe_unretained id<FilterTableViewControllerDelegate> delegate;

@end
