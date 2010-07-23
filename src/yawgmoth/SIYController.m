#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	cardDatabase = [[[SIYCardDatabase alloc] init] retain];
	[allCardsTable setDataSource:cardDatabase];
}

- (IBAction)addCardToLibraryAddTable:(id)sender
{
}

- (IBAction)addToLibrary:(id)sender
{
}

- (IBAction)cancelAddToLibrary:(id)sender
{
	[libraryAddingWindow close];
}

- (IBAction)openAddToLibraryWindow:(id)sender
{	
	[libraryAddingWindow makeKeyAndOrderFront:self];
}

- (IBAction)removeCardFromLibraryAddTable:(id)sender
{
}

- (void)performCardSelection
{
}

- (IBAction)updateFilter:(id)sender
{
	[cardDatabase updateFilter:[allCardsSearchField stringValue]];
	[allCardsTable reloadData];
}

@end
