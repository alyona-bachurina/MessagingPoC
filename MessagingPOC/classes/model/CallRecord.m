//
//  Created by grizzly on 1/10/14.
//


#import "CallRecord.h"
#import "User.h"
#import "UserContact.h"


@implementation CallRecord {

}


@dynamic id;
@dynamic recipientId;
@dynamic callerId;
@dynamic startTime;
@dynamic endTime;
@dynamic userContact;

- (User *)caller {
    User *result = nil;
    if(self.callerId.integerValue == self.userContact.contact.id.integerValue){
       result = self.userContact.contact; 
    }else{
        result = self.userContact.user;
    }
    
    return result;
}

- (User *)recipient {
    User *result = nil;
    if(self.recipientId.integerValue == self.userContact.contact.id.integerValue){
        result = self.userContact.contact;
    }else{
        result = self.userContact.user;
    }
    return result;
}


@end