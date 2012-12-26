#!/bin/bash

curl $* | tr '\r' ' ' | tr '\n' ' '
echo
