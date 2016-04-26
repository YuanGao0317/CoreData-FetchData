//
//  ViewController.m
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/2.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import "ViewController.h"
#import "Venue.h"
#import "FilterTableViewController.h"
#import "SINavigationMenuView.h"
#import "ViewControllerWithFetchResultsController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,FilterTableViewControllerDelegate,SINavigationMenuDelegate>

@property (nonatomic,strong) NSFetchRequest *fetchRequest;
@property (nonatomic,strong) NSAsynchronousFetchRequest *asyncFetchRequest;
@property (nonatomic,strong) NSArray <Venue *> *venues;

@end

@implementation ViewController

static NSString * const kCellIdentifier = @"Cell";
static NSString * const kFilterViewControllerSegueIdentifier = @"toFilterViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _venues = [NSArray new];
    
    // Fetch Data
    [self _fetchData];
    
    // Create Menu
    [self _setUpMoreMenu];
}



#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Venue *venue = self.venues[indexPath.row];
    
    cell.textLabel.text = venue.name;
    cell.detailTextLabel.text = [venue valueForKeyPath:@"priceInfo.priceCategory"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - FilterTableViewControllerDelegate

-(void)filterViewController:(UITableViewController *)filterVC didSelectPredicates:(NSMutableArray <NSPredicate *> *)predicates sortDescriptors:(NSMutableArray <NSSortDescriptor *> *)sortDescriptors
{
    NSFetchRequest *fetchRequest = self.fetchRequest;
    
    fetchRequest.predicate = nil;
    fetchRequest.sortDescriptors = nil;
    
    if (predicates) {
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        fetchRequest.predicate = compoundPredicate;
    }
    
    if (sortDescriptors) {
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    [self _fetchAndReload:fetchRequest];
}


#pragma mark - Event Handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kFilterViewControllerSegueIdentifier]) {
        UINavigationController *navController = segue.destinationViewController;
        FilterTableViewController *filterVC = (FilterTableViewController *)navController.topViewController;
        filterVC.coreDataStack = self.coreDataStack;
        filterVC.delegate = self;
    }
}

- (IBAction)batchUpdateButton:(UIBarButtonItem *)sender {
    
    
}


#pragma mark - SINavigationMenuDelegate

-(void)didSelectItemAtIndex:(NSUInteger)index
{
    if (index == 0) {
        [self batchUpdate];
    }
    
    if (index == 1) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewControllerWithFetchResultsController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewControllerWithFetchResultsController"];
        viewController.coreDataStack = self.coreDataStack;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void) batchUpdate
{
    NSDictionary *property = @{@"favorite":[NSNumber numberWithBool:YES]};
    [self _batchUpdateInEntity:@"Venue" withProperties:property];
}


-(void) _batchUpdateInEntity:(NSString *)entityName withProperties:(NSDictionary *)properties
{
    NSBatchUpdateRequest *batchUpdate = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:entityName];
    batchUpdate.propertiesToUpdate = properties;
    batchUpdate.resultType = NSUpdatedObjectIDsResultType;
    batchUpdate.affectedStores = self.coreDataStack.managedObjectContext.persistentStoreCoordinator.persistentStores;
    batchUpdate.predicate = [NSPredicate predicateWithFormat:@"favorite == %@ OR favorite == nil", @NO];
    
    NSError *error;
    NSBatchUpdateResult *batchResult = [self.coreDataStack.managedObjectContext executeRequest:batchUpdate error:&error];
    
    if ([[batchResult result] respondsToSelector:@selector(count)]){
        if ([[batchResult result] count] > 0){
            [self.coreDataStack.managedObjectContext performBlock:^{
                for (NSManagedObjectID *objectID in [batchResult result]){
                    NSError         *faultError = nil;
                    NSManagedObject *object     = [self.coreDataStack.managedObjectContext existingObjectWithID:objectID error:&faultError];
                    /**
                     *When you execute a batch update using the NSBatchUpdateRequest class available 
                     *  since iOS 8, any existing managed object contexts aren't aware of the changes
                     *  made to the persistent store.
                     *Due to this reason, you have to turn your managed objects into Fault objects, and
                     *  refresh the managed object and merge the changes into persistent store
                     *About Faulting:
                     *https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/FaultingandUniquing.html
                     **/
                    [self.coreDataStack.managedObjectContext refreshObject:object mergeChanges:YES];
                }
            }];
            
            NSString *message = [NSString stringWithFormat:@"Records updated: %u", [[batchResult result] count]];
            [self _showAlertWithTitle:@"Updated" andMessage:message];
            NSLog(@"Records updated: %u", [[batchResult result] count]);
        } else if (error) {
            [self _showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
            NSLog(@"Batch update error: %@", error.localizedDescription);
        }
    } else {
        [self _showAlertWithTitle:@"Error" andMessage:@"Batch update failed."];
    }
}


#pragma mark - Local Methods

-(void) _setUpMoreMenu
{
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        SINavigationMenuView *menu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"More"];
        //Set in which view we will display a menu
        [menu displayMenuInView:self.view];
        //Create array of items
        menu.items = @[@"Batch Update", @"NSFetchedResultsController"];
        menu.delegate = self;
        self.navigationItem.titleView = menu;
    }
}

-(void) _fetchData
{
    //    //Fetch using fetch request template
    //    NSManagedObjectModel *model = self.coreDataStack.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    //    self.fetchRequest = [model fetchRequestTemplateForName:@"FetchRequest"];
    
    
    // NSFetchRequest
    _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    _fetchRequest.fetchBatchSize = 10;
    
    // NSAsynchronousFetchRequest
    _asyncFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:self.fetchRequest completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        __unsafe_unretained __typeof(self) weakSelf = self;
        weakSelf.venues = result.finalResult;
        [weakSelf.tableView reloadData];
    }];
    
    [self _asyncFetch:_asyncFetchRequest];
//    [self _fetchAndReload:self.fetchRequest];
    
}

-(void) _fetchAndReload:(nonnull NSFetchRequest *)fetchRequest
{
    NSError *error;
    self.venues = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Fetch request error: %@", error.localizedDescription);
    }
    [self.tableView reloadData];
}

-(void) _asyncFetch:(nonnull NSAsynchronousFetchRequest *)asyncFetchRequest
{
    NSError *error;
    [self.coreDataStack.managedObjectContext executeRequest:asyncFetchRequest error:&error];
    
    if (error) {
        NSLog(@"Async fetch request error: %@", error.localizedDescription);
    }
}

-(void) _showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
