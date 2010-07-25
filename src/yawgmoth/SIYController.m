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
	NSString *set = [cardDatabase cardValueType:@"expansion" fromDBAtIndex:[allCardsTable selectedRow]];
	NSManagedObject *card = [self managedCardWithName:name andSet:set existsInEntityWithName:@"TempCard"];

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
	NSManagedObject *card;
	int i;
	
	for (i = 0; i < [tempCards count]; i++) {
		tempCard = [tempCards objectAtIndex:i];
		card = [self managedCardWithName:tempCard.name andSet:tempCard.set existsInEntityWithName:@"Card"];
		if (card == nil) {
			card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:[self managedObjectContext]];
			card.manaCost = tempCard.manaCost;
			card.name = tempCard.name;
			card.quantity = tempCard.quantity;
			card.rarity = tempCard.rarity;
			card.set = tempCard.set;
			card.text = tempCard.text;
			
			card.power = tempCard.power;
			card.toughness = tempCard.toughness;
			
			card.superType = tempCard.superType;
			card.type = tempCard.type;			
		} else {
			card.quantity = [NSNumber numberWithInt:[card.quantity intValue]+[tempCard.quantity intValue]];
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

- (NSManagedObject *)managedCardWithName:(NSString *)name andSet:(NSString *)set existsInEntityWithName:(NSString *)entityName
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (set = %@)", name, set];
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
	NSString *deckName = [[deckSelectionButton selectedItem] title];
}

- (IBAction)moveToLibrary:(id)sender
{
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
}

- (void)performCardSelection
{
}

- (void)save
{
    NSError *error = nil;
    
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
