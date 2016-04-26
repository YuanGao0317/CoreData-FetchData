//
//  ViewControllerWithFetchResultsController.m
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/3.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import "ViewControllerWithFetchResultsController.h"
#import "Venue.h"

@interface ViewControllerWithFetchResultsController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ViewControllerWithFetchResultsController

static NSString * const kCellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self _fetchDataUsingFetchedResultsController];
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [self _configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Change object's value in core data
    Venue *venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (venue.favorite.boolValue) {
        venue.favorite = [NSNumber numberWithBool:NO];
    } else {
        venue.favorite = [NSNumber numberWithBool:YES];
    }
    
    
    [self.coreDataStack saveContextWithCompletion:^(BOOL success) {
        if (success) {
            // It is not efficient to fetch all data and reload all data after every single value change, we'd better to use NSFetchedResultsControllerDelegate when working with NSFetchedResultsController
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self _fetchDataUsingFetchedResultsController];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            });
        }
    }];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        return [[sectionInfo name] boolValue] ? @"Favorite: Yes" : @"Favorite: No";
    } else
        return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"section count: %d",[self.tableView numberOfSections]);
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self _configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - Local Methods

-(void) _fetchDataUsingFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    
    // A request must have a sortDescriptor if we want to use it in fetchedResultsController
    // Separate fetched results using a section keyPath, the first sort descriptor’s attribute must match the key path’s attribute.
    NSSortDescriptor *favoriteSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"favorite" ascending:NO];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    
    request.sortDescriptors = @[favoriteSortDescriptor,nameSortDescriptor];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:request
                                 managedObjectContext:self.coreDataStack.managedObjectContext
                                 sectionNameKeyPath:@"favorite" //separate in sections, it can drill deep into a Core Data relationship, such as “employee.address.street”
                                 cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"FetchedResultsController error: %@",error.localizedDescription);
    }
}

-(void) _configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Venue *venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = venue.name;
    NSNumber *favorite = [venue valueForKeyPath:@"favorite"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Favorite: %@", [favorite boolValue] ? @"Yes" : @"No"];
}

@end
