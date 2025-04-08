#!/usr/bin/bash

INPUT=$1

awk '{ printf(">%s\n%s\n"), $1,$2 }' "${INPUT}"
