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

#warning VEDERE QUESTI LINK QUA SOTTO!!!
/*
 TUTORIAL SEGUITO DA: http://www.raywenderlich.com/13097/intro-to-restkit-tutorial
 
 MIGRAZIONE RESTKIT da 0.10.x a 0.20.0 vedere: https://github.com/RestKit/RestKit/wiki/Upgrading-from-v0.10.x-to-v0.20.0
 
 E CODICE GIÀ MEZZO CONVERTITO DA QUALCUNO SU INTERNET: http://madeveloper.blogspot.it/2013/01/ios-restkit-tutorial-code-for-version.html
 (che però è già deprecato su alcuni metodi...)
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
    
    //RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.Foursquare.com/v2"]]; // -- NON diventa semplicemente questa! perché il mapping poi non riesce... --
    
    // -- ... invece il tutto si traduce così!!! --
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com/v2"];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // -- questa non serve più -- objectManager.client.baseURL = baseURL;
    // -- perché c'è l'ha già! --
    //NSLog(@"objectManager.HTTPClient.baseURL: %@", objectManager.HTTPClient.baseURL);
    
    
    
    
    /* MAPPATURA JSON CON GLI OGGETTI DEL MODELLO */
    
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]]; // -- questa rimane uguale ---
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]]; // -- questa rimane uguale --
    
    
    /*** mappatura location ***/
    
    // -- questa -- [locationMapping mapKeyPathsToAttributes:@"address", @"address", @"city", @"city", @"country", @"country", @"crossStreet", @"crossStreet", @"postalCode", @"postalCode", @"state", @"state", @"distance", @"distance", @"lat", @"lat", @"lng", @"lng", nil];
    // -- diventa questa --
    [locationMapping addAttributeMappingsFromDictionary:@{@"address"     : @"address",
                                                          @"city"        : @"city",
                                                          @"country"     : @"country",
                                                          @"crossStreet" : @"crossStreet",
                                                          @"postalCode"  : @"postalCode",
                                                          @"state"       : @"state",
                                                          @"distance"    : @"distance",
                                                          @"lat"         : @"lat",
                                                          @"lng"         : @"lng"}];
    
    // -- questa -- [venueMapping mapRelationship:@"location" withMapping:locationMapping];
    // --  e questa -- [objectManager.mappingProvider setMapping:locationMapping forKeyPath:@"location"];
    // -- diventano questa ---
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    
    /*** mappatura venues ***/
    
    // -- questa -- [venueMapping mapKeyPathsToAttributes:@"name", @"name", nil];
    // -- diventa così! --
    [venueMapping addAttributeMappingsFromDictionary:@{@"name" : @"name"}];
    
    // -- questo --[objectManager.mappingProvider setMapping:venueMapping forKeyPath:@"response.venues"];
    // -- diventa queste due istruzioni qua -- (notare che si scorre l'albero JSON con response.venues per prendere solo la parte riguardante venues...)
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.venues" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor]; // (e notare questo collegamento)
    
    
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

    Venue *venue = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [venue.name length] > 24 ? [venue.name substringToIndex:24] : venue.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0fm", [venue.location.distance floatValue]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    // -- questa -- RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/venues/search" queryParameters:queryParams];
    // -- e questa -- [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
    
    // -- diventano questa! --
    [objectManager getObjectsAtPath:@"https://api.foursquare.com/v2/venues/search"
                         parameters:queryParams
                            success:^(RKObjectRequestOperation *operaton, RKMappingResult *mappingResult)
                                    {
                                        NSLog(@"Mappatura riuscita: %@", mappingResult);
                                        
                                        NSArray *result = [mappingResult array];
                                        _objects = [[mappingResult array] mutableCopy];
                                        
                                        for (Venue *item in result)
                                        {
                                            NSLog(@"name: %@",item.name);
                                            NSLog(@"distance: %@",item.location.distance);
                                        }
                                        
                                        [self.tableView reloadData];
                                    }
                            failure:^(RKObjectRequestOperation *operaton, NSError *error)
                                    {
                                        NSLog (@"Mappattura FALLITA: %@ \n\nErrore: %@", operaton, error);
                                    }];
}

@end
