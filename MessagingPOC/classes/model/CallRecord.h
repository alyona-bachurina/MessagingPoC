//
//  Created by grizzly on 1/10/14.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@class UserContact;


@interface CallRecord : NSManagedObject
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * recipientId;
@property (nonatomic, retain) NSNumber * callerId;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;

@property (nonatomic, retain) UserContact * userContact;
@property (nonatomic, retain, readonly) User * recipient;
@property (nonatomic, retain, readonly) User * caller;


@end