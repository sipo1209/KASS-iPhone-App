//
//  MapViewController.m
//  Demo
//
//  Created by zhicai on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "VariableStore.h"
#import "UIViewController+SegueActiveModel.h"

@implementation MapViewController
@synthesize currentMap = _currentMap;
@synthesize backButton = _backButton;

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupMap:(CLLocationCoordinate2D)userCoordinate
{
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userCoordinate ,MAP_DISTANCE_LAT, MAP_DISTANCE_LNG);
  [self.currentMap setRegion:region animated:YES];
  self.currentMap.scrollEnabled = YES;
  self.currentMap.zoomEnabled = YES;
}

- (void) loadMapSingleItem
{
  ListItem *_currentItem = VariableStore.sharedInstance.itemToShowOnMap;
  
  CLLocationCoordinate2D userCoordinate;
  userCoordinate.latitude = [_currentItem.location.latitude doubleValue];
  userCoordinate.longitude = [_currentItem.location.longitude doubleValue];
  
  [self setupMap:userCoordinate];
  
  ListingMapAnnotaion *listingA = [[ListingMapAnnotaion alloc] initWithCoordinate:userCoordinate title:_currentItem.title subTitle:_currentItem.description listingItemData:_currentItem];
  [self.currentMap addAnnotation:listingA];
}

- (void) loadMultipleItems
{
  CLLocationCoordinate2D userCoordinate;
  NSMutableArray *items = VariableStore.sharedInstance.nearBrowseListings;
  if ( VariableStore.sharedInstance.locateMeManager.hasLocation ) {
    userCoordinate.latitude = VariableStore.sharedInstance.location.coordinate.latitude;
    userCoordinate.longitude = VariableStore.sharedInstance.location.coordinate.longitude;
  }else if ( [items count] > 0 ){
    ListItem *item = (ListItem *)[items objectAtIndex:0];
    userCoordinate.latitude = [item.location.latitude doubleValue];
    userCoordinate.longitude = [item.location.longitude doubleValue];
  }
  
  [self setupMap:userCoordinate];
  
  for(int i= 0; i < [items count]; i++){
    
    ListItem *data = (ListItem *)[items objectAtIndex:i];
    
    CLLocationCoordinate2D newCoord = { (CGFloat)[data.location.latitude floatValue], (CGFloat)[data.location.longitude floatValue] };
    
    ListingMapAnnotaion *listingA = [[ListingMapAnnotaion alloc] initWithCoordinate:newCoord title:data.title subTitle:data.description listingItemData:data];
    [self.currentMap addAnnotation:listingA];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    DLog(@"Creating listing annotation view...");
    MKAnnotationView* annotationView = nil;
    ListingImageAnnotationView* imageAnnotationView = (ListingImageAnnotationView*)[self.currentMap dequeueReusableAnnotationViewWithIdentifier:nil];
    if(nil == imageAnnotationView)
    {
        imageAnnotationView = [[ListingImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];	
        imageAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView = imageAnnotationView;
	[annotationView setEnabled:YES];
	[annotationView setCanShowCallout:YES];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  if ( VariableStore.sharedInstance.itemToShowOnMap ) { return; }
  ListingMapAnnotaion *lma = (ListingMapAnnotaion *)[view annotation];
  
  if ( [lma isKindOfClass:ListingMapAnnotaion.class]) {
    [self performSegueByModel:lma.currentItem];
  }

}

//- (void)viewWillAppear:(BOOL)animated {  
//    // 1
//    CLLocationCoordinate2D zoomLocation;
//    zoomLocation.latitude = 39.281516;
//    zoomLocation.longitude = -76.580806;
//    // 2
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
//    // 3
//    MKCoordinateRegion adjustedRegion = [currentMap regionThatFits:viewRegion];                
//    // 4
//    [currentMap setRegion:adjustedRegion animated:YES];        
//}

//- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {    
//    MKAnnotationView *annotationView = [views objectAtIndex:0];
//    id<MKAnnotation> mp = [annotationView annotation];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
//    [mv setRegion:region animated:YES];
//}


//- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
//    CLLocationCoordinate2D userCoordinate = userLocation.location.coordinate;
//
//    for(int i = 1; i<=5;i++){
//        CGFloat latDelta = rand()*.035/RAND_MAX -.02;
//        CGFloat longDelta = rand()*.03/RAND_MAX -.015;
//
//        CLLocationCoordinate2D newCoord = { userCoordinate.latitude + latDelta, userCoordinate.longitude + longDelta };
//        
//        MKPointAnnotation *anotationPoint = [[MKPointAnnotation alloc] init];
//        anotationPoint.coordinate = newCoord;
//        anotationPoint.title = @"KASS";
//        anotationPoint.subtitle = @"KASS ROCKS";
//        [currentMap addAnnotation:anotationPoint];
//    }
//}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
    
  [ViewHelper buildBackButton:self.backButton];
  VariableStore.sharedInstance.itemToShowOnMap ? [self loadMapSingleItem] : [self loadMultipleItems];
}

- (void)viewDidUnload
{
    [self setCurrentMap:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    VariableStore.sharedInstance.itemToShowOnMap = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
