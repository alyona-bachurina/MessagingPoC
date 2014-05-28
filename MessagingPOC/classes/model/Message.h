//
//  Created by grizzly on 1/7/14.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * recipientId;
@property (nonatomic, retain) NSNumber * senderId;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSNumber * delayed;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSMutableDictionary * customParameters;

@end