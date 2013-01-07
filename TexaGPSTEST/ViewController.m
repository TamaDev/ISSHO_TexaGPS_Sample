//
//  ViewController.m
//  TexaGPSTEST
//
//  Created by ISSHO on 12/10/31.
//  Copyright (c)2012 ISSHO. All rights reserved.
//

#import "ViewController.h"

#define kTexaChoiceActionTag    1001    // Choose TexaGPS host UIActionSheet tag.

@interface ViewController ()

@end

@implementation ViewController

@synthesize mapTestView = mapTestView_;
@synthesize compassImageView = compassImageView_;
@synthesize killButton = killButton_;


- (BOOL)shouldAutorotate
{
    return(YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    compassImageView_.transform = CGAffineTransformIdentity;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if( [CLLocationManager locationServicesEnabled] == YES ){
        locationManager = [[CLLocationManager alloc] init];
    }
    
    // ==== Initialize TexaGPS only 4 line code!! ====
    texaGPS = [[TexaGPSClient alloc] init];
    texaGPS.delegate = self;
    texaGPS.interval = 1.5f;    // Auto recieve interval.
    [texaGPS lookupTexaGPSService]; // Auto connect TexaGPS
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark === CLLocationManager Delegate ===
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations lastObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if( proxyUserLocation != nil ){
            [mapTestView_ removeAnnotation:proxyUserLocation];
            proxyUserLocation = nil;
        }

        if( CLLocationCoordinate2DIsValid(newLocation.coordinate) == YES ){
            // Added user location annotation.
            if( proxyUserLocation != nil ){
                [mapTestView_ removeAnnotation:proxyUserLocation];
                proxyUserLocation = nil;
            }
            proxyUserLocation = [[MKUserLocation alloc] init];
            proxyUserLocation.coordinate = newLocation.coordinate;
            texaGPS.airGPSLocation = newLocation;
            [mapTestView_ addAnnotation:proxyUserLocation];
            
            [UIView animateWithDuration:1.0f animations:^{
                proxyUserLocation.coordinate = newLocation.coordinate;
                [mapTestView_ addAnnotation:proxyUserLocation];
            }];
            
            // Added Ripple annotation.
            if( rippleUserLocation == nil ){
                rippleUserLocation = [[MKUserLocation alloc] init];
                rippleUserLocation.coordinate = newLocation.coordinate;
                rippleUserLocation.title = @"Ripple";
                if( CLLocationCoordinate2DIsValid(rippleUserLocation.coordinate) == YES ){
                    [mapTestView_ addAnnotation:rippleUserLocation];
                }
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    static double oldMapHeading = 0;
    double mapHeading = 0;
     
    if (newHeading.trueHeading >= 0) {
        mapHeading = newHeading.trueHeading;
    }else if (newHeading.magneticHeading >=0){
        mapHeading = newHeading.magneticHeading;
    }else{
        return;
    }

    if( oldMapHeading == mapHeading ){
        return;
    }

    // Compass animation
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGContextRef context = UIGraphicsGetCurrentContext();
        compassImageView_.transform = CGAffineTransformMakeRotation(M_PI*2* (oldMapHeading)/360*(-1));
        
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationDuration:1.0f];
        compassImageView_.transform = CGAffineTransformMakeRotation(M_PI*2* (mapHeading)/360*(-1));
        
        [UIView commitAnimations];
        
        TexaLOG(@"ROTATE MAP FROM:[%f] -> TO:[%f]",oldMapHeading,mapHeading);
        oldMapHeading = mapHeading;
    });
}

#pragma mark === MKMapView Annotation Delegate ===
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"Pin";
    MKAnnotationView *annotationView = nil;

    if (annotation == mapTestView_.userLocation) {
        return nil;
	}
    
    // Draw fake user location annotation and ripple effect.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        const CGFloat airGPSAccuracyMax = 256.0f; // over limit.
        const CGFloat airGPSAccuracySteps = 50.0f; // hue threshould.
        
        CGFloat accuracyLevel = texaGPS.airGPSLocation.horizontalAccuracy;
        if( accuracyLevel > airGPSAccuracyMax ){
            accuracyLevel = airGPSAccuracyMax;
        // reset when the accracy is less than blue-hue value.
        }else if( accuracyLevel < airGPSAccuracySteps ){
            accuracyLevel = airGPSAccuracySteps;
        }
        // GPS accuracy threshould value sample.
/*
        accuracyLevel = 10.0f; // Excellent!
        accuracyLevel = 50.0f; // Great!
        accuracyLevel = 150.0f; // Ordinally
        accuracyLevel = 300.0f; // Poor
        accuracyLevel = 450.0f; // Dust
        accuracyLevel = 600.0f; // Ashes!
*/
        CGFloat hueValue = 0.55f - ((accuracyLevel/airGPSAccuracySteps/10) * 0.5f);
        TexaLOG(@"HUE:[%f]",hueValue);
        
#ifdef COLOR_LOOP_DEBUG // HUE loop test code.
         static int levelStep = 0;
         CGFloat testAccuracylevel = accuracyLevel + (airGPSAccuracySteps * levelStep++);
         if( testAccuracylevel > airGPSAccuracyMax ){
             levelStep = 0;
         }
         hueValue = (testAccuracylevel/airGPSAccuracySteps/10) * 0.5f;
#endif
        
        MKAnnotationView* proxyLocationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        if( texaGPS.enableAirGPS == NO ){
            hueValue = 1.0f;
        }
        
        UIColor* locationColor = [UIColor colorWithHue:hueValue saturation:1.0f brightness:1.0f alpha:0.8f];
        proxyLocationView.annotation = annotation;
        proxyLocationView.canShowCallout = NO;
        
        MKUserLocation* proxyAnnotation = annotation;
        CGFloat effectLevel = 256.0f; // effet range limit. 
        if( accuracyLevel > 0 ){
            if( accuracyLevel < airGPSAccuracySteps ){
                effectLevel = effectLevel / 2.0f;
            }else if( accuracyLevel > effectLevel ){
                accuracyLevel = effectLevel;
            }else if( accuracyLevel <= (effectLevel / 2) ){
                effectLevel = accuracyLevel * 2.0f;
            }
        }
        
        // Ripple animation effect.
        if( [proxyAnnotation.title compare:@"Ripple"] == NSOrderedSame ){
            proxyLocationView.image = [self imageNamed:@"rader-01.png" withColor:locationColor];
            proxyLocationView.alpha = 0.6f;
            proxyLocationView.center = lastLocationView.center;
            proxyLocationView.bounds = CGRectMake(proxyLocationView.frame.size.width/2, proxyLocationView.frame.size.height/2, 0, 0);
            [UIView animateWithDuration:1.6f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 proxyLocationView.alpha = 0.0f;
                                 proxyLocationView.bounds = CGRectMake(0.0f, 0.0f, effectLevel, effectLevel);
                             }completion:^(BOOL finished){
                                 if( rippleUserLocation != nil ){
                                     [mapTestView_ removeAnnotation:rippleUserLocation];
                                     rippleUserLocation = nil;
                                 }
                             }];
        }else{
            proxyLocationView.image = [self imageNamed:@"Landmark2.png" withColor:locationColor];
            lastLocationView = proxyLocationView;
        }
        return(proxyLocationView);
    }
    
    return(annotationView);
}

#pragma mark === TexaGPS Delegate(Optional) ===

- (void)foundTexaGPS:(NSDictionary*)serverInfo
{
    bonjourServerDic = serverInfo;
    
    if( texaChoiceSheet != nil ){
        return;
    }
    
    NSArray* serverNameArray = [serverInfo allKeys];
    texaChoiceSheet = [[UIActionSheet alloc]
                       initWithTitle:NSLocalizedString(@"Choose TexaGPS Devices.",nil)
                       delegate:self
                       cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                       otherButtonTitles:nil];
    
    for (NSString* buttonTitle in serverNameArray) {
        [texaChoiceSheet addButtonWithTitle:buttonTitle];
    }
    texaChoiceSheet.cancelButtonIndex = [texaChoiceSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    texaChoiceSheet.tag = kTexaChoiceActionTag;
    [texaChoiceSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [texaChoiceSheet showInView:self.view];
    });
}

// Receive success and raw data access.
// ==== Please when you use a more sensitive edge code!! ====
- (void)didLoadTexaGPS:(NSDictionary*)rawData
{
    TexaLOG(@"%@[%@]",NSStringFromSelector(_cmd),rawData);
}

// Receive failure.
- (void)didFailTexaGPS
{
    TexaLOG(@"%@",NSStringFromSelector(_cmd));
    [self enableLocalCoreLocation];
}

// TexaGPS start.
- (void)willStartTexaGPS
{
    TexaLOG(@"%@",NSStringFromSelector(_cmd));
    
     // This code is poor! You should move a curerent location code you can recieved it.
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         [self pushCurrentLocation:nil];
     });
}

// Unreachable TexaGPS.
- (void)didFinishingLookupFail
{
    TexaLOG(@"%@",NSStringFromSelector(_cmd));
    [self enableLocalCoreLocation];
}

// TexaGPS stop.
- (void)didStopTexaGPS
{
    TexaLOG(@"%@",NSStringFromSelector(_cmd));
    [self enableLocalCoreLocation];
}

// Remote command receive delegate.
- (void)didRecieveCommandTexaGPS:(NSString*)commandName
{
    TexaLOG(@"%@:[%@]",NSStringFromSelector(_cmd),commandName);
    if( [commandName compare:@"ISSHO.RouteHD.CurrentLocation"] == NSOrderedSame ){
        [self pushCurrentLocation:nil];
        
    }else if( [commandName compare:@"ISSHO.RouteHD.ZoomIn"] == NSOrderedSame ){
        [self pushZoomIn:nil];
        
    }else if( [commandName compare:@"ISSHO.RouteHD.ZoomOut"] == NSOrderedSame ){
        [self pushZoomOut:nil];
        
    }else if( [commandName compare:@"ISSHO.RouteHD.Reroute"] == NSOrderedSame ){
        TexaLOG(@"Sorry! This sample code is not implemented yet.");
    }
}

#pragma mark === IBAction ===
- (IBAction)pushCurrentLocation:(id)sender
{
    if( texaGPS.enableAirGPS == YES ){
        [mapTestView_ setCenterCoordinate:texaGPS.airGPSLocation.coordinate animated:YES];
    }else{
        [mapTestView_ setCenterCoordinate:locationManager.location.coordinate animated:YES];
    }
}

- (IBAction)pushZoomIn:(id)sender
{
    double latDelta = mapTestView_.region.span.latitudeDelta;
    double lonDelta = mapTestView_.region.span.longitudeDelta;
    
    latDelta = latDelta / 3.0f;
    lonDelta = lonDelta / 3.0f;
    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(mapTestView_.centerCoordinate, span);
    [mapTestView_ setRegion:coordinateRegion animated:YES];
}

- (IBAction)pushZoomOut:(id)sender
{
    double latDelta = mapTestView_.region.span.latitudeDelta;
    double lonDelta = mapTestView_.region.span.longitudeDelta;

    latDelta = latDelta * 1.5f;
    lonDelta = lonDelta * 1.5f;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(mapTestView_.centerCoordinate, span);
    [mapTestView_ setRegion:coordinateRegion animated:YES];
}

// Stop or start TexaGPS
- (IBAction)pushTexaGPS:(id)sender
{
    if( texaGPS.enableAirGPS == YES ){
        [self enableLocalCoreLocation];
        
    }else{
        [self enableTexaGPSLocation];
        
    }
}

#pragma mark === Utility ===
// Kill local CoreLocation and start TexaGPS.
- (void)enableTexaGPSLocation
{
    [killButton_ setTitle:@"STOP" forState:UIControlStateNormal];
    texaGPS.delegate = self;
    locationManager.delegate = nil;
    mapTestView_.showsUserLocation = NO;
    mapTestView_.userTrackingMode = MKUserTrackingModeNone;
    [texaGPS lookupTexaGPSService];

}

// Kill TexaGPS annotation and start CoreLocation.
- (void)enableLocalCoreLocation
{
    [killButton_ setTitle:@"START" forState:UIControlStateNormal];
    texaGPS.delegate = nil;
    locationManager.delegate = self;
    [texaGPS stopTexaGPSService];
    [mapTestView_ removeAnnotation:proxyUserLocation];
    mapTestView_.showsUserLocation = YES;
    mapTestView_.userTrackingMode = MKUserTrackingModeFollow;
}

// HUE convert gray scale image
- (UIImage*)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:name];
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return(coloredImg);
}

#pragma mark UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( actionSheet.tag == kTexaChoiceActionTag ){
        if( actionSheet.cancelButtonIndex == buttonIndex ){
            [self enableLocalCoreLocation];
        
        }else{
            NSString* lookupHOST = [actionSheet buttonTitleAtIndex:buttonIndex];
            [texaGPS chooseTexaGPSHost:lookupHOST];
        }
        
        texaChoiceSheet = nil;
    }
}
@end
