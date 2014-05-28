//
//  TransitionDelegate.h
//  CustomTransitionExample
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, TransitionType){
    TransitionTypeSlideFromRight  = 1,
    TransitionTypeSlideFromBottom = 2,
};


@interface TransitionDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property(nonatomic) BOOL isPresenting;
@property(nonatomic) TransitionType transitionType;

- (instancetype)initWithTransitionType:(enum TransitionType)transitionType;

+ (instancetype)delegateWithTransitionType:(enum TransitionType)transitionType;

@end
