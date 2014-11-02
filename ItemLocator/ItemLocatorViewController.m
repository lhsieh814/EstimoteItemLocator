//
//  ItemLocatorViewController.m
//  ItemLocator
//
//  Created by Lena Hsieh on 2014-11-01.
//  Copyright (c) 2014 lhsieh. All rights reserved.
//

#import "ItemLocatorViewController.h"
#import "ESTBeaconManager.h"

/*
 * Maximum distance (in meters) from beacon for which, the dot will be visible on screen.
 */
#define MAX_DISTANCE 20
#define TOP_MARGIN   150

@interface ItemLocatorViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, copy) void (^completion)(ESTBeacon *);

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *positionDot1;
@property (nonatomic, strong) UIImageView *positionDot2;
@property (nonatomic, strong) UIImageView *positionDot3;
@property (nonatomic, strong) UIImageView *customer;

@end

@implementation ItemLocatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.region];
//    [self.beaconManager requestAlwaysAuthorization];
//    [self.beaconManager startRangingBeaconsInRegion:self.region];
//    [self startRangingBeacons];

    // UI setup
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"distance_bkg"]];
    self.backgroundImage.frame = [UIScreen mainScreen].bounds;
    self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
//    [self.view addSubview:self.backgroundImage];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *beaconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beacon"]];
    [beaconImageView setCenter:CGPointMake(self.view.center.x, 100)];
//    [self.view addSubview:beaconImageView];
    
    self.positionDot1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot1 setCenter:CGPointMake(self.view.frame.size.width/2, self.view.center.x)];
    [self.view addSubview:self.positionDot1];
    
    self.positionDot2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot2 setCenter:CGPointMake(self.view.frame.size.width/6, self.view.center.x)];
    [self.view addSubview:self.positionDot2];
    
    self.positionDot3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot3 setCenter:CGPointMake(self.view.frame.size.width/6*5, self.view.center.x)];
    [self.view addSubview:self.positionDot3];
    
    self.customer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.customer setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 30)];
    [self.view addSubview:self.customer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            [self.beaconManager startRangingBeaconsInRegion:self.region];
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            [self.beaconManager requestAlwaysAuthorization];
        }
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"sss");
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self startRangingBeacons];
}

#pragma mark - ESTBeaconManager delegate
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSLog(@"beaconManager - didRangeBeacons");
    self.beaconsArray = beacons;
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSLog(@"beaconManager - didDiscoverBeacons %lul", (unsigned long)beacons.count);
    self.beaconsArray = beacons;
    if (self.beaconsArray.count == 3) {
        ESTBeacon *beacon1 = [self.beaconsArray objectAtIndex:0];
        ESTBeacon *beacon2 = [self.beaconsArray objectAtIndex:1];
        ESTBeacon *beacon3 = [self.beaconsArray objectAtIndex:2];

        NSLog(@"\n1: %.2f , %d \n2: %.2f , %d \n3: %.2f , %d\n", [beacon1.distance floatValue], [beacon1 rssi], [beacon2.distance floatValue], [beacon2 rssi], [beacon3.distance floatValue], [beacon3 rssi]);
        
        [self updatePositionForDistance:[beacon1 rssi]/-100.0f forBeacon:0];
        [self updatePositionForDistance:[beacon2 rssi]/-100.0f forBeacon:1];
        [self updatePositionForDistance:[beacon3 rssi]/-100.0f forBeacon:2];
    }
}

// Update UI
- (void)updatePositionForDistance:(float)distance forBeacon:(int)index
{
    NSLog(@"distance for beacon%d: %f", index, distance);
    
    float step = (self.view.frame.size.height - TOP_MARGIN) / MAX_DISTANCE;
    
    int newY = TOP_MARGIN + (distance * step);
    NSLog(@"%d", newY);
//    switch (index) {
//        case 0:
//            [self.positionDot1 setCenter:CGPointMake(self.positionDot1.frame.origin.x, self.positionDot1.frame.origin.x)];
//            break;
//        case 1:
//            [self.positionDot2 setCenter:CGPointMake(self.positionDot2.frame.origin.x, self.positionDot2.frame.origin.x)];
//        case 2:
//            [self.positionDot3 setCenter:CGPointMake(self.positionDot3.frame.origin.x, self.positionDot3.frame.origin.x)];
//        default:
//            break;
//    }
}

@end
