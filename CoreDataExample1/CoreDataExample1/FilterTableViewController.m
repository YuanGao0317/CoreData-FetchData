//
//  FilterTableViewController.m
//  CoreDataExample1
//
//  Created by GaoYuan on 16/3/3.
//  Copyright © 2016年 YuanGao. All rights reserved.
//

#import "FilterTableViewController.h"

@interface FilterTableViewController ()
{
    NSPredicate *_cheapVenuePredicate;
    NSPredicate *_moderateVenuePredicate;
    NSPredicate *_expensiveVenuePredicate;
    
    NSPredicate *_offeringDealPredicate;
    NSPredicate *_walkingDistancePredicate;
    NSPredicate *_hasUserTipsPredicate;
    
    NSSortDescriptor *_nameSortDescriptor;
    NSSortDescriptor *_distanceSortDescriptor;
    NSSortDescriptor *_priceSortDescriptor;
}

@property (nonatomic,strong) NSMutableDictionary *indexDict;
@end

@implementation FilterTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _indexDict = [NSMutableDictionary new];
    
    _selectedSortDescriptors = [NSMutableArray new];
    _selectedPredicates = [NSMutableArray new];
    
    [self _setUpPredicatesAndSortDescriptors];
    
    [self _populateCheapVenueCountLabel];
    [self _populateModerateVenueCountLabel];
    [self _populateExpensiveVenueCountLabel];
    [self _populateDealsCountLabel];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.selectedSortDescriptors = nil;
    self.selectedPredicates = nil;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // SINGLE SELECTION - SECTIONS 0 and 1
    if( [indexPath section] == 0 || [indexPath section] == 1 ){
        if( cell.accessoryType == UITableViewCellAccessoryNone ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            if([self.indexDict count] == 0){
                NSNumber *sec = [NSNumber numberWithInteger:indexPath.section];
                [self.indexDict setObject:indexPath forKey:sec];
            }
            else{
                NSNumber *sec = [NSNumber numberWithInteger:indexPath.section];
                NSIndexPath *lastIndexPath = self.indexDict[sec];
                
                UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndexPath];
                lastCell.accessoryType = UITableViewCellAccessoryNone;
                
                [self.indexDict removeObjectForKey:sec];
                [self.indexDict setObject:indexPath forKey:sec];
            }
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    // MULTIPLE SELECION - SECTION 2
    if( [indexPath section] == 2 ){
        if( cell.accessoryType == UITableViewCellAccessoryNone ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index selected: %ld", (long)indexPath.row);
    
    // Price section
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            
            case 0: //cheapVenueCell
                [self _updateSelectedPredicatesWithPredicate:_cheapVenuePredicate];
                break;
            case 1: //moderateVenueCell
                [self _updateSelectedPredicatesWithPredicate:_moderateVenuePredicate];
                break;
            case 2: //expensiveVenueCell
                [self _updateSelectedPredicatesWithPredicate:_expensiveVenuePredicate];
                break;
            default:
                break;
        }
    }
    
    //Most Popular section
    if ([indexPath section] == 1) {
        switch ([indexPath row]) {
                
            case 0: //offeringDealCell
                [self _updateSelectedPredicatesWithPredicate:_offeringDealPredicate];
                break;
            case 1: //walkingDistanceCell
                [self _updateSelectedPredicatesWithPredicate:_walkingDistancePredicate];
                break;
            case 2: //userTipsCell
                [self _updateSelectedPredicatesWithPredicate:_hasUserTipsPredicate];
                break;
            default:
                break;
        }
    }

    //Sort By section
    if ([indexPath section] == 2) {
        switch ([indexPath row]) {
                
            case 0: //nameAZSortCell
                [self _updateSelectedSortDescriptorsWithDescriptor:_nameSortDescriptor];
                break;
            case 1: //nameZASortCell
                [self _updateSelectedSortDescriptorsWithDescriptor:_nameSortDescriptor.reversedSortDescriptor];
                break;
            case 2: //distanceSortCell
                [self _updateSelectedSortDescriptorsWithDescriptor:_distanceSortDescriptor];
                break;
            case 3: //priceSortCell
                [self _updateSelectedSortDescriptorsWithDescriptor:_priceSortDescriptor];
                break;
                
            default:
                break;
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Event Handler

- (IBAction)searchButton:(UIBarButtonItem *)sender {
    [self.delegate filterViewController:self didSelectPredicates:self.selectedPredicates sortDescriptors:self.selectedSortDescriptors];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Local Methods

-(void) _updateSelectedSortDescriptorsWithDescriptor:(NSSortDescriptor *)sortDescriptor
{
    if (![self.selectedSortDescriptors containsObject:sortDescriptor]) {
        [self.selectedSortDescriptors addObject:sortDescriptor];
    }
}

-(void) _updateSelectedPredicatesWithPredicate:(NSPredicate *)predicate
{
    if (![self.selectedPredicates containsObject:predicate]) {
        [self.selectedPredicates addObject:predicate];
    }
}

-(void) _setUpPredicatesAndSortDescriptors
{
    _cheapVenuePredicate = [NSPredicate predicateWithFormat:@"priceInfo.priceCategory == %@", @"$"];
    _moderateVenuePredicate = [NSPredicate predicateWithFormat:@"priceInfo.priceCategory == %@", @"$$"];
    _expensiveVenuePredicate = [NSPredicate predicateWithFormat:@"priceInfo.priceCategory == %@", @"$$$"];
    
    _offeringDealPredicate = [NSPredicate predicateWithFormat:@"specialCount > 0"];
    _walkingDistancePredicate = [NSPredicate predicateWithFormat:@"specialCount < 500"];
    _hasUserTipsPredicate = [NSPredicate predicateWithFormat:@"stats.tipCount > 0"];
    
    _nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    _distanceSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"location.distance" ascending:YES];
    _priceSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priceInfo.priceCategory" ascending:YES];
}

-(void) _populateCheapVenueCountLabel {
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    // Define result type
    fetchRequest.resultType = NSCountResultType;
    // Define predicate
    fetchRequest.predicate = _cheapVenuePredicate;
    
    NSError *error;
    NSArray <NSNumber *>*results = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results) {
        NSInteger count = [[results firstObject] integerValue];
        self.firstPriceCategoryLabel.text = [NSString stringWithFormat:@"%ld bubble tea places", (long)count];
    } else if (error) {
        NSLog(@"Could not fetch %@",error.userInfo);
    }
}

-(void) _populateModerateVenueCountLabel
{
    // Init fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    // Define result type
    fetchRequest.resultType = NSCountResultType;
    // Define predicate
    fetchRequest.predicate = _moderateVenuePredicate;
    
    NSError *error;
    NSArray <NSNumber *>*results = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results) {
        NSInteger count = [[results firstObject] integerValue];
        self.secondPriceCategoryLabel.text = [NSString stringWithFormat:@"%ld bubble tea places", (long)count];
    } else if (error) {
        NSLog(@"Could not fetch %@",error.userInfo);
    }
}

-(void) _populateExpensiveVenueCountLabel
{
    // Init fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    // Define result type
    fetchRequest.resultType = NSCountResultType;
    // Define predicate
    fetchRequest.predicate = _expensiveVenuePredicate;
    
    NSError *error;
    NSArray <NSNumber *>*results = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results) {
        NSInteger count = [[results firstObject] integerValue];
        self.thirdPriceCategoryLabel.text = [NSString stringWithFormat:@"%ld bubble tea places", (long)count];
    } else if (error) {
        NSLog(@"Could not fetch %@",error.userInfo);
    }
}

-(void) _populateDealsCountLabel
{
    // Init fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    fetchRequest.resultType = NSDictionaryResultType;
    
    // Init expression description
    NSExpressionDescription *sumExpressionDesc = [[NSExpressionDescription alloc] init];
    // Define expression description name
    sumExpressionDesc.name = @"sumDeals";
    // Define expression
    sumExpressionDesc.expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForKeyPath:@"specialCount"]]];
    // Define expression result type
    sumExpressionDesc.expressionResultType = NSInteger32AttributeType;
    // Assign experssion description to fetch request
    fetchRequest.propertiesToFetch = @[sumExpressionDesc];
    
    NSError *error;
    NSArray <NSDictionary *> *results = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (results) {
        NSDictionary *resultDic = [results firstObject];
        NSNumber *numDeals = [resultDic valueForKey:@"sumDeals"];
        self.numDealsLabel.text = [NSString stringWithFormat:@"%ld total deals", (long)numDeals.integerValue];
    } else if (error) {
        NSLog(@"Could not fetch %@",error.userInfo);
    }
}



@end
