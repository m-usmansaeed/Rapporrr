//
//  MKMapView+ZoomLevel.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

-(double) getZoomLevel;


@end
