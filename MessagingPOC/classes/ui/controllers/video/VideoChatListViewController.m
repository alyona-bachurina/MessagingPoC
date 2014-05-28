//
//  Created by grizzly on 1/6/14.
//


#import "PVVFL.h"
#import <Parus/PVVFL.h>
#import "VideoChatListViewController.h"
#import "PickerViewController.h"
#import "UserContact.h"
#import "ControllerProvider.h"
#import "ChatService.h"
#import "UIImage+Utils.h"
#import "UIViewController+ChatSupport.h"
#import "CallRecord.h"
#import "User.h"
#import "ApplicationContextService.h"
#import "ApplicationContext.h"


@interface VideoChatListViewController ()


@property(nonatomic, strong) NSObject<ChatService> *chatService;
@property(nonatomic, strong) NSObject<ControllerProvider> *controllerProvider;
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;

@property(nonatomic, strong) NSArray* model;
@property(nonatomic, strong) UITableView *conversationsTableView;

@end


@implementation VideoChatListViewController {

}

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"video.screen.title", nil);
    }

    return self;
}

- (void)dealloc {
    [self.chatService unsubscribe: self];
    _chatService=nil;
    _controllerProvider=nil;
    _applicationContextService=nil;
    _model=nil;
    _conversationsTableView=nil;
}

- (void)loadView {
    [super loadView];
    [self setupControls];
    [self setupNavigationBar];
    [self setupLayoutConstraints];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadModel];
}

- (void)setupNavigationBar {

    [self.navigationController setNavigationBarHidden:NO];

    UIImage* callImage = [[UIImage imageNamed:@"make_call_clear"] imageBlendedWithColor: configUIColor(@"color.neutral.blue")];
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithImage:callImage style:UIBarButtonItemStylePlain target:self action:@selector(onNewConversationTapped:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: btnAdd, nil]];

}

- (void)setupControls {
    self.conversationsTableView = [[UITableView alloc] init];
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    self.conversationsTableView.allowsSelection = NO;
    [self.view addSubview:self.conversationsTableView];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.conversationsTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.conversationsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
}


- (void)setupSubscriptions {
    __weak typeof (self) weakSelf = self;
    [self.chatService subscribeObject: self onReceiveCallWithBlock:^(CallRecord *callRecord){
          [weakSelf presentVideoChatControllerForCallRecord:callRecord animated:YES controllerProvider: weakSelf.controllerProvider];
     }];

    [self.chatService subscribeObject:self onDidNotAnswerCallWithBlock:^(CallRecord *record) {
        [weakSelf reloadModel];
    }];

    [self.chatService subscribeObject:self onDidRejectCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf reloadModel];
    }];

    [self.chatService subscribeObject:self onDidStopCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf reloadModel];
    }];
}

- (void)setupLayoutConstraints {
    [self.view addConstraints:PVVFL(@"H:|[_conversationsTableView]|").withViews(NSDictionaryOfVariableBindings(_conversationsTableView)).asArray];
    [self.view addConstraints:PVVFL(@"V:|[_conversationsTableView]|").withViews(NSDictionaryOfVariableBindings(_conversationsTableView)).asArray];
}


- (void)reloadModel {
   self.model = [self.chatService getRecentCallHistory];
   [self.conversationsTableView reloadData];
}

- (void)onNewConversationTapped:(id)sender {

    UIViewController<PickerViewController>* contactPicker = [self.controllerProvider contactPickerController];
    __weak typeof (self) weakSelf = self;
    __weak UIViewController* weakContactPicker = contactPicker;
    [contactPicker setDoneBlock:^(id selectedItem) {
        UserContact *userContact = selectedItem;
        [weakContactPicker dismissViewControllerAnimated:NO completion:^{
            [weakSelf presentVideoChatControllerForUserContact:userContact animated:YES controllerProvider: self.controllerProvider];
        }];
    }];
    UINavigationController *uiNavigationController = [[UINavigationController alloc] initWithRootViewController: contactPicker];
    [self presentViewController: uiNavigationController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"ContactCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    CallRecord *callRecord = [self.model objectAtIndex:(NSUInteger) indexPath.row];
    ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
    BOOL isIncomingCall = applicationContext.currentUser.id.integerValue == callRecord.recipientId.integerValue;
    cell.textLabel.text = callRecord.userContact.contact.login;
    cell.detailTextLabel.text = [self formatTimeAndDurationForCallRecord:callRecord];
    cell.imageView.image = isIncomingCall ? [[UIImage imageNamed:@"incoming"] imageBlendedWithColor: configUIColor(@"color.online.green")]
                                          : [[UIImage imageNamed:@"outgoing.png"] imageBlendedWithColor: configUIColor(@"color.neutral.blue")];
    return cell;

}

- (NSString *)formatTimeAndDurationForCallRecord:(CallRecord *)record {

    NSDate *startDate = record.startTime;
    NSDate *endDate = record.endTime;


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setTimeStyle: NSDateFormatterShortStyle];

    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];

    NSMutableString* result = [[dateFormatter stringFromDate:startDate] mutableCopy];

    if(startDate&&endDate){
        NSTimeInterval theTimeInterval = [endDate timeIntervalSinceDate: startDate];
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        NSDate *fromDate = [[NSDate alloc] init];
        NSDate *toDate = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:fromDate];
        unsigned int unitFlags = NSSecondCalendarUnit |NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
        NSDateComponents *conversionInfo = [sysCalendar components:(NSCalendarUnit) unitFlags fromDate:fromDate toDate:toDate options:0];

        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        [dateFormatter setDateStyle: NSDateFormatterNoStyle];

        [result appendFormat:@" %@ %02ld:%02d:%02d", NSLocalizedString(@"call.duration.subtitle", nil),(long)[conversionInfo hour], [conversionInfo minute], [conversionInfo second] ];
    }

    return result;

}


@end