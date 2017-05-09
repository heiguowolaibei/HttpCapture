//
//  NSString+HTML.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "HttpCapture-swift.h"

#if TARGET_IPHONE_SIMULATOR
#include <net/route.h>
#else
#include "Route.h"
#endif
#import "LDNetGetAddress.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a)-1) | (sizeof(long) - 1))) : sizeof(long))

@implementation NSString (network)

#pragma mark - Instance Methods
-(NSString *)statusMessageGetHttpVersion{
    if ([self rangeOfString:@"/1.1"].length > 0) {
        return @"HTTP/1.1";
    }
    else if ([self rangeOfString:@"/1.0"].length > 0) {
        return @"HTTP/1.0";
    }
    else if ([self rangeOfString:@"/2.0"].length > 0) {
        return @"HTTP/2.0";
    }
    return @"HTTP/1.1";
}

+ (NSString *)getIPAddress
{
    NSDictionary * ipaddress = [self getIPAddresses];
    if ([[WXNetworkStatusManager currentNetworkType] isEqualToString:@"WIFI"]) {
        return [ipaddress objectForKey:@"en0/ipv4"];
    }
    else if ([[WXNetworkStatusManager currentNetworkType] isEqualToString: @"2G"] ||
             [[WXNetworkStatusManager currentNetworkType] isEqualToString: @"3G"] ||
             [[WXNetworkStatusManager currentNetworkType] isEqualToString: @"4G"] ||
             [[WXNetworkStatusManager currentNetworkType] isEqualToString: @"XG"])
    {
        return [ipaddress objectForKey:@"pdp_ip0/ipv4"];
    }
    
    return @"";
}

+(NSString *)formatIPV4Address:(struct in_addr)ipv4Addr{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+(NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+ (NSString *)getGatewayIPV4Address
{
    NSString *address = nil;
    
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;
    
    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }
    
    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }
        
        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if (((rt->rtm_addrs & (RTA_DST | RTA_GATEWAY)) == (RTA_DST | RTA_GATEWAY)) &&
                sa_tab[RTAX_DST]->sa_family == AF_INET &&
                sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                unsigned char octet[4] = {0, 0, 0, 0};
                int i;
                for (i = 0; i < 4; i++) {
                    octet[i] = (((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >>
                                (i * 8)) &
                    0xFF;
                }
                if (((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    in_addr_t addr =
                    ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    address = [self formatIPV4Address:*((struct in_addr *)&addr)];
                    NSLog(@"IPV4address%@", address);
                    break;
                }
            }
        }
        free(buf);
    }
    
    return address;
}

+ (NSString *)getGatewayIPV6Address
{
    NSString *address = nil;
    
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET6, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr_in6 *sa;
    struct sockaddr_in6 *sa_tab[RTAX_MAX];
    int i;
    
    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }
    
    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }
        
        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr_in6 *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr_in6 *)((char *)sa + sa->sin6_len);
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sin6_family == AF_INET6
               && sa_tab[RTAX_GATEWAY]->sin6_family == AF_INET6)
            {
                address = [self formatIPV6Address:((struct sockaddr_in6 *)(sa_tab[RTAX_GATEWAY]))->sin6_addr];
                NSLog(@"IPV6address%@", address);
                break;
            }
        }
        free(buf);
    }
    
    return address;
}


+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP)) {
                continue;
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)getDNSs
{
    NSArray * ar = [NSArray arrayWithArray:[LDNetGetAddress outPutDNSServers]];
    return [ar componentsJoinedByString:@", "];
}


@end
