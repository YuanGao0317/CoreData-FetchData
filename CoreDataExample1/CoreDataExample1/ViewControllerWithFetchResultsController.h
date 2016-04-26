//
//  ViewControllerWithFetchResultsController.h
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/3.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataStackInObjC.h"

@interface ViewControllerWithFetchResultsController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) CoreDataStackInObjC *coreDataStack;
@end
