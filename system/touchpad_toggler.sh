#!/bin/bash

# List devices called anything "Touchpad" and get their numerical IDs
id=$(xinput | grep Touchpad | grep -E -o "id=[[:digit:]]+" | grep -E -o "[[:digit:]]+")

# Handle cases where no devices are found
if [ "$id" = "" ]; then
    echo "no touchpad found."
    exit 0
fi

# Loop through captured IDs and toggle their status
for i in $id; do
    status=$(xinput list-props "$i" | grep "Device Enabled" | cut -f3)
    if [ $status -eq 0 ]; then
        xinput set-prop "$i" "Device Enabled" 1
        echo "enabling device $id"
    else
        xinput set-prop "$i" "Device Enabled" 0
        echo "disabling device $id"
    fi
done
