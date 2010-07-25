#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	cardDatabase = [[[SIYCardDatabase alloc] init] retain];
	[allCardsTable setDataSource:cardDatabase];
}

- (IBAction)addCardToLibraryAddTable:(id)sender
{
	NSString *name = [cardDatabase cardValueType:@"name" fromDBAtIndex:[allCardsTable selectedRow]];
	NSManagedObject *card = [self managedTempCardWithName:name];

	if (card != nil) {
		card.quantity = [NSNumber numberWithInt:[card.quantity intValue]+1];
	} else {
		card = [NSEntityDescription insertNewObjectForEntityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
		[cardDatabase populateCard:card withRowIndex:[allCardsTable selectedRow]];
	}
}

- (IBAction)addToLibrary:(id)sender
{
	NSEntityDescription *tempCardEntityDescription = [NSEntityDescription entityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *allTempCardsFetchRequest = [[NSFetchRequest alloc] init];
	[allTempCardsFetchRequest setEntity:tempCardEntityDescription];
	
	NSError *error;
	NSArray *tempCards = [[self managedObjectContext] executeFetchRequest:allTempCardsFetchRequest error:&error];
	NSManagedObject *tempCard;
	NSManagedObject *libraryCard;
	int i;
	
	for (i = 0; i < [tempCards count]; i++) {
		tempCard = [tempCards objectAtIndex:i];
		libraryCard = [self managedLibraryCardWithName:tempCard.name];
		if (libraryCard == nil) {
			libraryCard = [NSEntityDescription insertNewObjectForEntityForName:@"LibraryCard" inManagedObjectContext:[self managedObjectContext]];
			libraryCard.manaCost = tempCard.manaCost;
			libraryCard.name = tempCard.name;
			libraryCard.quantity = tempCard.quantity;
			libraryCard.rarity = tempCard.rarity;
			libraryCard.quantity = tempCard.quantity;
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

- (NSString *)applicationSupportDirectory {
	
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

- (NSManagedObject *)managedCardWithName:(NSString *)name inDeck:(NSManagedObject *)deck
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (deck = %@)", name, deck];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
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
	if (results == nil) {
		// TODO: do something with error
		return nil;
	}
	
	if ([results count] > 0) {
		return (NSManagedObject *) [results objectAtIndex:0];
	}
	
	return nil;
}

- (NSManagedObjectContext *) managedObjectContext {
	
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

- (NSManagedObjectModel *)managedObjectModel {
	
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
	NSArray *array = [libraryController selectedObjects];
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
}

- (IBAction)moveToLibrary:(id)sender
{
	NSArray *array = [deckCardsController selectedObjects];
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
}

- (IBAction)openAddToLibraryWindow:(id)sender
{	
	[libraryAddingWindow makeKeyAndOrderFront:self];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
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
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
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

- (IBAction)updateFilter:(id)sender
{
	[cardDatabase updateFilter:[allCardsSearchField stringValue]];
	[allCardsTable reloadData];
}

@end
