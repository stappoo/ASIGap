//
//  ASIGap.h
//
//  Created by Steve Noyce on 6/22/10.
//  Copyright 2010 Stappoo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"

@interface ASIGap : PhoneGapCommand {	
}

- (void) submitForm:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
