//
//  Created by grizzly on 1/6/14.
//


#import "UserDaoImpl.h"
#import "DataStore.h"
#import "User.h"
#import "NSManagedObject+SJODataKitAdditions.h"
#import "UserContact.h"


@interface UserDaoImpl ()
@property(nonatomic, strong) NSObject<DataStore> *store;
@end

@implementation UserDaoImpl {

}

- (User *)saveUser:(User *)user {
    User *result = [User findOrInsertByKey:@"id" value:user.id inContext: self.store.mainContext];
    result.login = user.login;
    result.email = user.email;
    [self.store save];
    return result;
}

- (NSArray *)getContactsForUser:(User *)user {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.id = %d", user.id.intValue];
    NSArray *result =[UserContact executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"contact.email" ascending:YES selector:@selector(compare:)];
    result = [result sortedArrayUsingDescriptors:@[descriptor]];
    return result;

}

//- (void)saveContact:(User *)contact ofUser:(User *)user {
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.id = %d AND contact.id = %d", user.id, contact.id];
//    NSArray *result =[UserContact executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];
//    if(!result.count){
//        UserContact * userContact = [UserContact insertInContext: self.store.mainContext];
//        userContact.user = user;
//        userContact.contact = contact;
//        [self.store save];
//    }
//}

- (void)saveContact:(UserContact *)contact ofUser:(User *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.id = %d AND contact.id = %d", user.id.intValue, contact.contact.id.intValue];
    NSArray *result =[UserContact executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];
    UserContact * userContact;
    if(!result.count){
        userContact = [UserContact insertInContext: self.store.mainContext];
        userContact.user = user;
        // save/update detached user and set it as contact
        userContact.contact = [self saveUser: contact.contact];
    }else{
        userContact = result.firstObject;
    }
    userContact.online = contact.online;
    userContact.pending = contact.pending;
    [self.store save];
}

- (UserContact *)getContactOfUser:(User *)user withContactUserId:(NSInteger)contactUserId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.id = %d AND contact.id = %d", user.id.intValue, contactUserId];
    NSArray *contacts =[UserContact executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];
    UserContact * result = contacts.firstObject;
    return result;
}


@end