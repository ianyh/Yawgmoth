#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	imageManager = [[[SIYCardImageManager alloc] initWithApplicationSupportDirectory:[self applicationSupportDirectory]] retain];	
}

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Yawgmoth"];
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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
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

- (IBAction)addCardToLibraryAddTable:(id)sender
{
	NSArray *array = [[allCardsController selectedObjects] copy];
	NSManagedObject *tempCard;
	NSManagedObject *fullCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		fullCard = [array objectAtIndex:i];
		tempCard = [self managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (set == %@)", fullCard.name, fullCard.set] 
								   inEntityWithName:@"TempCollectionCard"];
		
		if (tempCard == nil) {
			tempCard = [self insertTempCollectionCardFromCard:fullCard];
		}
		
		[self incrementQuantityForCard:tempCard withIncrement:1];
	}
}

- (IBAction)addToLibrary:(id)sender
{
	NSArray *array = [[tempCardsController arrangedObjects] copy];
	NSManagedObject *tempCard;
	NSManagedObject *libraryCard;
    SIYMetaCard *metaCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
		tempCard = [array objectAtIndex:i];
        metaCard = [self metaCardWithCardName:tempCard.name inDeck:nil];
        if (metaCard == nil) {
            metaCard = [self insertMetaCardFromCard:tempCard];
            libraryCard = [self insertCollectionCardFromCard:tempCard];
            [metaCard addCardsObject:libraryCard];
            libraryCard.quantity = tempCard.quantity;
        } else {
            libraryCard = [self collectionCardWithCardName:tempCard.name withSet:tempCard.set inCollection:metaCard.cards];
            if (libraryCard == nil) {
                libraryCard = [self insertCollectionCardFromCard:tempCard];
                [metaCard addCardsObject:libraryCard];
                libraryCard.quantity = tempCard.quantity;
            } else {
				[self incrementQuantityForCard:libraryCard withIncrement:[tempCard.quantity intValue]];
            }
        }
        
        [[self managedObjectContext] deleteObject:tempCard];
    }
    
    [self save];
	[libraryAddingWindow close];
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
	NSArray *array = [[tempCardsController selectedObjects] copy];
	NSManagedObject *tempCollectionCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
        tempCollectionCard = [array objectAtIndex:i];
		if ([tempCollectionCard.quantity intValue] == 1) {
			[[self managedObjectContext] deleteObject:tempCollectionCard];
		} else {
			[self incrementQuantityForCard:tempCollectionCard withIncrement:-1];
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
		NSManagedObject *deck = [self deckWithName:deckName];
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
	NSManagedObject *deck = [self deckWithName:[[deckSelectionButton selectedItem] title]];
	if (deck == nil) {
		return;
	}
	
	NSEnumerator *deckEnumerator = [deck.cards objectEnumerator];
    NSEnumerator *metaCardEnumerator;
	SIYMetaCard *deckMetaCard;    
    SIYMetaCard *libraryMetaCard;
    NSManagedObject *deckCollectionCard;
    NSManagedObject *libraryCollectionCard;

	while ((deckMetaCard = [deckEnumerator nextObject]) != nil) {
        libraryMetaCard = [self metaCardWithCardName:deckMetaCard.name inDeck:nil];
        metaCardEnumerator = [deckMetaCard.cards objectEnumerator];
        while ((deckCollectionCard = [metaCardEnumerator nextObject]) != nil) {
            libraryCollectionCard = [self collectionCardWithCardName:deckCollectionCard.name withSet:deckCollectionCard.set inCollection:libraryMetaCard.cards];
            if (libraryCollectionCard == nil) {
                libraryCollectionCard = [self insertCollectionCardFromCard:deckCollectionCard];
                [libraryMetaCard addCardsObject:libraryCollectionCard];
                [[self managedObjectContext] refreshObject:libraryMetaCard mergeChanges:YES];
            }
			[self incrementQuantityForCard:libraryCollectionCard withIncrement:[deckCollectionCard.quantity intValue]];            
        }
        
		NSSet *cards = deckMetaCard.cards;
		NSEnumerator *enumerator = [cards objectEnumerator];
		NSManagedObject *card;
		while ((card = [enumerator nextObject]) != nil) {
			[[self managedObjectContext] deleteObject:card];
		}
        [[self managedObjectContext] deleteObject:deckMetaCard];
    }
    
    [[self managedObjectContext] deleteObject:deck];
    [self save];
}

- (IBAction)moveToDeck:(id)sender
{
	NSManagedObject *deck = [self deckWithName:[[deckSelectionButton selectedItem] title]];
	if (deck == nil) {
		return;
	}
	NSArray *array = [[libraryController selectedObjects] copy];
    SIYMetaCard *libraryMetaCard;
    SIYMetaCard *deckMetaCard;
    NSManagedObject *libraryCollectionCard;
    NSManagedObject *deckCollectionCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
        libraryMetaCard = [array objectAtIndex:i];
        deckMetaCard = [self metaCardWithCardName:libraryMetaCard.name inDeck:deck];
        if (deckMetaCard == nil) {
            deckMetaCard = [self insertMetaCardFromCard:libraryMetaCard];
            [deck addMetaCardsObject:deckMetaCard];
        }
        
        libraryCollectionCard = [libraryMetaCard.cards anyObject];
        deckCollectionCard = [self collectionCardWithCardName:libraryCollectionCard.name withSet:libraryCollectionCard.set inCollection:deckMetaCard.cards];
        if (deckCollectionCard == nil) {
            deckCollectionCard = [self insertCollectionCardFromCard:libraryCollectionCard];
            [deckMetaCard addCardsObject:deckCollectionCard];
            [[self managedObjectContext] refreshObject:deckMetaCard mergeChanges:YES];
        }

        [self incrementQuantityForCard:deckCollectionCard withIncrement:1];
		[self incrementQuantityForCard:libraryCollectionCard withIncrement:-1];
	}
	
	[self save];
	[array release];
}

- (IBAction)moveToLibrary:(id)sender
{
	NSArray *array = [[deckCardsController selectedObjects] copy];
    SIYMetaCard *deckMetaCard;
    NSManagedObject *deckCollectionCard;
    SIYMetaCard *libraryMetaCard;
    NSManagedObject *libraryCollectionCard;
	int i;
	
	for (i = 0; i < [array count]; i++) {
        deckMetaCard = [array objectAtIndex:i];
        libraryMetaCard = [self metaCardWithCardName:deckMetaCard.name inDeck:nil];
		if (libraryMetaCard == nil) {
			libraryMetaCard = [self insertMetaCardFromCard:deckMetaCard];
		}
        
        deckCollectionCard = [deckMetaCard.cards anyObject];
        libraryCollectionCard = [self collectionCardWithCardName:deckCollectionCard.name withSet:deckCollectionCard.set inCollection:libraryMetaCard.cards];
        if (libraryCollectionCard == nil) {
            libraryCollectionCard = [self insertCollectionCardFromCard:deckCollectionCard];
            [libraryMetaCard addCardsObject:libraryCollectionCard];
            [[self managedObjectContext] refreshObject:libraryMetaCard mergeChanges:YES];
        }
        
		[self incrementQuantityForCard:libraryCollectionCard withIncrement:1];
		[self incrementQuantityForCard:deckCollectionCard withIncrement:-1];
	}
	
	[self save];
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
		[self incrementQuantityForCard:libraryCollectionCard withIncrement:-1];
	}
	
	[array release];
	[self save];
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
	[libraryAddingCardImageView setImage:NULL];
	[self updateLibraryAddAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
								shouldDownloadIfMissing:YES 
											 withAction:@selector(updateLibraryAddImage:forCardWithName:) 
											 withTarget:self];
	
	if (cardImage != nil) {
		[libraryAddingCardImageProgress stopAnimation:self];
		[libraryAddingCardImageView setImage:cardImage];
	} else if ([libraryAddingCardImageView image] == NULL) {
		[libraryAddingCardImageProgress startAnimation:self];
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
	[deckEditingCardImageView setImage:NULL];
	[self updateLibraryAddAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
								shouldDownloadIfMissing:YES
											 withAction:@selector(updateDeckEditingImage:forCardWithName:) 
											 withTarget:self];
	
	if (cardImage != nil) {
		[deckEditingCardImageProgress stopAnimation:self];
		[deckEditingCardImageView setImage:cardImage];
	} else if ([deckEditingCardImageView image] == NULL) {
		[deckEditingCardImageProgress startAnimation:self];
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
	[deckEditingCardImageView setImage:NULL];
	[self updateDeckEditingAltImageWithCard:selectedCard];
	
	NSString *selectedCardName = selectedCard.name;
	NSImage *cardImage = [imageManager imageForCardName:selectedCardName 
								shouldDownloadIfMissing:YES
											 withAction:@selector(updateDeckEditingImage:forCardWithName:) 
											 withTarget:self];
	
	if (cardImage != nil) {
		[deckEditingCardImageProgress stopAnimation:self];
		[deckEditingCardImageView setImage:cardImage];
	} else if ([deckEditingCardImageView image] == NULL) {
		[deckEditingCardImageProgress startAnimation:self];
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
}

- (SIYMetaCard *)metaCardWithCardName:(NSString *)cardName inDeck:(NSManagedObject *)deck
{
    return (SIYMetaCard *)[self managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (deck == %@)", cardName, deck] 
                           inEntityWithName:@"MetaCard"];
}

- (NSManagedObject *)collectionCardWithCardName:(NSString *)cardName withSet:(NSString *)set inCollection:(NSSet *)collection
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (set == %@)", cardName, set];
    
    NSSet *filteredSet = [collection filteredSetUsingPredicate:predicate];
    if ([filteredSet count] > 0) {
        return (NSManagedObject *) [filteredSet anyObject];
    }
    
    return nil;
}

- (NSManagedObject *)deckWithName:(NSString *)deckName
{
    return [self managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", deckName] inEntityWithName:@"Deck"];
}

- (NSManagedObject *)managedObjectWithPredicate:(NSPredicate *)predicate inEntityWithName:(NSString *)entityName
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if (results == nil) {
        // TODO: error
        return nil;
    }
	
    if ([results count] > 0) {
        return (NSManagedObject *) [results objectAtIndex:0];
    }
    
    return nil;
}

- (SIYMetaCard *)insertMetaCardFromCard:(NSManagedObject *)card
{
    SIYMetaCard *metaCard = [NSEntityDescription insertNewObjectForEntityForName:@"MetaCard" inManagedObjectContext:[self managedObjectContext]];
    [self copyCard:card toCard:metaCard];
    return metaCard;
}

- (NSManagedObject *)insertCollectionCardFromCard:(NSManagedObject *)card
{
    NSManagedObject *collectionCard = [NSEntityDescription insertNewObjectForEntityForName:@"CollectionCard" inManagedObjectContext:[self managedObjectContext]];
    [self copyCard:card toCard:collectionCard];
    collectionCard.set = card.set;
    collectionCard.quantity = [NSNumber numberWithInt:0];
    return collectionCard;
}

- (NSManagedObject *)insertTempCollectionCardFromCard:(NSManagedObject *)card
{
	NSManagedObject *tempCollectionCard = [NSEntityDescription insertNewObjectForEntityForName:@"TempCollectionCard" inManagedObjectContext:[self managedObjectContext]];
	[self copyCard:card toCard:tempCollectionCard];
	tempCollectionCard.set = card.set;
	tempCollectionCard.quantity = [NSNumber numberWithInt:0];
	return tempCollectionCard;
}

- (void)copyCard:(NSManagedObject *)sourceCard toCard:(NSManagedObject *)destinationCard
{
    destinationCard.convertedManaCost = sourceCard.convertedManaCost;
    destinationCard.imageUrl = sourceCard.imageUrl;
    destinationCard.manaCost = sourceCard.manaCost;
    destinationCard.rarity = sourceCard.rarity;
    destinationCard.text = sourceCard.text;
    destinationCard.name = sourceCard.name;
    
    destinationCard.power = sourceCard.power;
    destinationCard.toughness = sourceCard.toughness;
    
    destinationCard.superType = sourceCard.superType;
    destinationCard.type = sourceCard.type;
}

- (void)incrementQuantityForCard:(NSManagedObject *)card withIncrement:(int)increment
{
	card.quantity = [NSNumber numberWithInt:[card.quantity intValue]+increment];
	
	if ([card.quantity intValue] <= 0) {
		NSManagedObject *metaCard = card.metaCard;
		if ([card.metaCard.cards count] == 1) {
			[[self managedObjectContext] deleteObject:metaCard];
		}
		[[self managedObjectContext] deleteObject:card];
	}
}

@end
