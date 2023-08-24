#!/usr/bin/env bash

# exit 0 on an even random number, exit 1 otherwise

if [[ $(( $RANDOM  % 2)) -eq 0 ]]; then
    echo "SUCCESS!"
    exit 0
fi

echo "FAILURE!"
exit 1

