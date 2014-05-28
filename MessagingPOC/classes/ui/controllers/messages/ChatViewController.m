//
//  Created by grizzly on 1/6/14.
//


#import "ChatViewController.h"
#import "UserContact.h"
#import "UserService.h"
#import "ChatService.h"
#import "User.h"
#import "Message.h"
#import "ApplicationContextService.h"


@interface ChatViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSObject<ChatService> *chatService;
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;

@property(nonatomic, strong) NSArray *model;

@end



@implementation ChatViewController {

}

@synthesize destinationContact = _destinationContact;


- (void)dealloc {
    [self.chatService unsubscribe: self];
    _destinationContact=nil;
    _userService=nil;
    _chatService=nil;
    _applicationContextService=nil;
    _model=nil;
}


- (void)loadView {
    [super loadView];
    self.delegate = self;
    self.dataSource = self;
    self.title = self.destinationContact.contact.login;

    [self setupSubscriptions];
    [self setupNavigationBar];
    [self reloadModel];

    self.messageInputView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}



- (void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden: NO];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.title.back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onCancelTapped)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnCancel, nil]];
}

- (void)onCancelTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupSubscriptions {
    __weak typeof (self) weakSelf = self;
    [self.chatService subscribeObject: self onMessagesListUpdtatesWithBlock:^(){
        [weakSelf reloadModel];
        [weakSelf.chatService markMessagesRead: weakSelf.model];
        [weakSelf scrollToBottomAnimated:YES];

     }];
}

- (void)reloadModel {
   self.model = [self.chatService getMessagesHistoryForContact:self.destinationContact];
   [self.tableView reloadData];
}


#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text {
    [self.chatService sendMessage: text toContact: self.destinationContact];
    self.model = [self.chatService getMessagesHistoryForContact:self.destinationContact];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {

    Message* message = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    enum JSBubbleMessageType result;
    if(message.senderId.intValue == self.destinationContact.user.id.intValue){
       result = JSBubbleMessageTypeOutgoing;  
    }else{
        result = JSBubbleMessageTypeIncoming;
    }
    return result;

}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {

    UIImageView *result;
    if(type == JSBubbleMessageTypeIncoming) {
        result = [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }else{
        result = [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    result.backgroundColor = self.tableView.backgroundColor = [UIColor whiteColor];
    return result;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy {
    return JSMessagesViewTimestampPolicyEveryFive;

}

- (JSMessagesViewAvatarPolicy)avatarPolicy {
    return JSMessagesViewAvatarPolicyNone;

}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy {
    return JSMessagesViewSubtitlePolicyAll;

}

- (JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;

}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    return message.text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    return message.datetime;
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UIImageView alloc] init];
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [self.model objectAtIndex:(NSUInteger) indexPath.row];

    NSString *result = nil;
    if(message.senderId.intValue == self.destinationContact.user.id.intValue){
       result = self.destinationContact.user.login;
    }else{
        result = self.destinationContact.contact.login;
    }
    return result;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.count;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.chatService markMessagesRead:self.model];
}


@end