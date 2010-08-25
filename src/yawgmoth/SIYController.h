#import <Cocoa/Cocoa.h>
#import "SIYCardManager.h"
#import "SIYCardImageManager.h"
#import "SIYMetaCard.h"
#import "SIYUpdaterController.h"


@interface SIYController : NSObject {
	
	SIYCardImageManager *imageManager;
	IBOutlet SIYCardManager *cardManager;
	IBOutlet SIYUpdaterController *updaterController;
	
	IBOutlet NSArrayController *allCardsController;
	IBOutlet NSArrayController *libraryController;
	IBOutlet NSArrayController *deckCardsController;
	IBOutlet NSArrayController *tempCardsController;
	IBOutlet NSArrayController *deckController;
	
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
	
	IBOutlet NSMenu *mainMenu;
	IBOutlet NSMenuItem *searchAllMenuItem;
}

- (SIYCardManager *)cardManager;

- (IBAction)addCardToLibraryAddTable:(id)sender;
- (IBAction)addToLibrary:(id)sender;
- (IBAction)cancelAddToLibrary:(id)sender;
- (IBAction)openAddToLibraryWindow:(id)sender;
- (IBAction)removeCardFromLibraryAddTable:(id)sender;
- (BOOL)isAddingCards;

- (IBAction)createNewDeck:(id)sender;
- (IBAction)createNewDeckDidEnd:(id)sender;
- (IBAction)deleteDeck:(id)sender;

- (IBAction)moveToDeck:(id)sender;
- (IBAction)moveToLibrary:(id)sender;
- (IBAction)removeFromLibrary:(id)sender;

- (IBAction)toggleDeckData:(id)sender;

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)libraryAddingImageLoadForCard:(NSManagedObject *)selectedCard;
- (void)deckEditingImageLoadForCard:(NSManagedObject *)selectedCard;

- (void)clearCardImage:(NSImageView *)imageView;
- (void)updateDeckEditingImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;
- (void)updateLibraryAddImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName;
- (void)updateDeckEditingAltImageWithCard:(NSManagedObject *)card;
- (void)updateLibraryAddAltImageWithCard:(NSManagedObject *)card;

- (BOOL)isAddingCards;

@end
