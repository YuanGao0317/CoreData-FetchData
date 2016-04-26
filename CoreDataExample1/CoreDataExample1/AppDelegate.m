//
//  AppDelegate.m
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/2.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataStackInObjC.h"
#import "Location.h"
#import "TeaCategory.h"
#import "PriceInfo.h"
#import "Stats.h"
#import "Venue.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic,strong) CoreDataStackInObjC *coreDataStack;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CoreDataStackInObjC *coreDataStack = [[CoreDataStackInObjC alloc] initCoreDataStackWithModelName:@"Bubble_Tea_Finder"];
    
    [self importJSONSeedDataIfNeededIntoStack:coreDataStack];
    
    UINavigationController *navController = (UINavigationController *)[self.window rootViewController];
    ViewController *viewController = (ViewController *)navController.topViewController;
    
    viewController.coreDataStack = coreDataStack;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void) importJSONSeedDataIfNeededIntoStack:(CoreDataStackInObjC *)coreDataStack
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Venue"];
    
    NSError *error;
    NSUInteger resultsCount = [coreDataStack.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (resultsCount == 0) {
        NSError *error;
        NSArray <Venue *> *results = [coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (Venue *venue in results) {
            Venue *team = venue;
            
            [coreDataStack.managedObjectContext deleteObject:team];
        }
        
        [coreDataStack saveContextWithCompletion:nil];
        [self importJSONDataIntoStack:coreDataStack];
        
        if (error) {
            NSLog(@"Fetch error: %@", error.localizedDescription);
        }
    } else if (error) {
        NSLog(@"Result count error: %@", error.localizedDescription);
    }
}



-(void) importJSONDataIntoStack:(CoreDataStackInObjC *)coreDataStack
{
    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"seed" withExtension:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    
    NSEntityDescription *venueEntity = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:coreDataStack.managedObjectContext];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:coreDataStack.managedObjectContext];
    NSEntityDescription *teaCategoryEntity = [NSEntityDescription entityForName:@"TeaCategory" inManagedObjectContext:coreDataStack.managedObjectContext];
    NSEntityDescription *priceInfoEntity = [NSEntityDescription entityForName:@"PriceInfo" inManagedObjectContext:coreDataStack.managedObjectContext];
    NSEntityDescription *statsEntity = [NSEntityDescription entityForName:@"Stats" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    NSError *error;
    NSJSONSerialization *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if ((NSDictionary *)jsonDict) {
        NSArray *jsonArray = [jsonDict valueForKeyPath:@"response.venues"];
        
        for (NSDictionary *jsonDictionary in jsonArray) {
            NSString *venueName = [jsonDictionary valueForKey:@"name"];
            NSString *venuePhone = [jsonDictionary valueForKey:@"contact.phone"];
            NSNumber *specialCount = [jsonDictionary valueForKeyPath:@"specials.count"];
            NSDictionary *locationDict = [jsonDictionary valueForKey:@"location"];
            NSDictionary *priceDict = [jsonDictionary valueForKey:@"price"];
            NSDictionary *statsDict = [jsonDictionary valueForKey:@"stats"];
            
            Location *location = [[Location alloc] initWithEntity:locationEntity insertIntoManagedObjectContext:coreDataStack.managedObjectContext];
            location.address = [locationDict valueForKey:@"address"];
            location.city = [locationDict valueForKey:@"city"];
            location.state = [locationDict valueForKey:@"state"];
            location.zipcode = [locationDict valueForKey:@"postalCode"];
            location.distance = [locationDict valueForKey:@"distance"];
            
            TeaCategory *teaCategory = [[TeaCategory alloc] initWithEntity:teaCategoryEntity insertIntoManagedObjectContext:coreDataStack.managedObjectContext];
            PriceInfo *priceInfo = [[PriceInfo alloc] initWithEntity:priceInfoEntity insertIntoManagedObjectContext:coreDataStack.managedObjectContext];
            priceInfo.priceCategory = [priceDict valueForKey:@"currency"];
            
            Stats *stats = [[Stats alloc] initWithEntity:statsEntity insertIntoManagedObjectContext:coreDataStack.managedObjectContext];
            stats.checkinsCount = [statsDict valueForKey:@"checkinsCount"];
            stats.usersCount = [statsDict valueForKey:@"userCount"];
            stats.tipCount = [statsDict valueForKey:@"tipCount"];
            
            Venue *venue = [[Venue alloc] initWithEntity:venueEntity insertIntoManagedObjectContext:coreDataStack.managedObjectContext];
            venue.name = venueName;
            venue.phone = venuePhone;
            venue.specialCount = specialCount;
            venue.location = location;
            venue.teaCategory = teaCategory;
            venue.priceInfo = priceInfo;
            venue.stats = stats;
        }
        
        [coreDataStack saveContextWithCompletion:nil];
    } else if (error) {
        NSLog(@"Parse JSON data error: %@", error.localizedDescription);
    }
    
    
}

@end
