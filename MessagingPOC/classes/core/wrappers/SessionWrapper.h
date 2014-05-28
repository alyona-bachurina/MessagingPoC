//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>

typedef void (^StartSessionCompleteBlock)(NSError* error);
typedef void (^DestroySessionCompleteBlock)(NSError* error);

@protocol SessionWrapper <NSObject>
- (void) startSessionWithCompleteBlock:(StartSessionCompleteBlock) completeBlock;
- (void) startSessionWithLogin:(NSString*)login password:(NSString*) password completeBlock:(StartSessionCompleteBlock) completeBlock;

- (void)destroySession:(StartSessionCompleteBlock)pFunction;
@end