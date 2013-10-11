//
//  VenueCell.h
//  CoffeeShop
//
//  Created by Daniele Ceglia on 11/10/13.
//  Copyright (c) 2013 Relifeit (Daniele Ceglia). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkinsLabel;

@end
