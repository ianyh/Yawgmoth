#import <Cocoa/Cocoa.h>


@interface SIYUpdaterController : NSObject {
    IBOutlet NSButton *updateButton;
    IBOutlet NSLevelIndicator *setProgressIndicator;
    IBOutlet NSProgressIndicator *cardProgressIndicator;
    IBOutlet NSTextField *cardNumberLabel;
    IBOutlet NSTextField *setLabel;
    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;    
}

- (NSString *)applicationSupportDirectory;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)update;
- (IBAction)update:(id)sender;

@end
