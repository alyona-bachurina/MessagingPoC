//
//  TransitionDelegate.m
//  CustomTransitionExample
//

#import "TransitionDelegate.h"


@implementation TransitionDelegate
- (instancetype)initWithTransitionType:(enum TransitionType)transitionType {
    self = [super init];
    if (self) {
        self.transitionType = transitionType;
    }

    return self;
}

+ (instancetype)delegateWithTransitionType:(enum TransitionType)transitionType {
    return [[self alloc] initWithTransitionType:transitionType];
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresenting = NO;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    switch(self.transitionType){

        case TransitionTypeSlideFromRight:{
            if (self.isPresenting) {
                [toVC.view setFrame:CGRectMake(fromVC.view.frame.size.width, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                [inView addSubview:toVC.view];

                [UIView animateWithDuration:0.25f
                                 animations:^{
                                     [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                                 }
                                 completion:^(BOOL finished) {
                                     [transitionContext completeTransition:YES];
                                 }];
            } else {

                [UIView animateWithDuration:0.25f
                                 animations:^{
                                     [fromVC.view setFrame:CGRectMake(fromVC.view.frame.size.width, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                                 }
                                 completion:^(BOOL finished) {
                                     [toVC.view removeFromSuperview];
                                     [transitionContext completeTransition:YES];
                                 }];
            }
           break;
        };
        case TransitionTypeSlideFromBottom:{
            if (self.isPresenting) {
                [toVC.view setFrame:CGRectMake(0, fromVC.view.frame.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                [inView addSubview:toVC.view];

                [UIView animateWithDuration:0.25f
                                 animations:^{
                                     [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                                 }
                                 completion:^(BOOL finished) {
                                     [transitionContext completeTransition:YES];
                                 }];
            } else {

                [UIView animateWithDuration:0.25f
                                 animations:^{
                                     [fromVC.view setFrame:CGRectMake(0, fromVC.view.frame.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                                 }
                                 completion:^(BOOL finished) {
                                     [toVC.view removeFromSuperview];
                                     [transitionContext completeTransition:YES];
                                 }];
            }
            break;
        }
    }


}


@end
