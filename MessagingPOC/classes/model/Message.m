//
//  Created by grizzly on 1/7/14.
//


#import "Message.h"
#import "UserContact.h"
#import "CallRecord.h"


@implementation Message {

}

@dynamic id;
@dynamic text;
@dynamic recipientId;
@dynamic senderId;
@dynamic datetime;
@dynamic delayed;
@dynamic data;
@dynamic read;
//@synthesize customParameters;


- (NSMutableDictionary *)customParameters {
    NSMutableDictionary *customParameters = nil;
    if(self.data){
        NSMutableDictionary * rootObject  = [NSKeyedUnarchiver unarchiveObjectWithData: self.data];
        customParameters = [rootObject objectForKey:@"customParameters"];
        if(!customParameters){
            customParameters = [NSMutableDictionary dictionary];
        }
    }
    return customParameters;
}

- (void)setCustomParameters:(NSMutableDictionary *)customParameters {
    NSMutableDictionary * rootObject = [NSMutableDictionary dictionary];
    if (customParameters){
        [rootObject setObject:customParameters forKey:@"customParameters"];
        self.data= [NSKeyedArchiver archivedDataWithRootObject:rootObject];
    }
}


@end

