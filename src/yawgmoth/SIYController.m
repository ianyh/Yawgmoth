#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	imageManager = [[[SIYCardImageManager alloc] initWithApplicationSupportDirectory:[cardManager applicationSupportDirectory]] retain];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *updateFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"update"];
	if ([fileManager fileExistsAtPath:updateFilePath]) {
		[updaterController update];
		[fileManager removeItemAtPath:updateFilePath error:nil];
	}
}

- (SIYCardManager *)cardManager
{
	return cardManager;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [cardManager managedObjectContext];
}

- (IBAction)addCardToLibraryAddTable:(id)sender
{
	NSArray *array = [[allCardsController selectedObjects] copy];
	NSManagedObject *tempCard;
	NSManagedObject *fullCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		fullCard = [array objectAtIndex:i];
		tempCard = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (set == %@)", fullCard.name, fullCard.set] 
								   inEntityWithName:@"TempCollectionCard"];
		
		if (tempCard == nil) {
			tempCard = [cardManager insertTempCollectionCardFromCard:fullCard];
		}
		
		[cardManager incrementQuantityForCard:tempCard withIncrement:1];
	}
	
	[array release];
}

- (IBAction)addToLibrary:(id)sender
{
	NSArray *array = [[tempCardsController arrangedObjects] copy];
	NSManagedObject *tempCard;
	NSManagedObject *libraryCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		tempCard = [array objectAtIndex:i];
		libraryCard = [cardManager collectionCardWithCardName:tempCard.name withSet:tempCard.set inDeck:nil];
		if (libraryCard == nil) {
			libraryCard = [cardManager insertCollectionCardFromCard:tempCard inDeck:nil];
		}
		
		[cardManager incrementQuantityForCard:libraryCard withIncrement:[tempCard.quantity intValue]];
        [[cardManager managedObjectContext] deleteObject:tempCard];
    }
    
    [cardManager save];
	[libraryAddingWindow close];
	[NSApp endSheet:libraryAddingWindow];
	
	[array release];
}

- (IBAction)cancelAddToLibrary:(id)sender
{
	[libraryAddingWindow close];	
	[NSApp endSheet:libraryAddingWindow];
}

- (IBAction)openAddToLibraryWindow:(id)sender
{
	[NSApp beginSheet:libraryAddingWindow modalForWindow:deckEditingWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)removeCardFromLibraryAddTable:(id)sender
{
	NSArray *array = [[tempCardsController selectedObjects] copy];
	NSManagedObject *tempCollectionCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
        tempCollectionCard = [array objectAtIndex:i];
		if ([tempCollectionCard.quantity intValue] == 1) {
			[[cardManager managedObjectContext] deleteObject:tempCollectionCard];
		} else {
			[cardManager incrementQuantityForCard:tempCollectionCard withIncrement:-1];
		}
	}
    
    [array release];
}

- (IBAction)createNewDeck:(id)sender
{
	[NSApp beginSheet:newDeckPanel modalForWindow:deckEditingWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)createNewDeckDidEnd:(id)sender
{
	if (sender == newDeckCreateButton) {
		NSString *deckName = [newDeckNameField stringValue];
		NSManagedObject *deck = [cardManager deckWithName:deckName];
		if (deck == nil) {
			deck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:[cardManager managedObjectContext]];
			deck.name = deckName;
			[cardManager save];
		}
	}
	
	[newDeckPanel orderOut:nil];
	[NSApp endSheet:newDeckPanel];
}

- (IBAction)deleteDeck:(id)sender
{
	NSArray *deckArray = [deckController selectedObjects];
	if ([deckArray count] == 0) {
		return;
	}
	NSManagedObject *deck = [deckArray objectAtIndex:0];
	
	[cardManager deleteDeck:deck];
	
    [cardManager save];
}

- (IBAction)moveToDeck:(id)sender
{
	NSArray *deckArray = [deckController selectedObjects];
	if ([deckArray count] == 0) {
		return;
	}
	
	NSManagedObject *deck = [deckArray objectAtIndex:0];
	NSArray *array = [[libraryController selectedObjects] copy];
	NSManagedObject *card;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		card = [[[array objectAtIndex:i] cards] anyObject];
		[cardManager moveSingleCard:card toDeck:deck];
	}
	
	[cardManager save];
	[array release];
}

- (IBAction)moveToLibrary:(id)sender
{
	NSArray *array = [[deckCardsController selectedObjects] copy];
	NSManagedObject *card;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		card = [[[array objectAtIndex:i] cards] anyObject];
		[cardManager moveSingleCard:card toDeck:nil];
	}
	
	[cardManager save];
	[array release];
}

- (IBAction)removeFromLibrary:(id)sender
{
	NSArray *array = [[libraryController selectedObjects] copy];
    NSManagedObject *libraryMetaCard;
	NSManagedObject *libraryCollectionCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
        libraryMetaCard = [array objectAtIndex:i];
        libraryCollectionCard = [libraryMetaCard.cards anyObject];
		[cardManager incrementQuantityForCard:libraryCollectionCard withIncrement:-1];
	}
	
	[array release];
	[cardManager save];
}

- (IBAction)toggleDeckData:(id)sender
{
	if ([sender state] == NSOffState) {
		[sender setState:NSOnState];
		[deckDataPanel makeKeyAndOrderFront:self];
	} else {
		[sender setState:NSOffState];
		[deckDataPanel close];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSManagedObject *selectedCard;
	NSArray *array;

	if ([notification object] == allCardsTable || [notification object] == cardsToAddToLibraryTable) {
		if ([notification object] == allCardsTable) {
			array = [allCardsController selectedObjects];
		} else {
			array = [tempCardsController selectedObjects];
		}
		
		if ([array count] == 0) {
			selectedCard = nil;
		} else {
			selectedCard = [array objectAtIndex:0];
		}
		
		[self libraryAddingImageLoadForCard:selectedCard];
	} else {
		if ([notification object] == libraryTableView) {
			array = [libraryController selectedObjects];
		} else {
			array = [deckCardsController selectedObjects];
		}
		
		if ([array count] == 0) {
			selectedCard = nil;
		} else {
			selectedCard = [array objectAtIndex:0];
		}
		
		[self deckEditingImageLoadForCard:selectedCard];
	}
}

- (void)libraryAddingImageLoadForCard:(NSManagedObject *)selectedCard
{
	[self clearCardImage:libraryAddingCardImageView];
	if (selectedCard == nil) {
		return;
	}

	NSImage *cardImage = [imageManager imageForCardName:selectedCard.name 
								shouldDownloadIfMissing:YES 
											 withAction:@selector(updateLibraryAddImage:forCardWithName:) 
											 withTarget:self];

	if (cardImage != nil) {
		[libraryAddingCardImageProgress stopAnimation:self];
		[libraryAddingCardImageView setImage:cardImage];
	} else if ([libraryAddingCardImageView image] == NULL) {
		[self updateLibraryAddAltImageWithCard:selectedCard];		
		[libraryAddingCardImageProgress startAnimation:self];
	}
}

- (void)deckEditingImageLoadForCard:(NSManagedObject *)selectedCard
{
	[self clearCardImage:deckEditingCardImageView];
	if (selectedCard == nil) {
		return;
	}
	
	NSImage *cardImage = [imageManager imageForCardName:selectedCard.name 
								shouldDownloadIfMissing:YES 
											 withAction:@selector(updateDeckEditingImage:forCardWithName:)
											 withTarget:self];
	
	if (cardImage != nil) {
		[deckEditingCardImageProgress stopAnimation:self];
		[deckEditingCardImageView setImage:cardImage];
	} else if ([libraryAddingCardImageView image] == NULL) {
		[self updateDeckEditingAltImageWithCard:selectedCard];
		[deckEditingCardImageProgress startAnimation:self];
	}
}

- (void)clearCardImage:(NSImageView *)imageView
{
	[imageView setImage:nil];
	if (imageView == libraryAddingCardImageView) {
		[libraryAddingNameTextField setHidden:YES];
		[libraryAddingCostTextField setHidden:YES];
		[libraryAddingTypeTextField setHidden:YES];
		[libraryAddingRarityTextField setHidden:YES];
		[libraryAddingPTTextField setHidden:YES];
		[libraryAddingTextScrollView setHidden:YES];
	} else {
		[deckEditingNameTextField setHidden:YES];
		[deckEditingCostTextField setHidden:YES];
		[deckEditingTypeTextField setHidden:YES];
		[deckEditingRarityTextField setHidden:YES];
		[deckEditingPTTextField setHidden:YES];
		[deckEditingTextScrollView setHidden:YES];
	}
}

- (void)updateDeckEditingImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName
{
    [deckEditingCardImageView setImage:cardImage];
	[deckEditingCardImageProgress stopAnimation:self];	
}

- (void)updateLibraryAddImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName
{
    [libraryAddingCardImageView setImage:cardImage];
	[libraryAddingCardImageProgress stopAnimation:self];
}

- (void)updateDeckEditingAltImageWithCard:(NSManagedObject *)card
{
	[deckEditingNameTextField setStringValue:card.name];
    if (card.manaCost == nil) {
        [deckEditingCostTextField setStringValue:@""];
    } else {
        [deckEditingCostTextField setStringValue:card.manaCost];
    }
	[deckEditingTypeTextField setStringValue:card.type];
    if (card.rarity == nil) {
        [deckEditingRarityTextField setStringValue:@""];
    } else {
        [deckEditingRarityTextField setStringValue:card.rarity];
    }
	if ([card.superType isEqualToString:@"Artifact Creature"] || [card.superType isEqualToString:@"Creature"]) {
		[deckEditingPTTextField setStringValue:[NSString stringWithFormat:@"%@/%@", card.power, card.toughness]];
	} else {
		[deckEditingPTTextField setStringValue:@""];
	}
    if (card.text == nil) {
        [[deckEditingTextScrollView documentView] setString:@""];
    } else {
        [[deckEditingTextScrollView documentView] setString:card.text];
    }
	
	[deckEditingNameTextField setHidden:NO];
	[deckEditingCostTextField setHidden:NO];
	[deckEditingTypeTextField setHidden:NO];
	[deckEditingRarityTextField setHidden:NO];
	[deckEditingPTTextField setHidden:NO];
	[deckEditingTextScrollView setHidden:NO];
}

- (void)updateLibraryAddAltImageWithCard:(NSManagedObject *)card
{
	[libraryAddingNameTextField setStringValue:card.name];
    if (card.manaCost == nil) {
        [libraryAddingCostTextField setStringValue:@""];
    } else {
        [libraryAddingCostTextField setStringValue:card.manaCost];
    }
	[libraryAddingTypeTextField setStringValue:card.type];
    if (card.rarity == nil) {
        [libraryAddingRarityTextField setStringValue:@""];
    } else {
        [libraryAddingRarityTextField setStringValue:card.rarity];
    }
	if ([card.superType isEqualToString:@"Artifact Creature"] || [card.superType isEqualToString:@"Creature"]) {
		[libraryAddingPTTextField setStringValue:[NSString stringWithFormat:@"%@/%@", card.power, card.toughness]];
	} else {
		[libraryAddingPTTextField setStringValue:@""];
	}
    if (card.text == nil) {
        [[libraryAddingTextScrollView documentView] setString:@""];
    } else {
        [[libraryAddingTextScrollView documentView] setString:card.text];
    }
	
	[libraryAddingNameTextField setHidden:NO];
	[libraryAddingCostTextField setHidden:NO];
	[libraryAddingTypeTextField setHidden:NO];
	[libraryAddingRarityTextField setHidden:NO];
	[libraryAddingPTTextField setHidden:NO];
	[libraryAddingTextScrollView setHidden:NO];
}

@end
