#!/usr/bin/env python

import optparse
import os

LINODE_API_KEY = os.environ.get('LINODE_API_KEY')
LOCATION = "Atlanta, GA"
DNS_DOMAIN = "atl.patricklucas.net"

def add_linode(linode_type, hostname):
    print "Adding new Linode %d '%s'" % (linode_type, hostname)
    # Check permissions

    # Add the Linode to the account

    # Add and get a private IP

    # Add and get an IPv6 IP

    # Rebuild from StackScript with hostname and private ip as parameters

    # Add A/AAAA dns records

    # Bootem on up

if __name__ == '__main__':
    usage = "Usage: %prog [options] <hostname>"
    parser = optparse.OptionParser(usage)
    parser.add_option('-k', '--api-key', default=LINODE_API_KEY)
    parser.add_option('-t', '--type', type='int', dest='linode_type',
        default=512)

    options, args = parser.parse_args()

    if len(args) < 1:
        parser.error("You must specify a hostname")

    if not options.api_key:
        parser.error("No Linode API key provided")

    hostname = args[0]

    add_linode(options.linode_type, hostname)
