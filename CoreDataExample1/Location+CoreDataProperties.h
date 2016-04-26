//
//  Location+CoreDataProperties.h
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/2.
//  Copyright © 2016年 YuanGao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *zipcode;
@property (nullable, nonatomic, retain) Venue *venue;

@end

NS_ASSUME_NONNULL_END
