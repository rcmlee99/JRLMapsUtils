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

#import "GoogleMapsDropPinViewController.h"

@interface GoogleMapsDropPinViewController () <GMSMapViewDelegate, CLLocationManagerDelegate, UIAdaptivePresentationControllerDelegate>

@property (strong, nonatomic) GMSMarker *infoMarker;
@property (strong, nonatomic) GMSMarker *dropPin;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation GoogleMapsDropPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 5.0f;
    [self requestLocationServices];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.843366
                                                            longitude:151.134002
                                                                 zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.buildingsEnabled = YES;
    self.view = self.mapView;
    self.mapView.settings.compassButton = YES;
    self.mapView.multipleTouchEnabled = YES;
    self.mapView.delegate = self;
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location {
    NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
    [self updateDropPinLocation:location mapView:mapView];
}

- (void)updateDropPinLocation:(CLLocationCoordinate2D)location mapView:(GMSMapView *)mapView {
    self.dropPin = [GMSMarker markerWithPosition:location];
    self.dropPin.title = @"Drop PIN";
    self.dropPin.snippet = [NSString stringWithFormat:@"%.04f,%.04f",location.latitude, location.longitude];
    self.dropPin.opacity = 0;
    self.dropPin.position = location;
    CGPoint pos = self.dropPin.infoWindowAnchor;
    pos.y = 1;
    self.dropPin.infoWindowAnchor = pos;
    self.dropPin.map = mapView;
    mapView.selectedMarker = self.dropPin;
    self.dropPin.draggable = YES;
    self.dropPin.appearAnimation = kGMSMarkerAnimationPop;
    GMSCameraPosition *newpos = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:15];
    [self.mapView setCamera:newpos];
}

- (void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self updateDropPinLocation:coordinate mapView:mapView];
    self.dropPin = [GMSMarker markerWithPosition:coordinate];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapDropPinWindow:)]) {
        [self.delegate didTapDropPinWindow:self.dropPin];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self updateDropPinLocation:coordinate mapView:mapView];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self presentAlertWithTitle:@"Location services" message:@"Please authorize location services" dismissActionTitle:@"Dismiss"];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"CLLocationManager error: %@", error.localizedFailureReason];
    [self presentAlertWithTitle:@"Location services" message:message dismissActionTitle:@"Dismiss"];
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    if (self.infoMarker == nil) {
        self.infoMarker = [[GMSMarker alloc] init];
        self.infoMarker.position = location.coordinate;
        self.infoMarker.map = self.mapView;
    } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:2.0];
        self.infoMarker.position = location.coordinate;
        [CATransaction commit];
    }
    
    GMSCameraPosition *newpos = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    [self.mapView setCamera:newpos];
    [self.manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse))  {
        [self.manager startUpdatingLocation];
    }
}

#pragma mark - CLLocation

- (void)requestLocationServices
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title =  @"Location services are off" ;
        NSString *message = @"To zoom map view to current location you must turn on 'When Using the App' in the Location Services Settings";
        [self presentAlertWithTitle:title message:message dismissActionTitle:@"Dismiss"];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestWhenInUseAuthorization];
    }
    // The user has enable location services.
    else if ((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse))  {
        [self.manager startUpdatingLocation];
    }
}

@end
