//
//  Venue.h
//  CoffeeShop
//
//  Created by Daniele Ceglia on 10/10/13.
//  Copyright (c) 2013 Relifeit (Daniele Ceglia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Venue : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Location *location;

@end
