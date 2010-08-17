#import <Cocoa/Cocoa.h>
#import "SIYMetaCard.h"


@interface SIYCardManager : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (void)moveSingleCard:(NSManagedObject *)card toDeck:(NSManagedObject *)deck;
- (void)moveCard:(NSManagedObject *)card toDeck:(NSManagedObject *)deck;
- (void)deleteDeck:(NSManagedObject *)deck;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (NSString *)applicationSupportDirectory;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)save;

- (SIYMetaCard *)metaCardWithCardName:(NSString *)cardName inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)collectionCardWithCardName:(NSString *)cardName withSet:(NSString *)set inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)tempCardWithName:(NSString *)cardName withSet:(NSString *)set;
- (NSManagedObject *)deckWithName:(NSString *)deckName;
- (NSManagedObject *)managedObjectWithPredicate:(NSPredicate *)predicate inEntityWithName:(NSString *)entityName;
- (NSArray *)managedObjectsWithPredicate:(NSPredicate *)predicate inEntityWithName:(NSString *)entityName;

- (SIYMetaCard *)insertMetaCardFromCard:(NSManagedObject *)card inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)insertCollectionCardFromCard:(NSManagedObject *)card inDeck:(NSManagedObject *)deck;
- (NSManagedObject *)insertTempCollectionCardFromCard:(NSManagedObject *)card;
- (NSManagedObject *)insertDeck:(NSString *)deckName;
- (void)copyCard:(NSManagedObject *)sourceCard toCard:(NSManagedObject *)destinationCard;

- (void)incrementQuantityForCard:(NSManagedObject *)card withIncrement:(int)increment;

@end
