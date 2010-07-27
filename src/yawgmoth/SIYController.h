#import <Cocoa/Cocoa.h>
#import "SIYCardDatabase.h"
#import "SIYCardImageManager.h"


@interface SIYController : NSObject {
	
	SIYCardDatabase *cardDatabase;
	SIYCardImageManager *imageManager;
	IBOutlet NSArrayController *libraryController;
	IBOutlet NSArrayController *deckCardsController;
	IBOutlet NSArrayController *tempCardsController;
	
	IBOutlet NSWindow *deckEditingWindow;
	IBOutlet NSTableView *libraryTableView;
	IBOutlet NSTableView *deckTableView;
	IBOutlet NSTableColumn *libraryCardNameTableColumn;
	IBOutlet NSTableColumn *deckCardNameTableColumn;
	IBOutlet NSPopUpButton *deckSelectionButton;
	IBOutlet NSButton *moveToDeckButton;
	IBOutlet NSButton *moveToLibraryButton;
	IBOutlet NSImageView *deckEditingCardImageView;
	IBOutlet NSProgressIndicator *deckEditingCardImageProgress;
	IBOutlet NSButton *removeFromLibraryButton;
	
	IBOutlet NSWindow *libraryAddingWindow;
	IBOutlet NSButton *addToLibraryButton;
	IBOutlet NSTableView *allCardsTable;
	IBOutlet NSSearchField *allCardsSearchField;
	IBOutlet NSTableView *cardsToAddToLibraryTable;
	IBOutlet NSImageView *libraryAddingCardImageView;
	IBOutlet NSProgressIndicator *libraryAddingCardImageProgress;
	
	IBOutlet NSPanel *newDeckPanel;
	IBOutlet NSTextField *newDeckNameField;
	IBOutlet NSButton *newDeckCreateButton;
	IBOutlet NSButton *newDeckCancelButton;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)addCardToLibraryAddTable:(id)sender;
- (IBAction)addToLibrary:(id)sender;
- (BOOL)allCardsSelectionDownloading;
- (void)allCardsSelectionAction;
- (void)libraryTableSelectionAction;
- (void)deckCardsTableSelectionAction;
- (IBAction)cancelAddToLibrary:(id)sender;
- (IBAction)createNewDeck:(id)sender;
- (IBAction)createNewDeckDidEnd:(id)sender;
- (NSManagedObject *)managedCardWithName:(NSString *)name inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)managedDeckWithName:(NSString *)name;
- (NSManagedObject *)managedLibraryCardWithName:(NSString *)name;
- (NSManagedObject *)managedTempCardWithName:(NSString *)name;
- (IBAction)moveToDeck:(id)sender;
- (IBAction)moveToLibrary:(id)sender;
- (IBAction)openAddToLibraryWindow:(id)sender;
- (IBAction)removeCardFromLibraryAddTable:(id)sender;
- (IBAction)removeFromLibrary:(id)sender;
- (void)save;
- (IBAction)updateFilter:(id)sender;
- (void)updateDeckEditingImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;
- (void)updateLibraryAddImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;

@end
