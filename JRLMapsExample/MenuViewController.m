////////////////////////////////////////////////////////////////////////////
//
// Created by Roger Lee on 31/01/2017.
// Copyright (c) 2017 JRLee Pty Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "MenuViewController.h"
#import "Common.h"

@interface MenuViewController () <GMSAutocompleteResultsViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, DropPinDelegate>

@property (strong, nonatomic) IBOutlet GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) IBOutlet UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UILabel *streetAddressLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Maps Example";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressSearchAddressButton:(id)sender {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    filter.country = @"au";
    
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;
    _resultsViewController.autocompleteFilter = filter;
    //_resultsViewController.autocompleteBounds = bounds;
    
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    _searchController.searchBar.text = self.streetAddressLabel.text;
    _searchController.searchBar.delegate = self;
    _searchController.delegate = self;
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    // Put the search bar in the navigation bar.
    [_searchController.searchBar sizeToFit];
    self.navigationItem.titleView = _searchController.searchBar;
    
    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
    
    // Prevent the navigation bar from being hidden when searching.
    _searchController.hidesNavigationBarDuringPresentation = NO;
    [_searchController.searchBar becomeFirstResponder];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"dropPinSegue"]) {
        
        GoogleMapsDropPinViewController *detailsVC = (GoogleMapsDropPinViewController *)(segue.destinationViewController);
        detailsVC.delegate = self;
    }
        
}
    
#pragma mark - Drop Pin Delegate

- (void)didTapDropPinWindow:(GMSMarker *)marker {
    
    CLLocationCoordinate2D location = marker.position;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"0.####"];
    
    self.coordinates.text = [NSString stringWithFormat: @"%@,%@",[formatter stringFromNumber:[NSNumber numberWithDouble:location.latitude]],[formatter stringFromNumber:[NSNumber numberWithDouble:location.longitude]]];
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Google Place Search

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    _searchController.active = NO;
    
    CLLocationCoordinate2D coordinate = place.coordinate;
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Coordinate %f,%f", coordinate.latitude, coordinate.longitude);
    NSLog(@"Place ID %@", place.placeID);
    
    self.streetAddressLabel.text = place.formattedAddress;
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.navigationItem.titleView = nil;
    [searchBar resignFirstResponder];
}


@end
