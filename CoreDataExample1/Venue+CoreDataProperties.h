//
//  Venue+CoreDataProperties.h
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/2.
//  Copyright © 2016年 YuanGao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Venue.h"

NS_ASSUME_NONNULL_BEGIN

@interface Venue (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSNumber *specialCount;
@property (nullable, nonatomic, retain) TeaCategory *teaCategory;
@property (nullable, nonatomic, retain) Location *location;
@property (nullable, nonatomic, retain) PriceInfo *priceInfo;
@property (nullable, nonatomic, retain) Stats *stats;

@end

NS_ASSUME_NONNULL_END
