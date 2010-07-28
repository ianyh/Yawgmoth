#import <Cocoa/Cocoa.h>
#import "SIYCardDatabase.h"
#import "SIYDataModelManagedObjects.h"

@interface SIYImportController : NSObject {
	SIYCardDatabase *cardDatabase;
	IBOutlet NSProgressIndicator *importProgress;
	IBOutlet NSTextField *importText;
	IBOutlet NSButton *importButton;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
}

- (NSString *)applicationSupportDirectory;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;
- (IBAction)startImport:(id)sender;

@end
