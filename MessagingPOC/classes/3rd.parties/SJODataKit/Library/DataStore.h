//
//  Created by grizzly on 1/3/14.
//


#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@protocol DataStore <NSObject>
/**
 Save the contents of the store.
 @discussion Most often called within applicationWillTerminate: to persist changes to disk when the user leaves the app.
 */
- (void)save;

/**
 Create a new private context for use off the main thread.
 @discussion Make use of GCD and performBlockAndWait:. For example, if you want to import some data in the background:

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext* context = [store privateContext];
        [context performBlockAndWait:^{
            //Create new objects and save the private context here
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Notify of success on main thread
        });
    });

 @return A new context initialised with the NSPrivateQueueConcurrencyType type.
 */
- (NSManagedObjectContext *)newPrivateContext;

- (NSManagedObjectContext *)newChildContextForParentContext:(NSManagedObjectContext *)parentContext;

/**
 The primary NSManagedObjectContext on the main thread.
 @discussion In general this should only be used to back FRCs, or for quick operations. Most other operations should happen off the main thread for performance.
 @return The shared NSManagedObjectContext.
 */
- (NSManagedObjectContext *)mainContext;

- (BOOL)mergeChangesFromChildContext:(NSManagedObjectContext *)childContext;

- (void)saveContext:(NSManagedObjectContext *)context;
@end