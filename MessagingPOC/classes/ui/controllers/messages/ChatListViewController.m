//
//  Created by grizzly on 1/3/14.
//


#import "PVVFL.h"
#import <Parus/PVVFL.h>
#import "ChatListViewController.h"
#import "PickerViewController.h"
#import "UserContact.h"
#import "DirectChat.h"
#import "TyphoonAssembly.h"
#import "ControllersAssembly.h"
#import "ChatService.h"
#import "UserService.h"
#import "User.h"
#import "CustomBadge.h"
#import "UIViewController+ChatSupport.h"


@interface ChatListViewController ()


@property(nonatomic, strong) NSObject<ChatService> *chatService;
@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSObject<ControllerProvider> *controllerProvider;

@property(nonatomic, strong) NSArray* model;
@property(nonatomic, strong) NSDictionary* unreadMessages;
@property(nonatomic, strong) UITableView *conversationsTableView;
@end


@implementation ChatListViewController {

}



- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"chat.screen.title", nil);
    }
    return self;
}

- (void)dealloc {
    [self.chatService unsubscribe: self];
    _chatService=nil;
    _userService=nil;
    _controllerProvider=nil;
    _model=nil;
    _unreadMessages=nil;
    _conversationsTableView=nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadView {
    [super loadView];

    [self setupNavigationBar];

    [self reloadModel];

    [self setupControls];

    [self setupLayoutConstraints];

    [self.view layoutSubviews];

    [self.conversationsTableView reloadData];
}

- (void)reloadModel {
    self.model = [self.userService getRecentChatContacts];
    self.unreadMessages = [self.chatService getUnreadMessagesForContacts:self.model];
}

- (void)setupControls {
    self.conversationsTableView = [[UITableView alloc] init];
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    [self.view addSubview:self.conversationsTableView];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.conversationsTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.conversationsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupLayoutConstraints {
    [self.view addConstraints:PVVFL(@"H:|[_conversationsTableView]|").withViews(NSDictionaryOfVariableBindings(_conversationsTableView)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_conversationsTableView]|").withViews(NSDictionaryOfVariableBindings(_conversationsTableView)).asArray];
}

- (void)setupSubscriptions {
    __weak typeof (self) weakSelf = self;

    [self.chatService subscribeObject:self onMessagesListUpdtatesWithBlock:^{
        [weakSelf presentUnreadMessagesCount];
    }];

    [self.chatService subscribeObject:self onUnreadMessagesCountChangedWithBlock:^{
        [weakSelf presentUnreadMessagesCount];
    }];

    [self.chatService subscribeObject: self onContactListUpdtatesWithBlock:^(){
        weakSelf.model = [weakSelf.userService getRecentChatContacts];
        [weakSelf.conversationsTableView reloadData];
     }];
}

-(void) presentUnreadMessagesCount{
    [self reloadModel];
    NSUInteger totalUnreadMessages = [self totalUnreadMessages];
    if(totalUnreadMessages > 0){
        NSString* badgeValueAsString = [NSString stringWithFormat:@"%lu", (unsigned long)totalUnreadMessages];
        self.tabBarItem.badgeValue = badgeValueAsString;
    }else{
        self.tabBarItem.badgeValue = nil;
    }
    [self.conversationsTableView reloadData];
}

- (NSUInteger )totalUnreadMessages {
    __block NSUInteger result = 0;
    [self.unreadMessages.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result += [obj integerValue];
    }];
    return result;
}

- (void)setupNavigationBar {

    [self.navigationController setNavigationBarHidden:NO];

    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onNewConversationTapped:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: btnAdd, nil]];

}

- (void)onNewConversationTapped:(id)sender {

    UIViewController<PickerViewController>* contactPicker = [self.controllerProvider contactPickerController];
    __weak typeof (self) weakSelf = self;
    __weak UIViewController* weakContactPicker = contactPicker;
    [contactPicker setDoneBlock:^(id selectedItem) {
        UserContact *userContact = selectedItem;
        [weakContactPicker dismissViewControllerAnimated:NO completion:^{
            [weakSelf presentChatControllerForUserContact:userContact animated:NO controllerProvider: weakSelf.controllerProvider];
        }];

    }];
    UINavigationController *uiNavigationController = [[UINavigationController alloc] initWithRootViewController: contactPicker];
    [self presentViewController: uiNavigationController animated:YES completion:nil];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"ContactCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];

        CustomBadge *customBadge = [CustomBadge customBadgeWithString:@""
       												   withStringColor: [UIColor whiteColor]
       													withInsetColor: [UIColor redColor]
       													withBadgeFrame: YES
       											   withBadgeFrameColor: [UIColor whiteColor]
       														 withScale: 1
       													   withShining: NO];
        cell.accessoryView = customBadge;

    }

    UserContact *userContact = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = userContact.contact.login;
    cell.imageView.image = [userContact getStatusImage];
    CustomBadge *customBadge = (CustomBadge *) cell.accessoryView;

    NSNumber* unreadMessagesCount = [self.unreadMessages objectForKey: userContact.contact.id];
    if(unreadMessagesCount.integerValue){
        [customBadge autoBadgeSizeWithString: [unreadMessagesCount stringValue]];
        [customBadge setHidden: NO];
    }else{
        [customBadge setHidden: YES];
    }

    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserContact *userContact = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    [self presentChatControllerForUserContact:userContact animated:YES controllerProvider: self.controllerProvider];
}


@end