#import "SIYCardManager.h"


@implementation SIYCardManager

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
	NSArray *results = [self managedObjectsWithPredicate:predicate inEntityWithName:entityName];
	
    if ([results count] > 0) {
        return (NSManagedObject *) [results objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray *)managedObjectsWithPredicate:(NSPredicate *)predicate inEntityWithName:(NSString *)entityName
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
	
	return results;
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
		[card removeObserver:metaCard forKeyPath:@"quantity"];
		[[self managedObjectContext] deleteObject:card];
	}
}

@end
