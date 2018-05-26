//
//  GPSLocationModel.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/22/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "GPSLocationModel.h"

@implementation GPSLocationModel

- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    
    if (self) {
        
        NSDictionary *gpsDict = [responseData objectForKey:@"gps"];
        
        self.latitude = [self validStringForObject:gpsDict[@"latitude"]];
        self.longitude =[self validStringForObject:gpsDict[@"longitude"]];
        self.timestamp = [self validStringForObject:gpsDict[@"timestamp"]];
        self.altitude =[self validStringForObject:gpsDict[@"altitude"]];
        self.heading = [self validStringForObject:gpsDict[@"heading"]];
        self.accuracy =[self validStringForObject:gpsDict[@"accuracy"]];
        self.speed = [self validStringForObject:gpsDict[@"speed"]];
        self.titleStr =[self validStringForObject:responseData[@"title"]];
    }
    
    return self;
}

@end
