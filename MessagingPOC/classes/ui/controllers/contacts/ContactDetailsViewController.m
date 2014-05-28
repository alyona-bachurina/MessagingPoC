//
//  Created by grizzly on 1/9/14.
//


#import <Parus/PVGroup.h>
#import "PVLayout.h"
#import "PVVFL.h"
#import "ContactDetailsViewController.h"
#import "UIImage+Utils.h"
#import "ControllerProvider.h"
#import "UserContact.h"
#import "User.h"
#import "UIView+Utils.h"
#import "UIViewController+ChatSupport.h"


@interface ContactDetailsViewController ()
@property(nonatomic, strong) UIImageView *avatarPlace;
@property(nonatomic, strong) UILabel *lblUserName;
@property(nonatomic, strong) UITextView *txtEmail;
@property(nonatomic, strong) UIButton *btnChat;
@property(nonatomic, strong) UIButton *btnCall;

@property(nonatomic, strong) NSObject<ControllerProvider> *controllerProvider;
@end

@implementation ContactDetailsViewController {

}

@synthesize destinationContact;

- (void)dealloc {
    _controllerProvider=nil;
    _avatarPlace=nil;
    _lblUserName=nil;
    _txtEmail=nil;
    _btnChat=nil;
    _btnCall=nil;
}


- (void)loadView {
    [super loadView];

    [self.view setBackgroundColor: [UIColor whiteColor]];

    [self.navigationController setNavigationBarHidden: NO];

    [self setupControls];

    [self setupLayoutConstraints];

    [self setupSubscriptions];

    [self setupWithModel];

    [self.view layoutSubviews];
}


- (void)setupWithModel {
    self.txtEmail.text = self.destinationContact.contact.email;
    self.lblUserName.text = self.destinationContact.contact.login;
}

- (void)setupControls {
    self.avatarPlace = [[UIImageView alloc] init];
    self.avatarPlace.backgroundColor = configUIColor(@"color.very.light.gray");
    self.avatarPlace.image = [[UIImage imageNamed:@"avatar.png"] imageBlendedWithColor:[UIColor lightGrayColor]];
    [self.avatarPlace roundCornersWithRadius:12 withBorderWidth:2 andColor:configUIColor(@"color.very.light.gray")];

    self.lblUserName = [[UILabel alloc] init];
    self.txtEmail = [[UITextView alloc] init];
    self.txtEmail.editable = NO;
    self.txtEmail.dataDetectorTypes = UIDataDetectorTypeAll;
    self.txtEmail.textColor = [UIColor grayColor];
    self.txtEmail.textContainerInset = UIEdgeInsetsZero;

    self.btnChat = [UIButton buttonWithType: UIButtonTypeCustom];
    self.btnCall = [UIButton buttonWithType: UIButtonTypeCustom];

    [self.btnChat setImage: [[UIImage imageNamed:@"start_chat"] imageBlendedWithColor:configUIColor(@"color.neutral.blue")] forState: UIControlStateNormal];
    [self.btnCall setImage: [[UIImage imageNamed:@"make_call"] imageBlendedWithColor:configUIColor(@"color.online.green")] forState: UIControlStateNormal];

    self.lblUserName.font = [UIFont boldSystemFontOfSize: 17];
    self.lblUserName.textColor = [UIColor grayColor];

    [self.btnChat addTarget:self action:@selector(onStartChatTapped:) forControlEvents: UIControlEventTouchUpInside];
    [self.btnCall addTarget:self action:@selector(onStartCallTapped:) forControlEvents: UIControlEventTouchUpInside];

    [@[self.avatarPlace, self.txtEmail, self.lblUserName, self.btnChat, self.btnCall]
            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints: NO];
            [self.view addSubview: obj];
    }];    
}

- (void)setupLayoutConstraints {

    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    const float padding = 10.0;
    NSDictionary *views = @{@"lblUserName" : self.lblUserName, @"avatarPlace": self.avatarPlace, @"txtEmail" :self.txtEmail };
    [self.view addConstraints:(PVVFL(@"V:|-(i)-[lblUserName]-(i)-[txtEmail]-(i)-[avatarPlace]").withViews(views).metrics(@{@"i" : @(padding)}).asArray)];

    [self.view addConstraints:PVGroup(@[

            PVCenterXOf(self.avatarPlace).equalTo.centerXOf(self.view),
            PVWidthOf(self.avatarPlace).equalTo.heightOf(self.view).multipliedTo(0.45),
            PVHeightOf(self.avatarPlace).equalTo.heightOf(self.view).multipliedTo(0.45),

            PVHeightOf(self.txtEmail).equalTo.constant(22),
            PVWidthOf(self.txtEmail).equalTo.constant(200),
            PVLeftOf(self.txtEmail).equalTo.leftOf(self.avatarPlace),

            PVLeftOf(self.lblUserName).equalTo.leftOf(self.avatarPlace),

            PVTopOf(self.btnChat).equalTo.bottomOf(self.avatarPlace).plus(padding),
            PVLeftOf(self.btnChat).equalTo.leftOf(self.avatarPlace),
            PVTopOf(self.btnCall).equalTo.bottomOf(self.avatarPlace).plus(padding),
            PVRightOf(self.btnCall).equalTo.rightOf(self.avatarPlace)

    ]).asArray];
}


- (void)setupSubscriptions {

}

- (void)onStartChatTapped:(id)sender {
    [self presentChatControllerForUserContact:self.destinationContact animated:YES controllerProvider: self.controllerProvider];
}

- (void)onStartCallTapped:(id)sender {
    [self presentVideoChatControllerForUserContact:self.destinationContact animated:YES controllerProvider: self.controllerProvider];
}


@end