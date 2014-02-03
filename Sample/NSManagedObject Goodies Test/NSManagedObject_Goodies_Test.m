//
//  NSManagedObject_Goodies_Test.m
//  NSManagedObject Goodies Test
//
//  Created by Jaehwa Han on 12/4/12.
//  Copyright (c) 2012 Jaehwa Han. All rights reserved.
//

#import "NSManagedObject_Goodies_Test.h"
#import "NSManagedObject+Convenients.h"
#import "Models.h"

@implementation NSManagedObject_Goodies_Test

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    //clean up
    
    for (User *u in [User findWithPredicate:nil]) {
        NSError *err;
        [u delete:&err];
        if (err) {
            NSLog(@"delete error : %@", err.description);
        }
    }
    
    for (Group *g in [Group findWithPredicate:nil]) {
        NSError *err;
        [g delete:&err];
        if (err) {
            NSLog(@"delete error : %@", err.description);
        }
    }
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    
    ////
    //// Persistence example with NSDictionary
    ////
    NSDictionary *user = @{@"name": @"John Doe", @"emails":@[@"john@doe.com", @"john.doe@gmail.com"]};
    NSError *err;
    User *u = [User newWithDictionary:user error:&err commit:YES];
    STAssertNil(err, @"There should be no error");
    STAssertTrue(u != nil, @"User must be persisted");
    
    ////
    //// Find example
    ////
    User *john = [User findWithPredicate:@"name == %@", @"John Doe"][0];
    STAssertNotNil(john, @"John should be here");
    STAssertEqualObjects(john.name, @"John Doe", @"John's name should be \"John Doe\"");
    
    ////
    //// Check array persistency
    ////
    NSArray *emails = [NSKeyedUnarchiver unarchiveObjectWithData:john.emails];
    STAssertTrue(emails.count == 2, @"John should have two emails");
    STAssertTrue([emails containsObject:@"john@doe.com"], @"\"john@doe.com\" is one of John's email");
    STAssertTrue([emails containsObject:@"john.doe@gmail.com"], @"\"john.doe@gmail.com\" is one of John's email");
    
    ////
    //// Key format conversion (under_score and camelCase) & Data conversion (NSDate)
    ////
    NSDictionary *group = @{@"title":@"My best friends", @"created_at":@(1354652336)};
    Group *g = [Group newWithDictionary:group error:&err commit:YES];
    STAssertNil(err, @"There should be no error");
    STAssertNotNil(g, @"New group should  not be nil");
    STAssertTrue([[Group findWithPredicate:nil] count] == 1, @"");
    
    Group *friends = [Group findWithPredicate:@"title == %@", group[@"title"]][0];
    STAssertEqualObjects(friends.title, group[@"title"], @"name should be same");
    STAssertNotNil(friends.createdAt, @"NSDate type value should be persisted");
    STAssertEquals((long)[friends.createdAt timeIntervalSince1970], 1354652336l, @"timestamps should be same");
    
    ////
    //// Unique key test
    ////
    
    NSDictionary *group2 = @{@"title":group[@"title"], @"created_at":@(1354653107)};
    Group *g2 = [Group newWithDictionary:group2 uniqueKey:@"title" error:&err commit:YES];
    STAssertNil(g2, @"Duplicate key records can't be exist simultaneously");
    
    NSArray *groups = [Group findWithPredicate:nil];
    STAssertTrue(groups.count == 1, @"There should be only one group");
    
    ////
    //// Default unique key test (`id` or `_id`)
    ////
    NSDictionary *group3 = @{@"title":@"Group 3", @"id":@(42), @"created_at":@(1354653107)};
    Group *g3 = [Group updateWithDictionary:group3 commit:YES];
    
    NSDictionary *group4 = @{@"title":@"Group 4", @"id":@(42), @"created_at":@(1354653108)};
    Group *g4 = [Group updateWithDictionary:group4 commit:YES];
    
    STAssertTrue([g4.title isEqualToString:group4[@"title"]], @"updated comparing id");
    
    NSArray *groups2 = [Group findWithPredicate:@"SELF.id == 42"];
    STAssertTrue(groups2.count == 1, @"There should be only one group with id(42)");
    
    ////
    //// Multi key test (these conditions are concatenated by `AND`)
    ////
    NSDictionary *group5 = @{@"title":@"Group 5", @"id":@(43), @"created_at":@(1354653107)};
    Group *g5 = [Group updateWithDictionary:group5 uniqueKeys:@[@"id", @"title"] upsert:YES error:nil commit:YES];
    
    NSDictionary *group6 = @{@"title":@"Group 6", @"id":@(43), @"created_at":@(1354653108)};
    Group *g6 = [Group updateWithDictionary:group6 uniqueKeys:@[@"id", @"title"] upsert:YES error:nil commit:YES];
    
    STAssertTrue([[Group findWithPredicate:@"SELF.id == 43"] count] == 2, @"Multikey should be concatenated with AND");
    
    
    ////
    //// Update test
    ////
    g.title = @"friends";
    STAssertTrue([g save:&err], @"group must be updated");
    NSLog(@"err : %@", err.description);
    g2 = [Group findWithPredicate:@"title == %@", @"friends"][0];
    STAssertEqualObjects(g2.title, @"friends", @"group must be updated");
}

-(void)testContact
{
    NSDictionary* contactDict = @{@"name": @"John Smith",
                              @"age": @25 ,
                              @"address":@{
                                      @"city": @"New York",
                                      @"state": @"NY"},
                              @"phoneNumbers":@[
                                      @{@"type": @"home",
                                        @"number": @3454353},
                                      @{@"type": @"fax",
                                        @"number": @1235},
                                      ]
                              };
    
    NSError *err;
    Contact* contact = [Contact newWithDictionary:contactDict error:&err commit:YES];
    STAssertNil(err, @"There should be no error");
    STAssertTrue(contact != nil, @"User must be persisted");
    
    STAssertTrue([contact.address.city isEqualToString:@"New York"], @"Wrong address");
    STAssertTrue(contact.phoneNumbers.count == 2, @"A phone number missing");
}



@end
