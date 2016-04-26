//
//  TeaCategory+CoreDataProperties.h
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/2.
//  Copyright © 2016年 YuanGao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TeaCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface TeaCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *categoryID;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Venue *venue;

@end

NS_ASSUME_NONNULL_END
