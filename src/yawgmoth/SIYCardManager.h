#import <Cocoa/Cocoa.h>
#import "SIYMetaCard.h"


@interface SIYCardManager : NSObject {
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
