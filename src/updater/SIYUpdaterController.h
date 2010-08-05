#import <Cocoa/Cocoa.h>


@interface SIYUpdaterController : NSObject {
    NSMutableDictionary *setToCards;
    IBOutlet NSButton *updateButton;
    IBOutlet NSProgressIndicator *setProgressIndicator;
    IBOutlet NSProgressIndicator *cardProgressIndicator;
    IBOutlet NSTextField *cardNumberLabel;
    IBOutlet NSTextField *setLabel;
    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;    
}

- (NSString *)applicationSupportDirectory;
- (NSArray *)csvRowsFromString:(NSString *)fileString;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;
- (IBAction)startUpdate:(id)sender;
- (NSString *)superTypeFromType:(NSString *)type;
- (void)update;

@end
