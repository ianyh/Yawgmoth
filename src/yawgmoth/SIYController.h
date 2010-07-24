#import <Cocoa/Cocoa.h>
#import "SIYCardDatabase.h"


@interface SIYController : NSObject {
	
	SIYCardDatabase *cardDatabase;
	
	IBOutlet NSWindow *deckEditingWindow;
	IBOutlet NSWindow *libraryAddingWindow;
	
	IBOutlet NSButton *addToLibraryButton;
	
	IBOutlet NSTableView *allCardsTable;
	IBOutlet NSSearchField *allCardsSearchField;
	IBOutlet NSTableView *cardsToAddToLibraryTable;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)addCardToLibraryAddTable:(id)sender;
- (IBAction)addToLibrary:(id)sender;
- (IBAction)cancelAddToLibrary:(id)sender;
- (IBAction)openAddToLibraryWindow:(id)sender;
- (IBAction)removeCardFromLibraryAddTable:(id)sender;
- (IBAction)updateFilter:(id)sender;

@end
