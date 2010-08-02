#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	imageManager = [[[SIYCardImageManager alloc] initWithApplicationSupportDirectory:[self applicationSupportDirectory]] retain];	
	
	[allCardsTable setDelegate:self];
	[cardsToAddToLibraryTable setDelegate:self];
	[libraryTableView setDelegate:self];
	[deckTableView setDelegate:self];
}

- (IBAction)addCardToLibraryAddTable:(id)sender
{
	NSArray *array = [[allCardsController selectedObjects] copy];
	NSManagedObject *tempCard;	
	NSManagedObject *fullCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		fullCard = [array objectAtIndex:i];
		tempCard = [self managedTempCardWithName:fullCard.name];
		
		if (tempCard == nil) {
			tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
			
			tempCard.convertedManaCost = fullCard.convertedManaCost;
			tempCard.manaCost = fullCard.manaCost;
			tempCard.name = fullCard.name;
			tempCard.rarity = fullCard.rarity;
			tempCard.text = fullCard.text;
			
			tempCard.power = fullCard.power;
			tempCard.toughness = fullCard.toughness;
			
			tempCard.superType = fullCard.superType;
			tempCard.type = fullCard.type;
			
			tempCard.quantity = [NSNumber numberWithInt:1];			
		} else {
			tempCard.quantity = [NSNumber numberWithInt:[tempCard.quantity intValue]+1];
		}
	}
}

- (IBAction)addToLibrary:(id)sender
{
	NSArray *array = [[tempCardsController arrangedObjects] copy];
	NSManagedObject *tempCard;
	NSManagedObject *libraryCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		tempCard = [array objectAtIndex:i];
		libraryCard = [self managedLibraryCardWithName:tempCard.name];
		if (libraryCard == nil) {
			libraryCard = [NSEntityDescription insertNewObjectForEntityForName:@"LibraryCard" inManagedObjectContext:[self managedObjectContext]];
			libraryCard.manaCost = tempCard.manaCost;
			libraryCard.name = tempCard.name;
			libraryCard.quantity = tempCard.quantity;
			libraryCard.rarity = tempCard.rarity;
			libraryCard.text = tempCard.text;
			
			libraryCard.power = tempCard.power;
			libraryCard.toughness = tempCard.toughness;
			
			libraryCard.superType = tempCard.superType;
			libraryCard.type = tempCard.type;			
		} else {
			libraryCard.quantity = [NSNumber numberWithInt:[libraryCard.quantity intValue]+[tempCard.quantity intValue]];
		}
		
		[[self managedObjectContext] deleteObject:tempCard];
	}
	
	[self save];
	
	[libraryAddingWindow close];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([notification object] == allCardsTable) {
		[self allCardsSelectionAction];
	} else if ([notification object] == deckTableView) {
		[self deckCardsTableSelectionAction];
	} else if ([notification object] == libraryTableView) {
		[self libraryTableSelectionAction];
	}
}

- (void)allCardsSelectionAction
{
	NSArray *array = [allCardsController selectedObjects];
	if ([array count] == 0) {
		[libraryAddingCardImageView setImage:NULL];
		return;
	}
	
	NSManagedObject *selectedCard = [array objectAtIndex:0];
	[self updateLibraryAddAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
											 shouldDownloadIfMissing:YES 
											 withAction:@selector(updateLibraryAddImage:forCardWithName:) 
											 withTarget:self];

	if (cardImage != nil) {
		[libraryAddingCardImageProgress stopAnimation:self];
		[libraryAddingCardImageView setImage:cardImage];
	} else {
		[libraryAddingCardImageProgress startAnimation:self];
		[libraryAddingCardImageView setImage:NULL];
	}
}
	 
- (void)libraryTableSelectionAction
{
	NSArray *array = [libraryController selectedObjects];
	if ([array count] == 0) {
		[deckEditingCardImageView setImage:NULL];
		return;
	}
	
	NSManagedObject *selectedCard = [array objectAtIndex:0];
	[self updateDeckEditingAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
												 shouldDownloadIfMissing:YES
												 withAction:@selector(updateDeckEditingImage:forCardWithName:) 
												 withTarget:self];
	
	if (cardImage != nil) {
		[deckEditingCardImageProgress stopAnimation:self];
		[deckEditingCardImageView setImage:cardImage];
	} else {
		[deckEditingCardImageProgress startAnimation:self];
		[deckEditingCardImageView setImage:NULL];
	}
}

- (void)deckCardsTableSelectionAction
{
	NSArray *array = [deckCardsController selectedObjects];
	if ([array count] == 0) {
		[deckEditingCardImageView setImage:NULL];
		return;
	}
	
	NSManagedObject *selectedCard = [array objectAtIndex:0];
	[self updateDeckEditingAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
												 shouldDownloadIfMissing:YES
												 withAction:@selector(updateDeckEditingImage:forCardWithName:) 
												 withTarget:self];
	
	if (cardImage != nil) {
		[deckEditingCardImageProgress stopAnimation:self];
		[deckEditingCardImageView setImage:cardImage];
	} else {
		[deckEditingCardImageProgress startAnimation:self];		
		[deckEditingCardImageView setImage:NULL];
	}	
}

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Yawgmoth"];
}

- (IBAction)cancelAddToLibrary:(id)sender
{
	[libraryAddingWindow close];
}

- (IBAction)createNewDeck:(id)sender
{
	[NSApp beginSheet:newDeckPanel modalForWindow:deckEditingWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)createNewDeckDidEnd:(id)sender
{
	if (sender == newDeckCreateButton) {
		NSString *deckName = [newDeckNameField stringValue];
		NSManagedObject *deck = [self managedDeckWithName:deckName];
		if (deck == nil) {
			deck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:[self managedObjectContext]];
			deck.name = deckName;
			[self save];
		}
	}
	
	[newDeckPanel orderOut:nil];
	[NSApp endSheet:newDeckPanel];
}

- (IBAction)deleteDeck:(id)sender
{
	NSManagedObject *deck = [self managedDeckWithName:[[deckSelectionButton selectedItem] title]];
	if (deck == nil) {
		return;
	}
	
	NSEnumerator *deckEnumerator = [deck.cards objectEnumerator];
	NSManagedObject *card;
	NSManagedObject *libraryCard;
	
	while ((card = [deckEnumerator nextObject]) != nil) {
		libraryCard = [self managedLibraryCardWithName:card.name];
		libraryCard.quantity = [NSNumber numberWithInt:[libraryCard.quantity intValue]+[card.quantity intValue]];
		
		[[self managedObjectContext] deleteObject:card];
	}
	
	[[self managedObjectContext] deleteObject:deck];
	[self save];
}

- (NSManagedObject *)managedCardWithName:(NSString *)name inDeck:(NSManagedObject *)deck
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (deck = %@)", name, deck];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (results == nil) {
		// TODO: present error
		return nil;
	}
	
	if ([results count] > 0) {
		return (NSManagedObject *) [results objectAtIndex:0];
	}
	
	return nil;
}

- (NSManagedObject *)managedDeckWithName:(NSString *)name
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *checkResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (checkResults == nil) {
		// TODO: do something with error
		return nil;
	}
	
	if ([checkResults count] > 0) {
		return (NSManagedObject *) [checkResults objectAtIndex:0];
	}
	
	return nil;
}

- (NSManagedObject *)managedLibraryCardWithName:(NSString *)name
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LibraryCard" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *checkResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (checkResults == nil) {
		// TODO: do something with error
		return nil;
	}
	
	if ([checkResults count] > 0) {
		return (NSManagedObject *) [checkResults objectAtIndex:0];
	}
	
	return nil;
}

- (NSManagedObject *)managedTempCardWithName:(NSString *)name
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (results == nil) {
		// TODO: do something with error
		return nil;
	}
	
	if ([results count] > 0) {
		return (NSManagedObject *) [results objectAtIndex:0];
	}
	
	return nil;
}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"com.scarredions.yawgmoth" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel 
{	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (IBAction)moveToDeck:(id)sender
{
	NSManagedObject *deck = [self managedDeckWithName:[[deckSelectionButton selectedItem] title]];
	if (deck == nil) {
		return;
	}
	NSArray *array = [[libraryController selectedObjects] copy];
	NSManagedObject *libraryCard;
	NSManagedObject *card;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		libraryCard = [array objectAtIndex:i];
		libraryCard.quantity = [NSNumber numberWithInt:[libraryCard.quantity intValue]-1];
		
		card = [self managedCardWithName:libraryCard.name inDeck:deck];
		if (card == nil) {
			card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:[self managedObjectContext]];
			card.manaCost = libraryCard.manaCost;
			card.name = libraryCard.name;
			card.quantity = [NSNumber numberWithInt:1];
			card.rarity = libraryCard.rarity;
			card.text = libraryCard.text;
			
			card.power = libraryCard.power;
			card.toughness = libraryCard.toughness;
			
			card.superType = libraryCard.superType;
			card.type = libraryCard.type;
			card.deck = deck;
			[deck addCardsObject:card];
		} else {
			card.quantity = [NSNumber numberWithInt:[card.quantity intValue]+1];
		}
	}
	
	[self save];
	[array release];
}

- (IBAction)moveToLibrary:(id)sender
{
	NSArray *array = [[deckCardsController selectedObjects] copy];
	NSManagedObject *libraryCard;
	NSManagedObject *card;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		card = [array objectAtIndex:i];
		card.quantity = [NSNumber numberWithInt:[card.quantity intValue]-1];

		libraryCard = [self managedLibraryCardWithName:card.name];
		libraryCard.quantity = [NSNumber numberWithInt:[libraryCard.quantity intValue]+1];

		if ([card.quantity intValue] == 0) {
			[[self managedObjectContext] deleteObject:card];
		}		
	}
	
	[self save];
	[array release];
}

- (IBAction)openAddToLibraryWindow:(id)sender
{	
	[libraryAddingWindow makeKeyAndOrderFront:self];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator)return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
	}

	NSString *storeDataPath = [applicationSupportDirectory stringByAppendingPathComponent:@"storedata"];
	
	if (![fileManager fileExistsAtPath:storeDataPath]) {
		NSString *seedStoreDataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"storedata"];
		if (![fileManager copyItemAtPath:seedStoreDataPath toPath:storeDataPath error:&error]) {
			NSLog(@"Error copying seed store data to application support directory");
			return nil;
		}
	}
    
    NSURL *url = [NSURL fileURLWithPath:storeDataPath];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

- (IBAction)removeCardFromLibraryAddTable:(id)sender
{
	NSArray *array = [tempCardsController selectedObjects];
	NSManagedObject *tempCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		tempCard = [array objectAtIndex:i];
		if ([tempCard.quantity intValue] == 1) {
			[[self managedObjectContext] deleteObject:tempCard];
		} else {
			tempCard.quantity = [NSNumber numberWithInt:[tempCard.quantity intValue]-1];
		}
	}
}

- (IBAction)removeFromLibrary:(id)sender
{
	NSArray *array = [[libraryController selectedObjects] copy];
	NSManagedObject *libraryCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		libraryCard = [array objectAtIndex:i];
		libraryCard.quantity = [NSNumber numberWithInt:[libraryCard.quantity intValue]-1];
	}
	
	[array release];
	[self save];
}

- (void)save
{
    NSError *error;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }	
}

- (void)updateLibraryAddImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName
{
	if (cardName != nil && [cardName isEqualToString:[imageManager mainDownloadingCardName]]) {
		[libraryAddingCardImageView setImage:cardImage];
	}
	[libraryAddingCardImageProgress stopAnimation:self];
}

- (void)updateLibraryAddAltImageWithCard:(NSManagedObject *)card
{
	[libraryAddingNameTextField setStringValue:card.name];
	[libraryAddingCostTextField setStringValue:card.manaCost];
	[libraryAddingTypeTextField setStringValue:card.type];
	[libraryAddingRarityTextField setStringValue:card.rarity];
	if ([card.superType isEqualToString:@"Artifact Creature"] || [card.superType isEqualToString:@"Creature"]) {
		[libraryAddingPTTextField setStringValue:[NSString stringWithFormat:@"%@/%@", card.power, card.toughness]];
	} else {
		[libraryAddingPTTextField setStringValue:@""];
	}
	[[libraryAddingTextScrollView documentView] setString:card.text];
}

- (void)updateDeckEditingAltImageWithCard:(NSManagedObject *)card
{
	[deckEditingNameTextField setStringValue:card.name];
	[deckEditingCostTextField setStringValue:card.manaCost];
	[deckEditingTypeTextField setStringValue:card.type];
	[deckEditingRarityTextField setStringValue:card.rarity];
	if ([card.superType isEqualToString:@"Artifact Creature"] || [card.superType isEqualToString:@"Creature"]) {
		[deckEditingPTTextField setStringValue:[NSString stringWithFormat:@"%@/%@", card.power, card.toughness]];
	} else {
		[deckEditingPTTextField setStringValue:@""];
	}
	[[deckEditingTextScrollView documentView] setString:card.text];
}

- (void)updateDeckEditingImage:(NSImage *)cardImage forCardWithName:(NSString *)cardName
{
	if (cardName != nil && [cardName isEqualToString:[imageManager mainDownloadingCardName]]) {
		[deckEditingCardImageView setImage:cardImage];
	}
	[deckEditingCardImageProgress stopAnimation:self];	
}

@end
