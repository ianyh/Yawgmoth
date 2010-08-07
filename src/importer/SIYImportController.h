#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface SIYImportController : NSObject {
	IBOutlet NSProgressIndicator *importProgress;
	IBOutlet NSTextField *importText;
	IBOutlet NSButton *importButton;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    FMDatabase *db;
    int rowCount;
}

- (NSString *)applicationSupportDirectory;
- (void)import;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;
- (IBAction)startImport:(id)sender;
- (NSString *)superTypeFromType:(NSString *)type;

@end
