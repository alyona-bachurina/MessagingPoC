//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * id;
@end