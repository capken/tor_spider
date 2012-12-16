#!/bin/bash

find $(dirname $0)/../urls/* | grep urls.sh |
xargs -I SCRIPT bash SCRIPT
