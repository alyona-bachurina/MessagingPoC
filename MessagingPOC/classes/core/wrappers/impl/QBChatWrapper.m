//
//  Created by grizzly on 1/7/14.
//

#import "QBChatWrapper.h"
#import "User.h"
#import "EntityAdapter.h"
#import "UsersWrapper.h"
#import "UserContact.h"
#import "Message.h"
#import "CallRecord.h"


@interface QBChatWrapper () <QBChatDelegate>

@property(nonatomic, strong) EntityAdapter *entityAdapter;
@property(nonatomic, strong) NSObject<UsersWrapper> *usersManager;

@property (strong) NSTimer *presenceTimer;

@property (copy) LoginToChatCompletionBlock loginToChatCompletionBlock;
@property (copy) DidReceiveMessageBlock didReceiveMessageBlock;
@property (copy) ContactListDidChangeBlock contactListDidChangeBlock;

@property (copy) DidReceiveCallRequestBlock didReceiveCallRequestBlock;
@property (copy) DidNotAnswerCallRequestBlock didNotAnswerCallRequestBlock;
@property (copy) DidAcceptCallByUserBlock didAcceptCallByUserBlock;
@property (copy) DidRejectCallByUserBlock didRejectCallByUserBlock;
@property (copy) DidStopCallByUserBlock stopCallByUserBlock;
@property (copy) DidStartCallRequestBlock didStartCallRequestBlock;

@property(nonatomic, strong) QBVideoChat *videoChat;
@property(nonatomic, strong) CallRecord *currentCallRecord;
@end



@implementation QBChatWrapper {

}

- (id)init {
    self = [super init];
    if (self) {
        [QBChat instance].delegate = self;
    }

    return self;
}

- (void)dealloc {
    if(_presenceTimer.isValid){
        [_presenceTimer invalidate];
    }
    _presenceTimer=nil;
    _loginToChatCompletionBlock = nil;
    _didReceiveMessageBlock = nil;
    _contactListDidChangeBlock = nil;
    _didReceiveCallRequestBlock=nil;
    _didNotAnswerCallRequestBlock=nil;
    _didAcceptCallByUserBlock=nil;
    _didRejectCallByUserBlock=nil;
    _stopCallByUserBlock=nil;
    _didStartCallRequestBlock=nil;
    _videoChat=nil;
    _currentCallRecord=nil;
    _usersManager=nil;
    _entityAdapter=nil;
}

- (void)setCurrentCallRecord:(CallRecord *)currentCallRecord {
    _currentCallRecord = currentCallRecord;

}

- (BOOL)areHeadphonesPluggedIn {
    NSArray *availableOutputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    for (AVAudioSessionPortDescription *portDescription in availableOutputs) {
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    return NO;
}

- (void)initVideoChatWithCallRecord:(CallRecord *)record {
    if(self.videoChat == nil){
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID: record.id];
    }
    // TODO: add params for these settings
    self.videoChat.useHeadphone = [self areHeadphonesPluggedIn];
    self.videoChat.useBackCamera = NO;
}


- (void)destroyVideoChatSession {
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;
    self.currentCallRecord = nil;
}



#pragma mark subscriptions
- (void)subscribeForContactListDidChangeWithBlock:(ContactListDidChangeBlock)contactListDidChangeBlock {
    self.contactListDidChangeBlock = contactListDidChangeBlock;
}

- (void)subscribeForMessageReceiveWithBlock:(DidReceiveMessageBlock)didReceiveMessageBlock {
    self.didReceiveMessageBlock = didReceiveMessageBlock;
}

- (void)subscribeForReceiveCallRequestWithBlock:(DidReceiveCallRequestBlock)didReceiveCallRequestBlock {
    self.didReceiveCallRequestBlock = didReceiveCallRequestBlock;
}

- (void)subscribeForDidNotAnswerCallRequestWithBlock:(DidNotAnswerCallRequestBlock)didNotAnswerCallRequestBlock {
    self.didNotAnswerCallRequestBlock = didNotAnswerCallRequestBlock;
}

- (void)subscribeForDidAcceptCallByUserWithBlock:(DidAcceptCallByUserBlock)didAcceptCallByUserBlock {
    self.didAcceptCallByUserBlock = didAcceptCallByUserBlock;
}

- (void)subscribeForDidRejectCallByUserWithBlock:(DidRejectCallByUserBlock)didRejectCallByUserBlock {
    self.didRejectCallByUserBlock = didRejectCallByUserBlock;
}

- (void)subscribeForDidStopCallByUserWithBlock:(DidStopCallByUserBlock)stopCallByUserBlock {
    self.stopCallByUserBlock = stopCallByUserBlock;
}

- (void)subscribeForDidStartCallRequestWithBlock:(DidStartCallRequestBlock)didStartCallRequestBlock {
    self.didStartCallRequestBlock = didStartCallRequestBlock;
}

#pragma mark QBChatDelegate

- (void)chatDidLogin{
    // Start sending presences

    self.videoChat = nil;
    self.currentCallRecord = nil;

    [self.presenceTimer invalidate];
    self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                     target:[QBChat instance] selector:@selector(sendPresence)
                                   userInfo:nil repeats:YES];

    if(self.loginToChatCompletionBlock != nil){
        self.loginToChatCompletionBlock(nil);
        self.loginToChatCompletionBlock = nil;
    }
}

- (void)chatDidNotLogin{
    if(self.loginToChatCompletionBlock != nil){
        self.loginToChatCompletionBlock([NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo: @{NSLocalizedDescriptionKey: @"error.failed.to.login"}]);
        self.loginToChatCompletionBlock = nil;
    }
}

- (void)chatDidFailWithError:(NSInteger)code{

    DLog(@"Chat failed with error code: %d", code);
    if ([QBChat instance].currentUser) {
        [[QBChat instance] loginWithUser:[QBChat instance].currentUser];
    }
}

- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    if(![self.currentCallRecord.id isEqualToString:sessionID]){
        CallRecord *record = [self.entityAdapter callRecordWithCallerId: userID sessionId: sessionID conferenceType: conferenceType];
        record.startTime = [NSDate date];
        self.currentCallRecord = record;
        self.didReceiveCallRequestBlock(record);
    }

    // Need to
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(chatCallDidRejectByUser:) object:nil];
    [self performSelector:@selector(chatCallDidRejectByUser:) withObject:nil afterDelay:15];

}

- (void)chatCallUserDidNotAnswer:(NSUInteger)userID {
   self.didNotAnswerCallRequestBlock(self.currentCallRecord);
    [self destroyVideoChatSession];
}

- (void)chatCallDidAcceptByUser:(NSUInteger)userID {

   self.didAcceptCallByUserBlock(self.currentCallRecord);
}

- (void)chatCallDidRejectByUser:(NSUInteger)userID {
    self.didRejectCallByUserBlock(self.currentCallRecord);
    [self destroyVideoChatSession];
}

- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status {
    self.currentCallRecord.endTime = [NSDate date];
    self.stopCallByUserBlock(self.currentCallRecord);
    [self destroyVideoChatSession];
}

- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(chatCallDidRejectByUser:) object:nil];
    self.currentCallRecord.id = sessionID;
    self.didStartCallRequestBlock(self.currentCallRecord);

}

- (Message *)sendMessage:(NSString *)text toContact:(UserContact *)contact {
    QBChatMessage *qbChatMessage = [QBChatMessage message];
    qbChatMessage.senderID = contact.user.id.unsignedIntegerValue;
    qbChatMessage.text = text;
    qbChatMessage.recipientID = contact.contact.id.unsignedIntegerValue;
    qbChatMessage.datetime = [NSDate date];

    NSString* newId = [NSString stringWithFormat:@"%lu%d", (unsigned long)qbChatMessage.senderID,(int) [NSDate date].timeIntervalSince1970];

    qbChatMessage.ID = newId;

    [[QBChat instance] sendMessage:qbChatMessage];

    Message* message = [self.entityAdapter messageWithQBChatMessage: qbChatMessage];
    message.read = @(YES);
    return message;
}

- (void)chatDidReceiveMessage:(QBChatMessage *)qbChatMessage{

    Message* message = [self.entityAdapter messageWithQBChatMessage: qbChatMessage];
    message.read = @(NO);
    self.didReceiveMessageBlock(message, nil);

}

- (void)chatDidNotSendMessage:(QBChatMessage *)qbChatMessage{
    Message* message = [self.entityAdapter messageWithQBChatMessage: qbChatMessage];
    self.didReceiveMessageBlock(message, [NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Delivery failed"}]);
}

#pragma mark logic


- (void)loginWithUser:(User *)user password:password completionBlock:(LoginToChatCompletionBlock)completionBlock{

    self.loginToChatCompletionBlock = completionBlock;

    QBUUser *qbuUser = [self.entityAdapter qbUserWithUser:user];
    [qbuUser setPassword: password];
    [[QBChat instance] loginWithUser:qbuUser];
}

// TODO: refactor passing if QBVideoChatConferenceTypeAudioAndVideo

- (CallRecord *)startCallWithContact:(UserContact *)userContact callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView{

    NSString* sessionID = [NSString stringWithFormat:@"%ld%d", (long)userContact.user.id.integerValue, (int) [NSDate date].timeIntervalSince1970];
    CallRecord *callRecord = [self.entityAdapter callRecordWithCallerId:[userContact.user.id unsignedIntegerValue] sessionId:sessionID conferenceType:QBVideoChatConferenceTypeAudioAndVideo];
    callRecord.recipientId = [userContact.contact id];
    callRecord.startTime = [NSDate date];

    [self initVideoChatWithCallRecord:callRecord];
    self.videoChat.viewToRenderOpponentVideoStream = destinationVideoView;
    self.videoChat.viewToRenderOwnVideoStream = callerVideoView;

    [self.videoChat callUser:[userContact.contact.id unsignedIntegerValue] conferenceType: QBVideoChatConferenceTypeAudioAndVideo];
    self.currentCallRecord = callRecord;
    return callRecord;
}

- (void)finishCallWithCallRecord:(CallRecord *)callRecord {
    callRecord.endTime = [NSDate date];
    self.currentCallRecord = callRecord;
    [self.videoChat finishCall];
    [self destroyVideoChatSession];
}


- (void)cancelCall:(CallRecord *)record {
    [self.videoChat cancelCall];
    [self destroyVideoChatSession];
}

- (void)rejectCallWithCallRecord:(CallRecord *)callRecord {

    [self initVideoChatWithCallRecord:callRecord];
    [self.videoChat rejectCallWithOpponentID:[callRecord.userContact.contact.id unsignedIntegerValue]];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC));
    __weak typeof (self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [weakSelf destroyVideoChatSession];
    });


}

- (void)acceptCallWithCallRecord:(CallRecord *)callRecord callerView:(UIView *)callerVideoView recipientView:(UIView*)recipientVideoView {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(chatCallDidRejectByUser:) object:nil];
    [self performSelector:@selector(chatCallDidRejectByUser:) withObject:nil afterDelay:15];

    self.currentCallRecord = callRecord;
    [self initVideoChatWithCallRecord:callRecord];
    self.videoChat.viewToRenderOpponentVideoStream = callerVideoView;
    self.videoChat.viewToRenderOwnVideoStream = recipientVideoView;
    DLog(@"acceptCallWithOpponentID callRecord.recipientId %d", [callRecord.recipientId unsignedIntegerValue]);
    [self.videoChat acceptCallWithOpponentID:[callRecord.callerId unsignedIntegerValue] conferenceType: QBVideoChatConferenceTypeAudioAndVideo];

}


- (BOOL)addContact:(User *)user {

    BOOL result = [[QBChat instance] addUserToContactListRequest: user.id.unsignedIntegerValue];
    return result;
}

/**
 Called in case receiving contact request

 @param userID User ID from which received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID{

    [[QBChat instance] confirmAddContactRequest:userID];
}

/**
 Called in case changing contact list
 */
- (void)chatContactListDidChange:(QBContactList *)contactList{
    __weak typeof (self) weakSelf = self;
    [self loadDetailsForContactListUpdate:contactList completeBlock:^(NSArray *userContacts) {
         if([weakSelf contactListDidChangeBlock]){
             [weakSelf contactListDidChangeBlock](userContacts);
         }
    }];
}

/**
 Called in case changing contact's online status

 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status{

}

- (void)loadContactListWithCompletionBlock:(LoadUserContactsCompleteBlock) completeBlock {
    QBContactList *contactList = [QBChat instance].contactList;
    [self loadDetailsForContactListUpdate:contactList completeBlock:completeBlock];

}

- (void)loadDetailsForContactListUpdate:(QBContactList *)contactList completeBlock:(LoadUserContactsCompleteBlock)completeBlock {
    NSArray *qbContacts = contactList.contacts;
    NSArray *qbPending = contactList.pendingApproval;

    NSUInteger capacity = qbContacts.count + qbPending.count;
    NSMutableDictionary *contactsToId = [NSMutableDictionary dictionaryWithCapacity:capacity];

    NSArray *all = [qbContacts arrayByAddingObjectsFromArray:qbPending];
    [all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        QBContactListItem * item = obj;
        [contactsToId setObject:item forKey: @(item.userID)];
    }];
    __weak typeof (self) weakSelf = self;

    if([contactsToId allKeys].count){
        [self.usersManager loadUsersByIDs:[contactsToId allKeys] withCompleteBlock:^(NSArray *users, NSError *error) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:capacity];
            [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                User *contact = obj;
                QBContactListItem *qbContactListItem = [contactsToId objectForKey:contact.id];
                BOOL pending = [qbPending containsObject:qbContactListItem];
                UserContact *userContact = [[weakSelf entityAdapter] detachedUserContactWithUser:contact online:qbContactListItem.isOnline pending:pending];
                [result addObject:userContact];
            }];
            completeBlock(result);
        }];
    }else{
        completeBlock(@[]);
    }

}

- (void)logoutCurrentUser {

    if(self.videoChat!=nil){
        [self finishCallWithCallRecord: self.currentCallRecord];
    }
    if(self.presenceTimer.isValid){
        [self.presenceTimer invalidate];
    }
    if([QBChat instance].isLoggedIn){
        [[QBChat instance] logout];
    }

}



@end