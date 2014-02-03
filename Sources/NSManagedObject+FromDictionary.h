//
//  NSManagedObject+FromDictionary.h
//  Sample
//
//  Created by Jaehwa Han on 12/4/12.
//  Copyright (c) 2012 Jaehwa Han. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (FromDictionary)

+ (id)newWithJsonData:(NSData*)jsonData error:(NSError**)error commit:(BOOL)commit;
+ (id)newWithJsonString:(NSString*)json error:(NSError**)error commit:(BOOL)commit;
+ (id)newWithId:(id)object error:(NSError**)error commit:(BOOL)commit;
+ (id)newWithArray:(NSArray *)array error:(NSError **)error commit:(BOOL)commit;
+ (id)newWithDictionary:(NSDictionary *)dict error:(NSError **)error commit:(BOOL)commit;
+ (id)newWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key error:(NSError **)error commit:(BOOL)commit;

+ (id)updateWithDictionary:(NSDictionary *)dict commit:(BOOL)commit;
+ (id)updateWithDictionary:(NSDictionary *)dict error:(NSError **)error commit:(BOOL)commit;
+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key error:(NSError **)error commit:(BOOL)commit;
+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key upsert:(BOOL)upsert error:(NSError **)error commit:(BOOL)commit;

+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKeys:(NSArray *)keys upsert:(BOOL)upsert error:(NSError **)error commit:(BOOL)commit;

//this doesn't persist object. Just stuffing object with dict
- (void)updateWithDictionary:(NSDictionary *)dict;
@end
