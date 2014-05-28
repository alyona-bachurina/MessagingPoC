//
//  Store.h
//
//  Created by Sam Oakley on 10/07/2013.
//  Copyright (c) 2013 Sam Oakley. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "DataStore.h"

/**
 This class manages the Core Data setup and initialisation for an application. The model is automatically loaed from the bundle, and lightweight migration is enabled.
 
 Best practice would be to create an SJODataStore as a property on your appDelegate, then pass this to the view controllers as needed.
 */
@interface SJODataStore : NSObject <DataStore>

@end
