//
//  JasonMapComponent.m
//  Jasonette
//
//  Copyright © 2016 gliechtenstein. All rights reserved.
//
#import "JasonMapComponent.h"

@implementation JasonMapComponent
+ (UIView *)build:(NSDictionary *)json withOptions:(NSDictionary *)options{
    MKMapView *component = [[MKMapView alloc] init];
    [component setShowsUserLocation:YES];
    
    // Map Style
    NSDictionary *style = json[@"style"];
    component.mapType = MKMapTypeStandard;
    if(style && style[@"type"]){
        if([style[@"type"] isEqualToString:@"satellite"]){
            component.mapType = MKMapTypeSatellite;
        } else if([style[@"type"] isEqualToString:@"hybrid"]){
            component.mapType = MKMapTypeHybrid;
        } else if([style[@"type"] isEqualToString:@"hybrid_flyover"]){
            component.mapType = MKMapTypeHybridFlyover;
        } else if([style[@"type"] isEqualToString:@"satellite_flyover"]){
            component.mapType = MKMapTypeSatelliteFlyover;
        }
    }
    
    // Map Region
    // 1. If 'coord' exists, set the center. Otherwise, use the current location
    // 2. use 'width' and 'height' to create the visible area
    NSDictionary *region = json[@"region"];
    if(region){
        component.payload = [@{@"region": region} mutableCopy];
    }
    [self setRegion: component];
    
    // Pins
    if(json[@"pins"]){
        [self addPins: json[@"pins"] toMapView: component];
    }
    
    // Apply Common Style
    [self stylize:json component:component];
    
    return component;
}
+ (void)addPins: (NSArray *)pins toMapView: (MKMapView *)mapView{
    for(int i = 0 ; i < pins.count ; i++){
        NSDictionary *pin = pins[i];
        if(pin[@"coord"]){
            CLLocation *coord = [self pinFromCoordinateString:pin[@"coord"]];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            
            NSString *image = pin[@"image"];
            if(image){
                // todo
            } else {
                NSString *title = pin[@"title"];
                if(!title){
                    title = @"";
                }
                NSString *description = pin[@"description"];
                if(!description){
                    description = @"";
                }
                [annotation setTitle:title];
                [annotation setSubtitle:description];
            }
            [annotation setCoordinate:coord.coordinate];
            [mapView addAnnotation:annotation];
            
            if(pin[@"style"]){
                if(pin[@"style"][@"selected"]){
                    [mapView selectAnnotation:annotation animated:NO];
                }
            }
            
        }
    }
}
/*
+ (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self setRegion:mapView];
}
 */
+ (CLLocation *)pinFromCoordinateString: (NSString *)coord{
    NSArray *coord_array = [coord componentsSeparatedByString:@","];
    CLLocation *location = nil;
    if(coord_array.count == 2){
        CLLocationDegrees latitude;
        CLLocationDegrees longitude;
        latitude = [coord_array[0] doubleValue];
        longitude = [coord_array[1] doubleValue];
        location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    }
    return location;
}
+ (void)setRegion:(MKMapView *)mapView{
    
    // Default location is current location
    CLLocation *location;
    
    NSDictionary *region = mapView.payload[@"region"];
    
    // override with data
    if(region && region[@"coord"]){
        location = [self pinFromCoordinateString: region[@"coord"]];
    }
    
    if(location){
        
        CLLocationDistance width = 1000;
        CLLocationDistance height = 1000;
        if(region[@"width"]){
            width = [region[@"width"] doubleValue];
        }
        if(region[@"height"]){
            height = [region[@"height"] doubleValue];
        }
        
        if(region[@"width"] && !region[@"height"]){
            height = width;
        } else if(!region[@"width"] && region[@"height"]){
            width = height;
        }
        
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance ( location.coordinate, width, height);
        [mapView setRegion:r animated:NO];
    }
}


@end
