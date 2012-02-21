#!/usr/bin/env python

import getpass
import logging
import simplejson
import optparse
import os
import sys
import warnings

warnings.filterwarnings(
    action='ignore',
    category=RuntimeWarning,
    module='linode.api',
    lineno=59
)

from linode import api

DATACENTER_ID = 4 # Atlanta
PLAN_ID = 1
STACKSCRIPT_ID = 4053
DISTRIBUTION_ID = 77 # Debian 6 32-bit
DISK_SIZE = 1024 # in MB
SWAP_DISK_SIZE = 256 # in MB
DNS_DOMAIN_ID = 83108
KERNEL_ID = 137 # Latest 3.0 (3.0.18-linode43)
DNS_DOMAIN_SUFFIX = '.atl'

logging.basicConfig(level=logging.INFO)

def add_linode(linode_type, hostname, root_pass):
    linode_api = api.Api(options.api_key)

    # Add the Linode to the account
    linode_id = linode_api.linode_create(
        DatacenterID=DATACENTER_ID,
        PlanID=PLAN_ID,
        PaymentTerm=1,
    )['LinodeID']
    logging.info("Created Linode `%d'", linode_id)

    # Add and get a private IP
    private_ip_address_id = linode_api.linode_ip_addprivate(
        LinodeID=linode_id
    )['IPAddressID']

    private_ip_address = linode_api.linode_ip_list(
        LinodeID=linode_id,
        IPAddressID=private_ip_address_id
    )[0]['IPADDRESS']
    logging.info("Requisitioned private IP `%s'", private_ip_address)

    # Aggregate the StackScript parameters
    stackscript_udf_responses = simplejson.dumps({
        'hostname': hostname,
        'private_ip': private_ip_address
    })

    # Create a disk image based on the StackScript
    disk_id = linode_api.linode_disk_createfromstackscript(
        LinodeID=linode_id,
        StackScriptID=STACKSCRIPT_ID,
        StackScriptUDFResponses=stackscript_udf_responses,
        DistributionID=DISTRIBUTION_ID,
        Label="%s Disk Image" % hostname,
        Size=DISK_SIZE,
        rootPass=root_pass,
    )['DiskID']
    logging.info("Created disk image from StackScript")

    # Create a swap disk image
    swap_disk_id = linode_api.linode_disk_create(
        LinodeID=linode_id,
        Type='swap',
        Label="%dMB Swap Image" % SWAP_DISK_SIZE,
        Size=SWAP_DISK_SIZE
    )['DiskID']
    logging.info("Created swap disk image")

    # Add an A DNS record
    public_ip = [ip['IPADDRESS'] for ip in linode_api.linode_ip_list(
        LinodeID=linode_id
    ) if ip['ISPUBLIC']][0]

    linode_api.domain_resource_create(
        DomainID=DNS_DOMAIN_ID,
        Type='a',
        Name=hostname + DNS_DOMAIN_SUFFIX,
        Target=public_ip
    )
    logging.info("Added DNS `A' record")

    # Create a Linode configuration
    linode_api.linode_config_create(
      LinodeID=linode_id,
      KernelID=KERNEL_ID,
      Label=hostname,
      DiskList='%d,%d,,,,,,,' % (disk_id, swap_disk_id)
    )
    logging.info("Created Linode configuration")

    # Bootem on up
    linode_api.linode_boot(
        LinodeID=linode_id
    )
    logging.info("Booting Linode")

if __name__ == '__main__':
    usage = "Usage: %prog [options] <hostname>"
    parser = optparse.OptionParser(usage)
    parser.add_option('-k', '--api-key', default=os.environ.get('LINODE_API_KEY'))

    options, args = parser.parse_args()

    if len(args) < 1:
        parser.error("You must specify a hostname")

    if not options.api_key:
        parser.error("No Linode API key provided")

    hostname = args[0]

    root_pass = getpass.getpass("Root password: ")

    add_linode(options.api_key, hostname, root_pass)
