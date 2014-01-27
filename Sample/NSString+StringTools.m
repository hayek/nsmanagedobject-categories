//
//  NSString+CamelCaseConversion.m
//  Sample
//
//  Created by Jaehwa Han on 12/4/12.
//  Copyright (c) 2012 Jaehwa Han. All rights reserved.
//

#import "NSString+StringTools.h"
#import "RegexKitLite.h"

@implementation NSString (StringTools)
- (NSString *)toCamelCase
{
    return [self stringByReplacingOccurrencesOfRegex:@"_([a-zA-Z0-9]+)" usingBlock:^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
        return [capturedStrings[1] capitalizedString];
    }];
}

- (NSString *)toUnderscore
{
    return [self stringByReplacingOccurrencesOfRegex:@"[A-Z]" usingBlock:^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
        unichar cs[2] = {(unichar)'_', [capturedStrings[0] characterAtIndex:0] + 32};
        return [NSString stringWithCharacters:cs length:2];
    }];
}


- (NSString *) capitalizeFirstLetter
{
    return [NSString stringWithFormat:@"%@%@",
            [[self substringWithRange:NSMakeRange(0, 1)] uppercaseString],
            [self substringWithRange:NSMakeRange(1, [self length]-1)]
            ];
}


- (NSString *) capitalizeLastLetter
{
    return [NSString stringWithFormat:@"%@%@",
            [self substringWithRange:NSMakeRange(0, [self length]-1)],
            [[self substringWithRange:NSMakeRange([self length]-1, 1)] uppercaseString]
            ];
}

- (NSString *) humanize
{
    return [self stringByReplacingOccurrencesOfRegex:@"([a-z])([A-Z])" withString:@"$1 $2"];
}

- (NSString *) lowercaseFirstLetter
{
    return [NSString stringWithFormat:@"%@%@",
            [[self substringWithRange:NSMakeRange(0, 1)] lowercaseString],
            [self substringWithRange:NSMakeRange(1, [self length]-1)]
            ];
}

-(NSString*)pluralToSingle
{
    if ([self pluralToSingleExceptions]){
        return [self pluralToSingleExceptions];
    }
    
    if ([[self substringFromIndex:self.length-3] isEqualToString:@"ies"]) { //e.g. countries
        return [NSString stringWithFormat:@"%@y",[self substringWithRange:NSMakeRange(0, self.length-3)]];
    }
    if ([[self substringFromIndex:self.length-2] isEqualToString:@"es"]) {
        if (
            [[self substringWithRange:NSMakeRange(self.length-3, 1)] isEqualToString:@"x"] || //e.g. boxes
            [[self substringWithRange:NSMakeRange(self.length-3, 1)] isEqualToString:@"s"] || //e.g. kisses
            [[self substringWithRange:NSMakeRange(self.length-4, 2)] isEqualToString:@"ch"] || //e.g. churches
            [[self substringWithRange:NSMakeRange(self.length-4, 2)] isEqualToString:@"sh"] //e.g. dishes
            )
        {
            return [self substringWithRange:NSMakeRange(0, [self length]-2)];
        }
    }
    
    if ([[self substringFromIndex:self.length-1] isEqualToString:@"s"]) //e.g. dogs, books, towns
    {
        return [self substringWithRange:NSMakeRange(0, [self length]-1)];
    }
    
    return self;
}

-(NSString*)pluralToSingleExceptions
{
    if ([self isEqualToString:@"taxies"]) {
        return @"taxi";
    }
    
    return nil;
}

-(BOOL)isVowel
{
    if ([self isEqualToString:@"a"] ||
        [self isEqualToString:@"e"] ||
        [self isEqualToString:@"i"] ||
        [self isEqualToString:@"o"] ||
        [self isEqualToString:@"u"] )
    {
        return YES;
    }
    
    return NO;
}



@end
