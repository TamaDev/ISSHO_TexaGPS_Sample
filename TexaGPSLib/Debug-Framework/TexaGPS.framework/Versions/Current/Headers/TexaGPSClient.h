//
//  TexaGPSLib.h
//  TexaGPSLib
//
//  Created by ISSHO on 12/10/29.
//  Copyright (c) 2012年 ISSHO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MKUserLocation+TexaGPS.h"

// GPS data recieve protocol.
@protocol TexaGPSClientDelegate <NSObject>
@optional
- (void)didLoadTexaGPS:(NSDictionary*)rawData;
- (void)didFailTexaGPS;
- (void)willStartTexaGPS;
- (void)didStopTexaGPS;
- (void)didRecieveCommandTexaGPS:(NSString*)commandName;
- (void)didFinishingLookupSuccess:(NSString*)connectedHost;
- (void)didFinishingLookupFail;
- (void)foundTexaGPS:(NSDictionary*)serverInfo;
@end


@interface TexaGPSClient : NSObject
<
NSURLConnectionDelegate,
NSNetServiceBrowserDelegate,NSNetServiceDelegate
>
{
    __block NSDate *airGPSlastRecieveDate_;
    BOOL isLookup_;
    BOOL noBonjourDevices;
    NSMutableData* receivedData;    // concat NSURLConnection received data.
    NSMutableDictionary* bonjourServerDic;  // Bonjour service dictionary.
    NSMutableDictionary* browseDic; // NSNetService host<->IP resolve dictionary.
    NSString* lastTexaHost;         // Connection succellfully IP address.
    NSNetServiceBrowser *texaServiceBrowser;
}

@property (nonatomic, weak) id<TexaGPSClientDelegate> delegate;
@property (nonatomic, strong) NSDate *airGPSlastRecieveDate;    // Recieve raw data
@property (nonatomic, strong) CLLocation *airGPSLocation;       // Remote location value.
@property (nonatomic, strong) CLHeading *airGPSHeading;         // Remote compass value.
@property (nonatomic, readonly) BOOL enableAirGPS;              // TexaGPS status
@property (nonatomic, assign) CGFloat interval;                 // Reload interval.(defaul 1.0sec)
@property (nonatomic, assign) CGFloat lookupInterval;           // Lookup interval.(default 0.25sec)

- (void)lookupTexaGPSService;    // Lookup TexaGPS host.
- (void)stopTexaGPSService;      // Safe terminate.
- (void)chooseTexaGPSHost:(NSString*)hostName;    // Choose several TexaGPS host.
- (void)uploadPreset:(NSString*)zipPath;    // upload preset manifest-zip file.

@end

