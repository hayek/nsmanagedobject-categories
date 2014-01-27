//
//  User.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSData * emails;
@property (nonatomic, retain) NSString * name;

@end
