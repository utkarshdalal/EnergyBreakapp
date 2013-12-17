//
//  EnergyBreakappViewController.m
//  EnergyBreakapp
//
//  Created by Class Account on 10/10/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import "EnergyBreakappViewController.h"

@interface EnergyBreakappViewController ()

@end

@implementation EnergyBreakappViewController
@synthesize currentDistribution;
@synthesize batteryView;
@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (![standardUserDefaults objectForKey:@"totalPercentage"]) {
        totalCoalPercentage = 0.0;
        totalGasPercentage = 0.0;
        totalHydroPercentage = 0.0;
        totalNuclearPercentage = 0.0;
        totalOilPercentage = 0.0;
        totalRenewablePercentage = 0.0;
        totalOptOutPercentage = 0.0;
        totalPercentage = 0.0;
        optOut = NO;
    }
    else
    {
        totalCoalPercentage = [standardUserDefaults doubleForKey:@"totalCoal"];
        totalGasPercentage = [standardUserDefaults doubleForKey:@"totalGas"];
        totalHydroPercentage = [standardUserDefaults doubleForKey:@"totalHydro"];
        totalNuclearPercentage = [standardUserDefaults doubleForKey:@"totalNuclear"];
        totalOilPercentage = [standardUserDefaults doubleForKey:@"totalOil"];
        totalRenewablePercentage = [standardUserDefaults doubleForKey:@"totalRenewable"];
        totalOptOutPercentage = [standardUserDefaults doubleForKey:@"totalOptOut"];
        totalPercentage = [standardUserDefaults doubleForKey:@"totalPercentage"];
        startCharge = [standardUserDefaults doubleForKey:@"startCharge"];
        optOut = [standardUserDefaults boolForKey:@"optOut"];
    }
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChange:)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
    
    isCharging = YES;
    
    //Adding swipe gesture recognisers
    //The following code taken from http://www.altinkonline.nl/tutorials/xcode/gestures/swipe-gesture-for-ios-apps/
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    //Uncomment the following lines and delete the one before this comment when you want the phone to check if it is charging before updating the location.
    /*if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)
    {
        isCharging = YES;
    }*/
    
    
    
    NSLog(@"View finished loading");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Swiped left");
    if (currentDistribution != nil && [currentDistribution valueForKey:@"nextDistribution"] != nil) {
        currentDistribution = [currentDistribution valueForKey:@"nextDistribution"];
        int zip = [[currentDistribution valueForKey:@"zip"] integerValue];
        distribution = [[EnergyDistribution alloc] initWithZipCode:zip];
        [self setPercentages];
        NSString *currentCity = [currentDistribution valueForKey:@"city"];
        NSString *currentState = [currentDistribution valueForKey:@"state"];
        NSDate *currentDate = [currentDistribution valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];
        _locationText.textAlignment = NSTextAlignmentCenter;
        NSString *cityAndState = [NSString stringWithFormat: @"%@, %@", currentCity, currentState];
        [_locationText setText:cityAndState];
        [_dateText setText:formattedDateString];
    }
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Swiped right");
    if (currentDistribution != nil && [currentDistribution valueForKey:@"previousDistribution"] != nil) {
        currentDistribution = [currentDistribution valueForKey:@"previousDistribution"];
        int zip = [[currentDistribution valueForKey:@"zip"] integerValue];
        NSLog(@"Zip coming out is %i", ([[currentDistribution valueForKey:@"zip"] integerValue]));
        distribution = [[EnergyDistribution alloc] initWithZipCode:zip];
        [self setPercentages];
        NSString *currentCity = [currentDistribution valueForKey:@"city"];
        NSString *currentState = [currentDistribution valueForKey:@"state"];
        NSDate *currentDate = [currentDistribution valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];
        NSString *cityAndState = [NSString stringWithFormat: @"%@, %@", currentCity, currentState];
        _locationText.textAlignment = NSTextAlignmentCenter;
        _dateText.textAlignment = NSTextAlignmentCenter;
        [_locationText setText:cityAndState];
        [_dateText setText:formattedDateString];
    }
}

- (void)batteryStateDidChange:(NSNotification *)notification {
    if (([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)) {
        [locationManager startUpdatingLocation];
        _startDate = [NSDate date];
        _startChargePercentage = [[UIDevice currentDevice] batteryLevel];
        isCharging = YES;
        if (optOut) {
            NSLog(@"Device is charging in opt-out mode");
            distribution = [[EnergyDistribution alloc] initOptOutMode];
            [self setPercentages];
        }
        else{
            NSLog(@"Device is charging");
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            [locationManager startUpdatingLocation];
        }
        //DON'T FORGET ABOUT OPT-OUT CHARGE!
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setDouble:currentCoalPercentage forKey:@"currentCoal"];
        [standardUserDefaults setDouble:currentGasPercentage forKey:@"currentGas"];
        [standardUserDefaults setDouble:currentHydroPercentage forKey:@"currentHyrdo"];
        [standardUserDefaults setDouble:currentNuclearPercentage forKey:@"currentNuclear"];
        [standardUserDefaults setDouble:currentOilPercentage forKey:@"currentOil"];
        [standardUserDefaults setDouble:currentRenewablePercentage forKey:@"currentRenewable"];
        [standardUserDefaults setDouble:currentOptOutPercentage forKey:@"currentOptOut"];
        [standardUserDefaults setDouble:currentTotalPercentage forKey:@"currentTotal"];
        [standardUserDefaults setDouble:_startChargePercentage forKey:@"startCharge"];
        [standardUserDefaults synchronize];
        UIAlertView *chargingAlert = [[UIAlertView alloc] initWithTitle:@"Charging" message:@"Your device is now charging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [chargingAlert show];
    }
    else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        _endDate = [NSDate date];
        _endChargePercentage = [[UIDevice currentDevice] batteryLevel];
        isCharging = NO;
        [_optOutButton setTitle:@"Opt out" forState:UIControlStateNormal];
        optOut = NO;
        _secondsSpentCharging = [_endDate timeIntervalSinceDate:_startDate];
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        currentCoalPercentage = [standardUserDefaults doubleForKey:@"currentCoal"];
        currentGasPercentage = [standardUserDefaults doubleForKey:@"currentGas"];
        currentHydroPercentage = [standardUserDefaults doubleForKey:@"currentHydro"];
        currentNuclearPercentage = [standardUserDefaults doubleForKey:@"currentNuclear"];
        currentOilPercentage = [standardUserDefaults doubleForKey:@"currentOil"];
        currentRenewablePercentage = [standardUserDefaults doubleForKey:@"currentRenewable"];
        currentOptOutPercentage = [standardUserDefaults doubleForKey:@"currentOptOut"];
        currentTotalPercentage = [standardUserDefaults doubleForKey:@"currentTotal"];
        _percentCharged = _endChargePercentage - [standardUserDefaults doubleForKey:@"startCharge"];
        
        [standardUserDefaults setDouble:totalCoalPercentage+currentCoalPercentage*_percentCharged forKey:@"totalCoal"];
        [standardUserDefaults setDouble:totalGasPercentage+currentGasPercentage*_percentCharged forKey:@"totalGas"];
        [standardUserDefaults setDouble:totalHydroPercentage+currentHydroPercentage*_percentCharged forKey:@"totalHydro"];
        [standardUserDefaults setDouble:totalNuclearPercentage+currentNuclearPercentage*_percentCharged forKey:@"totalNuclear"];
        [standardUserDefaults setDouble:totalOilPercentage+currentOilPercentage*_percentCharged forKey:@"totalOil"];
        [standardUserDefaults setDouble:totalRenewablePercentage+currentRenewablePercentage*_percentCharged forKey:@"totalRenewable"];
        [standardUserDefaults setDouble:totalOptOutPercentage+currentOptOutPercentage*_percentCharged forKey:@"totalOptOut"];
        [standardUserDefaults setDouble:totalPercentage+currentTotalPercentage*_percentCharged forKey:@"totalPercentage"];
        [standardUserDefaults synchronize];
        UIAlertView *unpluggedAlert = [[UIAlertView alloc] initWithTitle:@"Unplugged" message:@"Your device is no longer charging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [unpluggedAlert show];
    }
}

- (IBAction)updateLocation:(id)sender{
    NSLog(@"Update Location button pressed");
    _locationText.text = @"";
    _dateText.text = @"";
    if (optOut)
    {
        distribution = [[EnergyDistribution alloc] initOptOutMode];
        [self setPercentages];
    }
    else if (isCharging)
    {
        NSLog(@"Device is charging");
        locationManager.delegate = self;
        
        //CHANGE THE ACCURACY!
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //CHANGE THE UPDATE FREQUENCY!
        [locationManager startUpdatingLocation];
    }
    /*locationManager.delegate = self;
    
    //CHANGE THE ACCURACY!
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //CHANGE THE UPDATE FREQUENCY!
    [locationManager startUpdatingLocation];*/
    else{
        NSLog(@"Device is not charging");
    }
}


/* Unclear event here - what if user presses opt out, plugs in, then presses opt out before unplugging? The opt out charge will not be recorded. Look into this. */

- (IBAction)OptOut:(id)sender {
    if (optOut) {
        [locationManager startUpdatingLocation];
        optOut = NO;
        NSLog(@"Opt in button pressed");
        [(UIButton *)sender setTitle:@"Opt out" forState:UIControlStateNormal];
    }
    else{
        distribution = [[EnergyDistribution alloc] initOptOutMode];
        [self setPercentages];
        optOut = YES;
        NSLog(@"Opt out button pressed");
        [(UIButton *)sender setTitle:@"Opt in" forState:UIControlStateNormal];
    }
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:optOut forKey:@"optOut"];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSLog(@"Updated to location: %@", currentLocation);
    
    if (currentLocation != nil)
    {
        //_LocationText.text = [NSString stringWithFormat: @"Longitude: %.8f Latitude: %.8f", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
    }
    
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Reverse geocoding");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0){
            placemark = [placemarks lastObject];
            //_LocationText.text = [placemark postalCode];
            distribution = [[EnergyDistribution alloc] initWithZipCode:[[placemark postalCode] intValue]];
            [self setPercentages];
            NSManagedObjectContext *context;
            EnergyBreakappAppDelegate *appDelegate = (EnergyBreakappAppDelegate*) [[UIApplication sharedApplication] delegate];
            context = appDelegate.managedObjectContext;
            
            
            NSError *error;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"EnergyDistribution" inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
            
            NSManagedObject *last = [fetchedObjects lastObject];
            NSManagedObject *energyDistribution = [NSEntityDescription
                                               insertNewObjectForEntityForName:@"EnergyDistribution"
                                               inManagedObjectContext:context];
            [energyDistribution setValue:[NSNumber numberWithInt:[[placemark postalCode] integerValue]] forKey:@"zip"];
            NSLog(@"Zip put in is %@", [NSNumber numberWithInt:[[placemark postalCode] integerValue]]);
            [energyDistribution setValue:[NSDate date] forKey:@"date"];
            [energyDistribution setValue:[placemark locality] forKey:@"city"];
            [energyDistribution setValue:[placemark administrativeArea] forKey:@"state"];
            
            if (last != nil) {
                [energyDistribution setValue:last forKey:@"previousDistribution"];
                [last setValue:energyDistribution forKey:@"nextDistribution"];
            }
            
            currentDistribution = energyDistribution;
            
            if (![context save:&error]) {
                NSLog(@"Couldn't save: %@", [error localizedDescription]);
            }
        }        
        else{
            NSLog(@"Error!");
        }
    }];
}

-(void) setPercentages
{
    currentCoalPercentage = [distribution coalPercentage];
    currentOilPercentage = [distribution oilPercentage];
    currentGasPercentage = [distribution gasPercentage];
    currentNuclearPercentage = [distribution nuclearPercentage];
    currentHydroPercentage = [distribution hydroPercentage];
    currentRenewablePercentage = [distribution renewablePercentage];
    currentOtherFossilPercentage = [distribution otherFossilPercentage];
    currentGeothermalPercentage = [distribution geothermalPercentage];
    currentSolarPercentage = [distribution solarPercentage];
    currentWindPercentage = [distribution windPercentage];
    currentBiomassPercentage = [distribution biomassPercentage];
    currentOptOutPercentage = [distribution optOutPercentage];
    currentTotalPercentage = [distribution totalPercentages];
    [batteryView setDistributionForCoal:currentCoalPercentage Oil:currentOilPercentage Gas:currentGasPercentage Nuclear:currentNuclearPercentage Hydro:currentHydroPercentage Renewable:currentRenewablePercentage OtherFossil:currentOtherFossilPercentage Geothermal:currentGeothermalPercentage Wind:currentWindPercentage Solar:currentSolarPercentage Biomass:currentBiomassPercentage OptOut:currentOptOutPercentage AndTotal:currentTotalPercentage];
}
@end
