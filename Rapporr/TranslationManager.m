//
//  TranslationManager.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/30/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "TranslationManager.h"

@implementation TranslationManager

+ (FGTranslator *)translator {
    FGTranslator *translator = [[FGTranslator alloc] initWithGoogleAPIKey:@"AIzaSyA2vQ33UkuiAgOGn2R2nHxlPgKbJgtw1MI"];
    
    return translator;
}


@end
