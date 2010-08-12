#import <Cocoa/Cocoa.h>


@interface SIYUpdaterController : NSObject {
	IBOutlet NSPanel *updatePanel;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSModalSession modalSession;
}

- (NSString *)applicationSupportDirectory;
- (NSArray *)csvRowsFromString:(NSString *)fileString;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;
- (NSString *)superTypeFromType:(NSString *)type;
- (void)update;
- (void)startUpdate;
- (void)endUpdate;

@end
