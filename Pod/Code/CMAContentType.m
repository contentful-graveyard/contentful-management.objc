//
//  CMAContentType.m
//  Pods
//
//  Created by Boris Bügling on 24/07/14.
//
//

#import "CDAResource+Management.h"
#import "CDAResource+Private.h"
#import "CMAContentType.h"

@interface CMAContentType ()

@property (nonatomic) NSMutableArray* mutableFields;
@property (nonatomic, readonly) NSString* URLPath;

@end

#pragma mark -

@implementation CMAContentType

-(BOOL)addFieldWithName:(NSString *)name type:(CDAFieldType)type {
    CMAField* field = [CMAField fieldWithName:name type:type];

    if ([[self.mutableFields valueForKey:@"identifier"] containsObject:field.identifier]) {
        return NO;
    }

    [self.mutableFields addObject:field];
    return YES;
}

-(void)deleteField:(CMAField *)field {
    [self.mutableFields removeObject:field];
}

-(void)deleteFieldWithIdentifier:(NSString *)identifier {
    for (CMAField* field in self.fields) {
        if ([field.identifier isEqualToString:identifier]) {
            [self deleteField:field];
        }
    }
}

-(CDARequest *)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(NSArray *)fields {
    return [self.mutableFields copy];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient *)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        self.mutableFields = [super.fields mutableCopy];
    }
    return self;
}

-(NSArray*)parameterArrayFromFields {
    NSMutableArray* fieldsArray = [@[] mutableCopy];

    for (CDAField* field in self.mutableFields) {
        [fieldsArray addObject:[field valueForKey:@"dictionaryRepresentation"]];
    }

    return fieldsArray;
}

-(CDARequest *)publishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@"published" withSuccess:success failure:failure];
}

-(CDARequest *)unpublishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"published" withSuccess:^{
        // Delay is needed to avoid issues with deleted Content Types still showing up in search.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           if (success) {
                               success();
                           }
                       });
    } failure:failure];
}

-(void)updateWithResource:(CDAResource *)resource {
    [super updateWithResource:resource];

    if ([resource isKindOfClass:[CMAContentType class]]) {
        self.mutableFields = [[(CMAContentType*)resource mutableFields] mutableCopy];
    }
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"name": self.name,
                                         @"description": self.description,
                                         @"fields": [self parameterArrayFromFields] }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return [@"content_types" stringByAppendingPathComponent:self.identifier];
}

@end
