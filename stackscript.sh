#!/bin/bash

aptitude install -y curl
curl -s https://raw.github.com/patricklucas/config/master/bootstrap.sh | sh
