//
//  Created by Alyona on 10/23/13.
//


#import <Foundation/Foundation.h>

@class EKObjectMapping;
@class EKManagedObjectMapping;

@protocol Mappable <NSObject>
+(NSString*) externalEntityName;
+(NSString*) entityName;
+(EKManagedObjectMapping *)objectMapping;
@optional
+(NSString*)externalArrayEntitiesName;
@end