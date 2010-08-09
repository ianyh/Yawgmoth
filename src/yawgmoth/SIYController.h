#import <Cocoa/Cocoa.h>
#import "SIYCardImageManager.h"
#import "SIYMetaCard.h"


@interface SIYController : NSObject {
	
	SIYCardImageManager *imageManager;
	
	IBOutlet NSArrayController *allCardsController;
	IBOutlet NSArrayController *libraryController;
	IBOutlet NSArrayController *deckCardsController;
	IBOutlet NSArrayController *tempCardsController;
	
	IBOutlet NSWindow *deckEditingWindow;
	IBOutlet NSTableView *libraryTableView;
	IBOutlet NSTableView *deckTableView;
	IBOutlet NSPopUpButton *deckSelectionButton;
	IBOutlet NSTextField *deckEditingNameTextField;
	IBOutlet NSTextField *deckEditingCostTextField;
	IBOutlet NSTextField *deckEditingTypeTextField;
	IBOutlet NSTextField *deckEditingRarityTextField;
	IBOutlet NSTextField *deckEditingPTTextField;
	IBOutlet NSScrollView *deckEditingTextScrollView;	
	IBOutlet NSImageView *deckEditingCardImageView;
	IBOutlet NSProgressIndicator *deckEditingCardImageProgress;
	
	IBOutlet NSWindow *libraryAddingWindow;
	IBOutlet NSTableView *allCardsTable;
	IBOutlet NSSearchField *allCardsSearchField;
	IBOutlet NSTableView *cardsToAddToLibraryTable;
	IBOutlet NSTextField *libraryAddingNameTextField;
	IBOutlet NSTextField *libraryAddingCostTextField;
	IBOutlet NSTextField *libraryAddingTypeTextField;
	IBOutlet NSTextField *libraryAddingRarityTextField;
	IBOutlet NSTextField *libraryAddingPTTextField;
	IBOutlet NSScrollView *libraryAddingTextScrollView;
	IBOutlet NSImageView *libraryAddingCardImageView;
	IBOutlet NSProgressIndicator *libraryAddingCardImageProgress;
	
	IBOutlet NSPanel *newDeckPanel;
	IBOutlet NSTextField *newDeckNameField;
	IBOutlet NSButton *newDeckCreateButton;
	
	IBOutlet NSPanel *deckDataPanel;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (NSString *)applicationSupportDirectory;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;

- (IBAction)addCardToLibraryAddTable:(id)sender;
- (IBAction)addToLibrary:(id)sender;
- (IBAction)cancelAddToLibrary:(id)sender;
- (IBAction)openAddToLibraryWindow:(id)sender;
- (IBAction)removeCardFromLibraryAddTable:(id)sender;

- (IBAction)createNewDeck:(id)sender;
- (IBAction)createNewDeckDidEnd:(id)sender;
- (IBAction)deleteDeck:(id)sender;

- (IBAction)moveToDeck:(id)sender;
- (IBAction)moveToLibrary:(id)sender;
- (IBAction)removeFromLibrary:(id)sender;

- (IBAction)toggleDeckData:(id)sender;

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)allCardsSelectionAction;
- (void)libraryTableSelectionAction;
- (void)deckCardsTableSelectionAction;

- (void)updateDeckEditingImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;
- (void)updateLibraryAddImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;
- (void)updateDeckEditingAltImageWithCard:(NSManagedObject *)card;
- (void)updateLibraryAddAltImageWithCard:(NSManagedObject *)card;

- (SIYMetaCard *)metaCardWithCardName:(NSString *)cardName inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)collectionCardWithCardName:(NSString *)cardName withSet:(NSString *)set inCollection:(NSSet *)collection;
- (NSManagedObject *)deckWithName:(NSString *)deckName;
- (NSManagedObject *)managedObjectWithPredicate:(NSPredicate *)predicate inEntityWithName:(NSString *)entityName;

- (SIYMetaCard *)insertMetaCardFromCard:(NSManagedObject *)card;
- (NSManagedObject *)insertCollectionCardFromCard:(NSManagedObject *)card;
- (NSManagedObject *)insertTempCollectionCardFromCard:(NSManagedObject *)card;
- (void)copyCard:(NSManagedObject *)sourceCard toCard:(NSManagedObject *)destinationCard;

- (void)incrementQuantityForCard:(NSManagedObject *)card withIncrement:(int)increment;

@end
