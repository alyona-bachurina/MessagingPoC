//
//  Created by grizzly on 1/10/14.
//


#import "PVVFL.h"
#import <Parus/PVGroup.h>
#import "PVLayout.h"
#import "VideoChatViewController.h"
#import "ChatService.h"
#import "ApplicationContext.h"
#import "User.h"
#import "ApplicationContextService.h"
#import "CallRecord.h"
#import "UserContact.h"
#import "UIImage+Utils.h"
#import "UIView+Utils.h"
#import "Toast+UIView.h"


@interface VideoChatViewController ()
@property(nonatomic, strong) UIButton *btnReject;
@property(nonatomic, strong) UIImageView *opponentVideoView;
@property(nonatomic, strong) UIImageView *ownVideoView;
@property(nonatomic, strong) UILabel *lblRecordingTime;

@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;
@property(nonatomic, strong) NSObject<ChatService> *chatService;

@property(nonatomic, strong) UIButton *btnAccept;
@property(nonatomic, strong) UIImageView *avatarPlace;
@property(nonatomic, strong) UIButton *btnStop;

@property(nonatomic, strong) NSTimer *repeatingTimer;
@property(nonatomic) int fraction;
@end

@implementation VideoChatViewController {

}

@synthesize destinationContact = _destinationContact;
@synthesize callRecord = _callRecord;

- (void)dealloc {
    [self.chatService unsubscribe: self];
    [self stopTimer];
    _btnReject=nil;
    _opponentVideoView=nil;
    _ownVideoView=nil;
    _lblRecordingTime=nil;
    _applicationContextService=nil;
    _chatService=nil;
    _btnAccept=nil;
    _avatarPlace=nil;
    _btnStop=nil;
}

- (id)init {
    self = [super init];
    if (self) {

    }

    return self;
}


- (void)loadView {
    [super loadView];

    [self.view setBackgroundColor: [UIColor whiteColor]];
    
    [self setupControls];

    [self setupSubscriptions];

    [self setupLayoutConstraints];
    
    [self.navigationController setNavigationBarHidden: NO];
}



- (void)setupControls {
    
    self.opponentVideoView = [[UIImageView alloc] init];
    self.opponentVideoView.contentMode = UIViewContentModeScaleAspectFit;

    self.ownVideoView = [[UIImageView alloc] init];
    self.ownVideoView.contentMode = UIViewContentModeScaleAspectFit;

    [self.ownVideoView roundCornersWithRadius:12 withBorderWidth:2 andColor: configUIColor(@"color.neutral.blue")];
    [self.opponentVideoView setBackgroundColor: configUIColor(@"color.very.light.gray")];

    self.btnReject = [UIButton buttonWithType: UIButtonTypeCustom];
    self.btnReject.backgroundColor = configUIColor(@"color.reject.red");
    [self.btnReject setImage:[UIImage imageNamed: @"reject_call"] forState: UIControlStateNormal];
    [self.btnReject addTarget:self action:@selector(onRejectTapped:) forControlEvents: UIControlEventTouchUpInside];
    [self.btnReject roundCornersWithRadius:12 withBorderWidth:2 andColor:configUIColor(@"color.very.light.gray")];
    
    self.btnAccept = [UIButton buttonWithType: UIButtonTypeCustom];
    self.btnAccept.backgroundColor = configUIColor(@"color.online.green");
    [self.btnAccept setImage:[UIImage imageNamed: @"make_call.png"] forState: UIControlStateNormal];
    [self.btnAccept addTarget:self action:@selector(onAcceptTapped:) forControlEvents: UIControlEventTouchUpInside];
    [self.btnAccept roundCornersWithRadius:12 withBorderWidth:2 andColor:configUIColor(@"color.very.light.gray")];
    
    self.btnStop = [UIButton buttonWithType: UIButtonTypeCustom];
    self.btnStop.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    self.btnStop.backgroundColor = configUIColor(@"color.reject.red");
    [self.btnStop setTitle:NSLocalizedString(@"button.stop.call", nil) forState:UIControlStateNormal];
    [self.btnStop addTarget:self action:@selector(onStopTapped:) forControlEvents: UIControlEventTouchUpInside];
    [self.btnStop roundCornersWithRadius:12 withBorderWidth:2 andColor:configUIColor(@"color.very.light.gray")];
    
    self.avatarPlace = [[UIImageView alloc] init];
    self.avatarPlace.backgroundColor = configUIColor(@"color.very.light.gray");
    self.avatarPlace.image = [[UIImage imageNamed:@"avatar.png"] imageBlendedWithColor:[UIColor lightGrayColor]];
    [self.avatarPlace roundCornersWithRadius:12 withBorderWidth:2 andColor:configUIColor(@"color.very.light.gray")];

    self.lblRecordingTime = [[UILabel alloc] init];
    self.lblRecordingTime.textColor = configUIColor(@"color.neutral.blue");
    self.lblRecordingTime.font=[UIFont boldSystemFontOfSize: 16];
    self.lblRecordingTime.textAlignment = NSTextAlignmentCenter;

    [@[self.btnReject, self.btnAccept, self.btnStop, self.avatarPlace, self.opponentVideoView, self.ownVideoView, self.lblRecordingTime]
            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints: NO];
            [(UIView*)obj setHidden: YES];
            [self.view addSubview: obj];
    }];      

}

- (void)setupLayoutConstraints {
    const float padding = 15.0;
    const float topPadding = 42.0;

    const float buttonWidth = 65.0;

    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [self.view addConstraints:(PVVFL(@"V:|-(i)-[avatarPlace]").withViews(@{ @"avatarPlace": _avatarPlace }).metrics(@{@"i" : @(topPadding)}).asArray)];

    [self.view addConstraints:(PVVFL(@"V:|[opponentVideoView]").withViews(@{ @"opponentVideoView": _opponentVideoView }).metrics(@{@"i" : @(topPadding)}).asArray)];
    [self.view addConstraints:(PVVFL(@"H:|[opponentVideoView]|").withViews(@{ @"opponentVideoView": _opponentVideoView }).metrics(@{@"i" : @(topPadding)}).asArray)];

    [self.view addConstraints:(PVVFL(@"V:[btnStop]-(i)-|").withViews(@{ @"btnStop": _btnStop }).metrics(@{@"i" : @(padding)}).asArray)];

    [self.view addConstraints:PVGroup(@[

            PVCenterXOf(self.avatarPlace).equalTo.centerXOf(self.view),
            PVWidthOf(self.avatarPlace).equalTo.heightOf(self.view).multipliedTo(0.45),
            PVHeightOf(self.avatarPlace).equalTo.heightOf(self.view).multipliedTo(0.45),

            PVBottomOf(self.opponentVideoView).equalTo.topOf(self.lblRecordingTime).minus(padding),

            PVHeightOf(self.ownVideoView).equalTo.constant(IS_IPAD ? 120 : 60),
            PVWidthOf(self.ownVideoView).equalTo.constant(IS_IPAD ? 120 : 60),
            PVLeftOf(self.ownVideoView).equalTo.leftOf(self.opponentVideoView),
            PVTopOf(self.ownVideoView).equalTo.topOf(self.opponentVideoView),

            PVLeftOf(self.btnReject).equalTo.centerXOf(self.view).plus(buttonWidth),
            PVRightOf(self.btnAccept).equalTo.centerXOf(self.view).minus(buttonWidth),
            PVCenterXOf(self.btnStop).equalTo.centerXOf(self.view),

            PVWidthOf(self.btnAccept).equalTo.constant(buttonWidth),
            PVHeightOf(self.btnAccept).equalTo.constant(buttonWidth),
            PVWidthOf(self.btnReject).equalTo.constant(buttonWidth),
            PVHeightOf(self.btnReject).equalTo.constant(buttonWidth),
            PVWidthOf(self.btnStop).equalTo.constant(80),
            PVHeightOf(self.btnStop).equalTo.constant(42),

            PVBottomOf(self.btnAccept).equalTo.bottomOf(self.btnStop).minus(padding),
            PVBottomOf(self.btnReject).equalTo.bottomOf(self.btnStop).minus(padding),

            PVCenterXOf(self.lblRecordingTime).equalTo.centerXOf(self.view),
            PVHeightOf(self.lblRecordingTime).equalTo.constant(20),
            PVWidthOf(self.lblRecordingTime).equalTo.constant(250),
            PVBottomOf(self.lblRecordingTime).equalTo.topOf(self.btnStop).minus(10)

    ]).asArray];
}


- (BOOL)isIncomingCall {
    BOOL result = !(self.callRecord==nil || (self.callRecord.recipientId == self.destinationContact.user.id));
    return result;
}

- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear: animated];
    [self startCall];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


- (void)setupSubscriptions {

    __weak typeof (self) weakSelf = self;
    [self.chatService subscribeObject:self onDidNotAnswerCallWithBlock:^(CallRecord *record) {
        [weakSelf.view makeToast:NSLocalizedString(@"message.user.is.not.answering", nil) duration:2 position:@"center" withTapToHide:YES onDismissBlock:^(){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }];

    [self.chatService subscribeObject:self onDidAcceptCallByUserWithBlock:^(CallRecord *record) {
        weakSelf.callRecord = record;
        [weakSelf showVideoControls];
    }];

    [self.chatService subscribeObject:self onDidRejectCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf.view makeToast:NSLocalizedString(@"message.user.has.rejected.call", nil) duration:2 position:@"center" withTapToHide:YES onDismissBlock:^(){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }];

    [self.chatService subscribeObject:self onDidStopCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf stopTimer];
        [weakSelf.view makeToast:NSLocalizedString(@"message.user.has.stopped.call", nil) duration:2 position:@"center" withTapToHide:YES onDismissBlock:^(){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];

    }];

    [self.chatService subscribeObject:self onDidStartCallRequestWithBlock:^(CallRecord *record) {
        weakSelf.callRecord = record;
        weakSelf.title = record.userContact.contact.login;
        [weakSelf startTimer];
    }];

}


- (void)startCall {
    self.avatarPlace.hidden = NO;
    if ([self isIncomingCall]) {
        self.btnAccept.hidden = NO;
        self.btnReject.hidden = NO;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"contact.is.calling", nil), self.destinationContact.contact.login];
    } else {
        self.btnStop.hidden = NO;

        self.title = [NSString stringWithFormat:NSLocalizedString(@"calling.to.contact", nil), self.destinationContact.contact.login];
        self.callRecord = [self.chatService startCallWithContact:self.destinationContact callerView:self.ownVideoView recipientView:self.opponentVideoView];
    }
}

- (void)onStopTapped:(id)sender {

    if(![self.repeatingTimer isValid]){
        [self.chatService rejectWithCallRecord: self.callRecord];
    }else{
        [self stopTimer];
        [self.chatService finishCallWithCallRecord:self.callRecord];
    }
    [self dismissViewControllerAnimated:YES completion: nil];
}


- (void)onRejectTapped:(id)sender {
    [self.chatService rejectWithCallRecord: self.callRecord];
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (void)onAcceptTapped:(id)sender {
    [self showVideoControls];
    [self.chatService acceptWithCallRecord:self.callRecord callerView:self.opponentVideoView recipientView:self.ownVideoView];
}

- (void)showVideoControls {
    [self rotateLayer];
    self.btnStop.hidden = NO;
    self.btnAccept.hidden = YES;
    self.btnReject.hidden = YES;

    self.avatarPlace.hidden = YES;
    self.opponentVideoView.hidden= NO;
    self.ownVideoView.hidden=NO;
}

- (void)updateTimeLabel:(id)sender {

    self.lblRecordingTime.hidden=NO;
    NSDate *startDate = (NSDate *)[self.repeatingTimer userInfo];
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
    div_t h = div(elapsedTime, 3600);
    div_t m = div(h.rem, 60);
    int minutes = m.quot;
    int seconds = m.rem;
    self.fraction++;
    self.lblRecordingTime.text= [NSString stringWithFormat:@"%02d:%02d:%02d", minutes, seconds, self.fraction%10];
}

-(void)startTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimeLabel:) userInfo:[NSDate date] repeats:YES];
    self.fraction=0;
    self.repeatingTimer = timer;
}

-(void)stopTimer{
    if([self.repeatingTimer isValid]){
        [self.repeatingTimer invalidate];
    }
    self.repeatingTimer = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self rotateLayer];
}

-(void)rotateLayer{
    CALayer * stuckview = [self.ownVideoView layer];
    CGRect layerRect = [[self.ownVideoView  layer] bounds];

    UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];

    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            stuckview.affineTransform = CGAffineTransformMakeRotation(M_PI+ M_PI_2);

            break;
        case UIDeviceOrientationLandscapeRight:
            stuckview.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            stuckview.affineTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            stuckview.affineTransform = CGAffineTransformMakeRotation(0.0);
            [stuckview setBounds:layerRect];
            break;
    }
    [stuckview setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
}


@end
