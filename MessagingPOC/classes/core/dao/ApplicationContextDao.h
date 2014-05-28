//
//  Created by grizzly on 1/4/14.
//


#import <Foundation/Foundation.h>

@class ApplicationContext;
@class User;

@protocol ApplicationContextDao <NSObject>
- (ApplicationContext *)getApplicationContextCreateIfNeed;

- (void)updateCurrentUser:(User *)user andPassword:(NSString *)password;
@end