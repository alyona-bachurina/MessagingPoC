#import "ContactsViewController.h"

@protocol UserService;

@interface ContactsViewController (_protected) <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *contactsTableView;
@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSArray *model;
@property(nonatomic, copy) NSString *emptyListMessage;

- (void)setupNavigationBar;

- (void)setupControls;

- (void)setupLayoutConstraints;

- (void)setupSubscriptions;

@end