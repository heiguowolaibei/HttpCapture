//
//  QQHostName.h
//  QQMSFContact
//
//  Created by justinytang on 1/19/15.
//
//

#import <Foundation/Foundation.h>
#include "QQNetworkHeaders.h"

// Build a host name from the address or vice versa. Depending on whatever you initialized first.
@interface QQHostInfo : NSObject

@property (nonatomic, readonly) NSString *hostName;
@property (nonatomic, readonly) NSString *hostAddress;

- (id)initWithHostNameOrNumber:(NSString *)hostName;
- (struct sockaddr *)validAddress;

- (qq_hivalidity)isIPAddressStringValid:(NSString *)address;

@end
