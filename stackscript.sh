#!/bin/bash

<udf name="hostname" LABEL="Hostname">
<udf name="private_ip" LABEL="Private IP Address">

curl -s https://raw.github.com/patricklucas/config/master/bootstrap.sh | bash
