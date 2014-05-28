//
//  Created by grizzly on 1/6/14.
//


#import "ContactsViewController.h"
#import "UserService.h"
#import "UserContact.h"
#import "User.h"
#import "PVVFL.h"
#import "ChatService.h"
#import "UIImage+Utils.h"
#import "ControllerProvider.h"
#import "ContactViewController+protected.h"
#import "DirectChat.h"


@interface ContactsViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *contactsTableView;
@property(nonatomic, strong) NSArray *model;
@property(nonatomic, copy) NSString *emptyListMessage;

@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSObject<ChatService> *chatService;
@property(nonatomic, strong) NSObject<ControllerProvider> *controllerProvider;


- (void)setupNavigationBar;
- (void)setupControls;
- (void)setupLayoutConstraints;
@end

@implementation ContactsViewController {

}


- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"contacts.screen.title", nil);
        self.emptyListMessage = NSLocalizedString(@"contact.list.is.empty", nil);
    }
    return self;
}

- (void)dealloc {
    [self.chatService unsubscribe: self];
    _contactsTableView=nil;
    _model=nil;
    _emptyListMessage=nil;
    _userService=nil;
    _chatService=nil;
    _controllerProvider=nil;
}


- (void)loadView {
    [super loadView];

    [self setupNavigationBar];

    [self setupControls];

    [self setupLayoutConstraints];

    [self setupSubscriptions];

    [self reloadModel];
}

- (void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];

    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddContact:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: btnAdd, nil]];
}

- (void)setupControls {
    self.contactsTableView = [[UITableView alloc] init];
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    [self.view addSubview:self.contactsTableView];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.contactsTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.contactsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupLayoutConstraints {
    [self.view addConstraints:PVVFL(@"H:|[_contactsTableView]|").withViews(NSDictionaryOfVariableBindings(_contactsTableView)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_contactsTableView]|").withViews(NSDictionaryOfVariableBindings(_contactsTableView)).asArray];
}

- (void)setupSubscriptions {
    __weak typeof (self) weakSelf = self;
    [self.chatService subscribeObject: self onContactListUpdtatesWithBlock:^(){
         [weakSelf reloadModel];
     }];
}

- (void)reloadModel {
   self.model = [self.userService getContactsOfCurrentUser];
   [self.contactsTableView reloadData];
}

- (void)onAddContact:(id)onAddContact {
    [self.navigationController pushViewController:self.controllerProvider.searchContactViewController animated: YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.model count] == 0) {
         return 1; // a single cell to report no data
    }
    return [self.model count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =nil;
    if ([self.model count] == 0) {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.font = [UIFont systemFontOfSize:11];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = self.emptyListMessage;
    }else{
        NSString *identifier = @"ContactCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        UserContact *userContact = [self.model objectAtIndex:(NSUInteger) indexPath.row];
        cell.textLabel.text = userContact.contact.login;
        cell.detailTextLabel.text = userContact.contact.email;
        cell.imageView.image = [userContact getStatusImage];
    }
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.model.count){
        UserContact *userContact = [self.model objectAtIndex:(NSUInteger) indexPath.row];
        UIViewController<DirectChat> * contactDetailsViewController = [self.controllerProvider contactDetailsViewController];
        contactDetailsViewController.destinationContact = userContact;
        [self.navigationController pushViewController: contactDetailsViewController animated: YES];
    }
}


@end