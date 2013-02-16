//
//  ViewController.m
//  MapTest
//
//  Created by Zushi Tatsuya on 2013/01/16.
//  Copyright (c) 2013年 griffin_stewie. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h> 

@interface SamplePlace : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, copy) NSDictionary *addressDictionary;
@property (nonatomic, copy, readonly) NSString *escapedName;
@end

@implementation SamplePlace
- (NSString *)escapedName
{
    NSString *escapedPlaceName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                       (CFStringRef)self.name,
                                                                                                       NULL,
                                                                                                       CFSTR(":/?=,!$&'()*+;[]@#"),
                                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return escapedPlaceName;
}
@end


@interface ViewController ()
@property (nonatomic, strong) SamplePlace *place;
@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _place = [[SamplePlace alloc] init];
        _place.latitude = 35.710036;
        _place.longitude = 139.810638;
        _place.name = @"東京スカイツリー";
        _place.addressDictionary  = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"日本", kABPersonAddressCountryKey,
                                    @"東京都", kABPersonAddressStateKey,
                                    @"墨田区", kABPersonAddressCityKey,
                                    @"押上１丁目１−２", kABPersonAddressStreetKey,
                                    @"131-0045", kABPersonAddressZIPKey,
                                    @"jp", kABPersonAddressCountryCodeKey,
                                    nil];
    }
    return self;
}

- (IBAction)appleMapApp:(id)sender
{    
    /**
     MKMapItem が使えるか確認し、使える場合はそれを利用（事実上 iOS 6 以前か以降かの判定）
     使えない場合（事実上 iOS 6.x 以前）の場合は昔からの挙動
     */
    Class itemClass = [MKMapItem class];
    if (itemClass) {
        /// MKPlacemark を作る
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.place.latitude, self.place.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:self.place.addressDictionary];
        
        /// MKPlacemark から MKMapItem を作る
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = self.place.name;
        
        /// Apple Map.app に渡すオプションを準備
        /// Span を指定して Map 表示時の拡大率を調整
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 250, 250);
        MKCoordinateSpan span = region.span;
        
        /// Apple Map.app を開く
        BOOL result = [item openInMapsWithLaunchOptions:@{
                             MKLaunchOptionsMapSpanKey : [NSValue valueWithMKCoordinateSpan:span],
                           MKLaunchOptionsMapCenterKey : [NSValue valueWithMKCoordinate:coordinate]
                       }];
        
        if (result == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Apple Map.app を開けませんでした"
                                                           delegate:nil
                                                  cancelButtonTitle:@"閉じる"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f&q=%@", self.place.latitude, self.place.longitude, self.place.escapedName];
        NSURL *URL = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (IBAction)googleMapApp:(id)sender
{
    /**
     明示的に Google Map.app でひらく
     */
    
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f(%@)", self.place.latitude, self.place.longitude, self.place.escapedName];
    NSURL *URL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Google Map.app がインストールされていません"
                                                       delegate:nil
                                              cancelButtonTitle:@"閉じる"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
@end
