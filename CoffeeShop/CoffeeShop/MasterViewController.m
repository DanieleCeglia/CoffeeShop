//
//  MasterViewController.m
//  CoffeeShop
//
//  Created by Daniele Ceglia on 10/10/13.
//  Copyright (c) 2013 Relifeit (Daniele Ceglia). All rights reserved.
//

#import "MasterViewController.h"
#import <RestKit/RestKit.h>
#import "Venue.h"

#define kCLIENTID "GGHC2ZDRME511ZY4NEUK4CN5IKIYE3K55YTX2OWW5HDSMIIZ"
#define kCLIENTSECRET "YO3G2Q0DZEYHWMSXUW41UBYV3TUIHZMW54CN0G2MQI34TZD1"

/*
 MIGRAZIONE RESTKIT da 0.10.x a 0.20.0 vedere: https://github.com/RestKit/RestKit/wiki/Upgrading-from-v0.10.x-to-v0.20.0
*/

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    
    
    /* DEFINIZIONE URL DEL WEBSERVICE REST */
    
    // -- questa -- RKURL *baseURL = [RKURL URLWithBaseURLString:@"https://api.Foursquare.com/v2"];
    // -- più questa -- RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.Foursquare.com/v2"]]; // -- diventa questa! --
    
    // -- questa non serve più -- objectManager.client.baseURL = baseURL;
    NSLog(@"objectManager.HTTPClient.baseURL: %@", objectManager.HTTPClient.baseURL); // -- perché c'è l'ha già! --
    
    
    
    /* MAPPATURA JSON CON IL NOSTRO OGGETTO DEL MODELLO */
    
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]]; // -- questa rimane uguale --
    
    // -- questa... -- [venueMapping mapKeyPathsToAttributes:@"name", @"name", nil];
    [venueMapping addAttributeMappingsFromDictionary:@{@"name" : @"name"}]; // -- ... diventa così! --
    
    //[objectManager.mappingProvider setMapping:venueMapping forKeyPath:@"response.venues"];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.venues" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [self sendRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - Metodi privati

- (void)sendRequest
{
    NSString *latLon = @"37.33,-122.03";
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams;
    queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll", clientID, @"client_id", clientSecret, @"client_secret", @"coffee", @"query", @"20120602", @"v", nil];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    //RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/venues/search" queryParameters:queryParams];
    //[objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
    
    [objectManager getObjectsAtPath:@"https://api.foursquare.com/v2/venues/search"
                         parameters:queryParams
                            success:^(RKObjectRequestOperation * operaton, RKMappingResult *mappingResult)
                                    {
                                        NSLog(@"success: mappings: %@", mappingResult);
                                        /*NSArray *result = [mappingResult array];
                                        cafeArray = [mappingResult array];
                                        for (Venue *item in result)
                                        {
                                            NSLog(@"name=%@",item.name);
                                            NSLog(@"name=%@",item.location.distance);
                                        }
                                        [self.tableView reloadData];*/
                                    }
                            failure:^(RKObjectRequestOperation * operaton, NSError * error)
                                    {
                                        NSLog (@"failure: operation: %@ \n\nerror: %@", operaton, error);
                                    }];
}

@end
