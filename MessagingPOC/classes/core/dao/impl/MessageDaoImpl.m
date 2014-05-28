//
//  Created by grizzly on 1/8/14.
//


#import "MessageDaoImpl.h"
#import "DataStore.h"
#import "Message.h"
#import "NSManagedObject+SJODataKitAdditions.h"
#import "UserContact.h"
#import "User.h"
#import "CallRecord.h"


@interface MessageDaoImpl ()
@property(nonatomic, strong) NSObject<DataStore> *store;
@end

@implementation MessageDaoImpl {

}

- (Message *)saveMessage:(Message *)message{
    Message *result = [Message findOrInsertByKey:@"id" value:message.id inContext: self.store.mainContext];

    result.id = message.id;
    result.text = message.text;
    result.recipientId = message.recipientId;
    result.senderId = message.senderId;
    result.datetime = message.datetime;
    result.datetime = message.datetime;
    result.delayed = message.delayed;
    result.data = message.data;
    result.read = message.read;
    result.customParameters = message.customParameters;

    [self.store save];
    return result;
}

- (NSArray *)getMessagesHistoryForContact:(UserContact *)contact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recipientId = %d AND senderId = %d) OR (recipientId = %d AND senderId = %d)",
                    contact.contact.id.intValue,
                    contact.user.id.intValue,
                    contact.user.id.intValue,
                    contact.contact.id.intValue
    ];

    NSFetchRequest *request =[Message fetchRequestWithPredicate: predicate];
    request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES selector:@selector(compare:)] ];
    [request setFetchLimit:configValueNSUInteger(@"messages.history.max.qty")];

    NSArray *result =[self.store.mainContext executeFetchRequest:request error:nil];
    return result;
}

- (NSArray *)getUnreadMessagesFromContact:(UserContact *)contact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recipientId = %d AND senderId = %d) AND read = 0",
                    contact.user.id.intValue,
                    contact.contact.id.intValue
    ];
    NSArray *result =[Message executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES selector:@selector(compare:)];
    result = [result sortedArrayUsingDescriptors:@[descriptor]];
    return result;
}

- (void)markMessageRead:(Message *)message{
    message.read = @(YES);
    [self.store save];
}

- (NSArray *)getCallsHistoryForUser:(User *)user {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recipientId = %d OR callerId = %d)",
                    user.id.intValue,
                    user.id.intValue
    ];

    NSFetchRequest *request =[CallRecord fetchRequestWithPredicate: predicate];
    [request setFetchLimit:configValueNSUInteger(@"calls.history.max.qty")];
    request.sortDescriptors = @[  [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
    NSArray *result =[self.store.mainContext executeFetchRequest:request error:nil];

//    NSArray *result = [CallRecord executeFetchRequestWithPredicate: predicate inContext:self.store.mainContext error:nil];
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES selector:@selector(compare:)];
//    result = [result sortedArrayUsingDescriptors:@[descriptor]];


    return result;

}

- (CallRecord *)saveCallRecord:(CallRecord *)record {

    CallRecord *result = [CallRecord findOrInsertByKey:@"id" value:record.id inContext: self.store.mainContext];

    result.recipientId = record.recipientId;
    result.callerId = record.callerId;
    result.startTime = record.startTime;
    result.endTime = record.endTime;

    result.userContact = record.userContact;

    [self.store save];

    return result;
}


@end