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
	
}

- (IBAction)addCardToLibraryAddTable:(id)sender;
- (IBAction)addToLibrary:(id)sender;
- (IBAction)cancelAddToLibrary:(id)sender;
- (IBAction)openAddToLibraryWindow:(id)sender;
- (IBAction)removeCardFromLibraryAddTable:(id)sender;
- (IBAction)updateFilter:(id)sender;

@end
