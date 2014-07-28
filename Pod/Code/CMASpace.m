//
//  CMASpace.m
//  ManagementSDK
//
//  Created by Boris Bügling on 15/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAClient+Private.h"
#import "CDAResource+Private.h"
#import "CMASpace.h"

@interface CMASpace ()

@property (nonatomic) CDAClient* apiClient;;

@end

#pragma mark -

@implementation CMASpace

@dynamic name;

#pragma mark -

-(CDAClient *)client {
    return self.apiClient;
}

-(void)setClient:(CDAClient *)client {
    NSParameterAssert(client);
    self.apiClient = [client copyWithSpace:self];
}

-(CDARequest *)createAssetWithFields:(NSDictionary *)fields
                             success:(CMAAssetFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"assets"
                            headers:nil
                         parameters:@{ @"fields": fields }
                            success:success
                            failure:failure];
}

-(CDARequest *)createEntryOfContentType:(CMAContentType*)contentType
                             withFields:(NSDictionary *)fields
                                success:(CMAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"entries"
                            headers:@{ @"X-Contentful-Content-Type": contentType.identifier }
                         parameters:@{ @"fields": fields }
                            success:success
                            failure:failure];
}

-(CDARequest *)fetchContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                    failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchContentTypesWithSuccess:success failure:failure];
}

-(CDARequest *)fetchEntryWithIdentifier:(NSString *)identifier
                                success:(CDAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchEntryWithIdentifier:identifier success:success failure:failure];
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client putURLPath:@""
                           headers:@{ @"X-Contentful-Version": [self.sys[@"version"] stringValue] }
                        parameters:@{ @"name": self.name }
                           success:^(CDAResponse *response, CMASpace* space) {
                               [self updateWithResource:space];

                               if (success) success();
                           } failure:failure];
}

@end
