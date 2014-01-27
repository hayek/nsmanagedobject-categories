//
//  Group.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;

@end
