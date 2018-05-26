//
//  GPSLocationModel.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/22/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"
@interface GPSLocationModel : BaseEntity

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *altitude;
@property (strong, nonatomic) NSString *heading;
@property (strong, nonatomic) NSString *accuracy;
@property (strong, nonatomic) NSString *speed;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *altitudeAccuracy;
@property (strong, nonatomic) NSString *rapporrverison;
@property (strong, nonatomic) NSString *platform;

@property (strong, nonatomic) NSString *msgId;
@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *host;

- (id)initWithDictionary:(NSDictionary *) responseData;


@end
