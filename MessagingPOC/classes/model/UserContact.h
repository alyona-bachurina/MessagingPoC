//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;


@interface UserContact : NSManagedObject

@property (nonatomic, retain) User * user;
@property (nonatomic, retain) User * contact;
@property (nonatomic, retain) NSNumber * online;
@property (nonatomic, retain) NSNumber * pending;

-(UIImage*)getStatusImage;
@end