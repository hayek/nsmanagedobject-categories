//
//  NSManagedObject+FromDictionary.m
//  Sample
//
//  Created by Jaehwa Han on 12/4/12.
//  Copyright (c) 2012 Jaehwa Han. All rights reserved.
//

#import "NSManagedObject+FromDictionary.h"
#import "NSString+StringTools.h"
#import <objc/runtime.h>
#import "RegexKitLite.h"
#import "NSManagedObjectContextHolder.h"
#import "NSManagedObject+FindMethods.h"

@implementation NSManagedObject (FromDictionary)

static inline NSDate *longToDate(long ts) {
    return [NSDate dateWithTimeIntervalSince1970:ts];
}

static inline NSDate *strToDate(NSString *d) {
    if ([d isMatchedByRegex:@"d{2}\\/d{2}\\/d{4}"]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        [fmt setDateFormat:@"MM/dd/yyyy"];
        return [fmt dateFromString:d];
    }
    
    return nil;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    unsigned int n;
    objc_property_t *properties = class_copyPropertyList([self class], &n);
    unsigned int i = 0;
    
    for (objc_property_t *pp = properties; i<n; i++, pp++) {
        objc_property_t property = *pp;
        NSString *propName = @(property_getName(property));
        
        id val = nil;
        NSString *key = nil;
        if ((val = dict[propName])) { //good to go
            key = propName;
        } else {
            //Try underscore name
            NSString *underscoreName = [propName toUnderscore];
            if ((val = dict[underscoreName])) {
                key = propName;
            }
        }
        
        //NSNull value handling
        if ((NSNull *)val == [NSNull null]) {
            val = nil;
        }

        if (key) {
            // convert type if needed
            
            NSString *propertyAttributes = (NSString *)@(property_getAttributes(property));
            
            //// 1) NSDate convert
            if ([propertyAttributes hasPrefix:@"T@\"NSDate\""]) {
                if ([val isKindOfClass:[NSNumber class]]) {
                    val = longToDate([(NSNumber *)val longValue]);
                } else if ([val isKindOfClass:[NSString class]]) {
                    val = strToDate((NSString *)val);
                } else {
                    //we don't know how to convert val to NSDate
                    val = nil;
                }
            }
            
            //// 2) NSArray to NSData convert
            else if ([propertyAttributes hasPrefix:@"T@\"NSData\""] && [val isKindOfClass:[NSArray class]]) {
                val = [NSKeyedArchiver archivedDataWithRootObject:val];
            }

            //// 3) NSArray to Custom Class convert
            else if ([propertyAttributes hasPrefix:@"T@\""] && [val isKindOfClass:[NSArray class]]) {
                NSMutableArray* valArray = [NSMutableArray arrayWithCapacity:[(NSArray*)val count]];
                for (id object in val) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        NSString* fixedKey = [[key pluralToSingle] capitalizeFirstLetter];
                        id newObject = [NSClassFromString(fixedKey) insertWithDictionary:object error:nil commit:YES];
                        [valArray addObject:newObject];
                        
                        [newObject setValue:self forKey:[NSStringFromClass(self.class) lowercaseString]];
                    }else{
                        [valArray addObject:object];
                    }
                }
                val = [NSSet setWithArray:valArray];
                
            }

            //// 2) NSDictionary to Custom Class convert
            else if ([propertyAttributes hasPrefix:@"T@\""] && [val isKindOfClass:[NSDictionary class]]) {
                NSString* fixedKey = [key capitalizeFirstLetter];
                val = [NSClassFromString(fixedKey) insertWithDictionary:val error:nil commit:YES];
                [val setValue:self forKey:[NSStringFromClass(self.class) lowercaseString]];
            }
            
            [self setValue:val forKey:key];
        }
    }
}

+ (id)insertWithDictionary:(NSDictionary *)dict error:(NSError **)error commit:(BOOL)commit
{
    NSManagedObjectContext *context = [(id<NSManagedObjectContextHolder>)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *instance = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    
    [instance updateWithDictionary:dict];
    
    if (commit && ![context save:error]) return nil;
    return instance;
}

static inline NSPredicate *equalPredicate(NSString *key, id value) {
    return [NSPredicate predicateWithFormat:@"SELF.%K == %@", key, value];
}

+ (id)insertWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key error:(NSError **)error commit:(BOOL)commit
{
    NSArray *arr = [self findWithPredicate:equalPredicate(key, dict[key])];
    if (arr.count == 0) {
        //insert new one
        return [self insertWithDictionary:dict error:error commit:commit];
    } else {
        *error = nil;
        return nil;
    }
}

+ (id)updateWithDictionary:(NSDictionary *)dict commit:(BOOL)commit{
    return [self updateWithDictionary:dict uniqueKeys:@[@"id", @"_id"] upsert:YES error:nil commit:commit]; //_id for mongoDB
}

+ (id)updateWithDictionary:(NSDictionary *)dict error:(NSError **)error commit:(BOOL)commit {
    return [self updateWithDictionary:dict uniqueKeys:@[@"id", @"_id"] upsert:YES error:error commit:commit]; //_id for mongoDB
}

+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key error:(NSError **)error commit:(BOOL)commit 
{
    return [self updateWithDictionary:dict uniqueKey:key upsert:YES error:error commit:commit];
}

+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKeys:(NSArray *)keys upsert:(BOOL)upsert error:(NSError **)error commit:(BOOL)commit
{
    NSArray *arr = nil;
    
    //check if this class has a key which is in keys
    unsigned int n;
    objc_property_t *properties = class_copyPropertyList([self class], &n);
    unsigned int i = 0;
    
    NSMutableArray *existKeys = [NSMutableArray arrayWithCapacity:keys.count];
    NSMutableDictionary *propkeys = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    
    for (objc_property_t *pp = properties; i<n; i++, pp++) {
        objc_property_t property = *pp;
        NSString *propName = @(property_getName(property));
        
        for (NSString *key in keys) {
            if ([propName isEqualToString:key] || [[propName toUnderscore] isEqualToString:key]) {
                [existKeys addObject:key];
                propkeys[key] = propName;
            }
        }
    }
    
      
    if (existKeys.count == 0) {
        arr = [self findWithPredicate:equalPredicate(keys[0], dict[keys[0]])];
    } else {
        NSMutableArray *preds = [NSMutableArray arrayWithCapacity:existKeys.count];
        for (NSString *k in existKeys) {
            [preds addObject:equalPredicate(propkeys[k], dict[k] ?: dict[[k toUnderscore]])];
        }
        arr = [self findWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:preds]];
    }

    if (arr.count == 0) {
        if (upsert) //insert new one
            return [self insertWithDictionary:dict error:error commit:commit];
        else {
            *error = nil;
            return nil;
        }
    } else {
        //update
        id obj = arr[0];
        [obj updateWithDictionary:dict];
        if (commit && ![obj save:error]) return nil;
        return obj;
    }
}



+ (id)updateWithDictionary:(NSDictionary *)dict uniqueKey:(NSString *)key upsert:(BOOL)upsert error:(NSError **)error commit:(BOOL)commit
{
    NSArray *arr = [self findWithPredicate:equalPredicate(key, dict[key])];
    
    if (arr.count == 0) {
        if (upsert) //insert new one
            return [self insertWithDictionary:dict error:error commit:commit];
        else {
            *error = nil;
            return nil;
        }
    } else {
        //update
        id obj = arr[0];
        [obj updateWithDictionary:dict];
        if (commit && ![obj save:error]) return nil;
        return obj;
    }
}
@end
