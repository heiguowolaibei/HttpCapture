
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#define __FILE__ "QQHostInfo"
#pragma clang diagnostic pop

//
//  QQHostName.m
//  QQMSFContact
//
//  Created by justinytang on 1/19/15.
//
//

#import "QQHostInfo.h"
#import <arpa/inet.h>

@interface QQHostInfo ()
{
    NSString * _hostCandidate;
}


@end

@implementation QQHostInfo {
    qq_hivalidity ipaddr_sa;
}

- (id)initWithHostNameOrNumber:(NSString *)hostName {
    self = [super init];
    if (self) {
        qq_hivalidity valid = [self isIPAddressStringValid:hostName];
        ipaddr_sa = valid;
        if(ipaddr_sa.isValid) {
            _hostAddress = hostName;
        } else {
            _hostName = hostName;
        }
    }
    return self;
}

- (struct sockaddr *)validAddress {
    if(ipaddr_sa.isValid) {
        return &ipaddr_sa.addr;
    } else {
        return NULL;
    }
}

- (qq_hivalidity)isIPAddressStringValid:(NSString *)address {
    
    struct sockaddr zajeb;
    qq_hivalidity resultValidity = {zajeb, FAIL};
    
    if(address == nil) return resultValidity;
    
    const char * ipAddress = [address cStringUsingEncoding:NSASCIIStringEncoding];
    
    struct in_addr sAddr;
    int result = inet_pton(AF_INET, ipAddress, &sAddr);
    
    if(result == 1) {
        resultValidity.isValid = WIN;
        qq_hostinfo_populate(&resultValidity.addr, AF_INET, &sAddr);
        return resultValidity;
    }
    
    // OK, so this might not be a IPV4 address, go on
    struct in6_addr sAddr6;
    result = inet_pton(AF_INET6, ipAddress, &sAddr6);
    if(result == 1) {
        resultValidity.isValid = WIN;
        qq_hostinfo_populate(&resultValidity.addr, AF_INET6, &sAddr);
        return resultValidity;
    }
    
    return resultValidity;
}

- (void)dealloc {
    
}

@end
