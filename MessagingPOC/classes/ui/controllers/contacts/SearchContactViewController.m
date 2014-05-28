//
//  Created by grizzly on 1/6/14.
//


#import "SearchContactViewController.h"
#import "ContactViewController+protected.h"
#import "PVVFL.h"
#import "PVGroup.h"
#import "PVLayout.h"
#import "Toast+UIView.h"
#import "NSString+Utils.h"
#import "User.h"
#import "UserService.h"
#import "ChatService.h"


@interface SearchContactViewController () <UISearchBarDelegate>
@property(nonatomic, strong) UITableView *contactsTableView;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic) BOOL shouldBeginEditing;

@property(nonatomic, strong) NSObject<ChatService> *chatService;

@end

@implementation SearchContactViewController {

}


- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"search.contacts.screen.title", nil);
        self.emptyListMessage = NSLocalizedString(@"no.users.found", nil);
    }
    return self;
}

- (void)dealloc {
    _contactsTableView=nil;
    _searchBar=nil;
    _chatService=nil;

}


- (void)setupControls {
    [super setupControls];

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.delegate=self;
    [self.view addSubview: self.searchBar];
}


- (void)setupLayoutConstraints {

    [self.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.view addConstraints:PVGroup(@[
            PVHeightOf(self.searchBar).lessThan.constant(42)
    ]).asArray];


    [self.view addConstraints:PVVFL(@"H:|[_contactsTableView]|").withViews(NSDictionaryOfVariableBindings(_contactsTableView)).asArray];
    [self.view addConstraints:PVVFL(@"H:|[_searchBar]|").withViews(NSDictionaryOfVariableBindings(_searchBar)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_searchBar]-[_contactsTableView]|").withViews(NSDictionaryOfVariableBindings(_searchBar, _contactsTableView)).asArray];
}


- (void)setupNavigationBar {

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
        User *user = [self.model objectAtIndex:(NSUInteger) indexPath.row];
        cell.textLabel.text = user.email;
        cell.detailTextLabel.text = user.login;
    }
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.model count]) {
        User *user = [self.model objectAtIndex:(NSUInteger) indexPath.row];
        [self.chatService addContact: user];
        [self.navigationController popViewControllerAnimated: YES];
    }
}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    UITextField *txfSearchField = [searchBar valueForKey:@"_searchField"];
    [txfSearchField resignFirstResponder];

    NSString* searchString = searchBar.text;
    __weak typeof (self) weakSelf = self;

    [self.view makeToastActivityWithLockInteractionsForController:self];
    [self.userService searchUsers:searchString withCompleteBlock:^(NSArray* users, NSError *error) {
        [weakSelf.view hideToastActivityAndUnlockInteractions:weakSelf];
        weakSelf.model = users;
        [weakSelf.contactsTableView reloadData];
    }];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.text= @"";
    self.model = [NSArray array];
    [self.contactsTableView reloadData];
    self.searchBar.showsCancelButton=NO;

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(![searchBar isFirstResponder]) {
        self.shouldBeginEditing = NO;
    }
    self.searchBar.showsCancelButton = ![NSString isBlankOrNil: searchText];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)setupSubscriptions {

}

- (void)reloadModel {

}


@end