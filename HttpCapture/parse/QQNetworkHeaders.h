//
//  QQNetworkHeaders.h
//  QQMSFContact
//
//  Created by justinytang on 1/19/15.
//
//

#ifndef TracerouteTester_BBNetworkHeaders_h
#define TracerouteTester_BBNetworkHeaders_h

#include <arpa/inet.h>

typedef struct _QQHostInfoValidity {
    struct sockaddr addr;
    int isValid;
} qq_hivalidity;

int qq_hostinfo_populate(struct sockaddr *, int, void *);

#define FAIL    NO
#define WIN     YES

#endif
