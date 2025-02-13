#!/usr/bin/env sh
# wait-for-it.sh

# The MIT License (MIT)
# Copyright (c) 2017 - 2020 vishnubob

# This script will wait for a service to become available on a specific host and port
# Usage: wait-for-it.sh host:port -- command_to_execute

TIMEOUT=30
QUIET=0
WAIT_FOR=0
HOST="postgres"
PORT="5432"
CMD=""
WAIT_INTERVAL=1
# parse args
while [[ $# -gt 0 ]]
do
    case "$1" in
        *:* )
            HOST=$(echo "$1" | cut -d: -f1)
            PORT=$(echo "$1" | cut -d: -f2)
            WAIT_FOR=1
            ;;
        -t|--timeout)
            TIMEOUT=$2
            shift
            ;;
        -q|--quiet)
            QUIET=1
            ;;
        --)
            shift
            CMD=$@
            break
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
    shift
done

# Check if we were provided a host:port to wait for
if [[ $WAIT_FOR -eq 0 ]]; then
    echo "Error: You must specify host:port to wait for"
    exit 1
fi

# Start waiting for the service to be available
echo "Waiting for $HOST:$PORT..."

# Loop until we can connect to the specified host and port
START_TIME=$(date +%s)
while true; do
    # Attempt to connect
    nc -z $HOST $PORT > /dev/null 2>&1
    RESULT=$?

    if [[ $RESULT -eq 0 ]]; then
        if [[ $QUIET -eq 0 ]]; then
            echo "$HOST:$PORT is available!"
        fi
        break
    fi

    # Check timeout
    END_TIME=$(date +%s)
    DIFF=$((END_TIME - START_TIME))
    if [[ $DIFF -gt $TIMEOUT ]]; then
        echo "Timeout of $TIMEOUT seconds reached. $HOST:$PORT is still not available."
        exit 1
    fi

    # Wait for a bit before retrying
    sleep $WAIT_INTERVAL
done

# Execute the command if provided
if [[ -n $CMD ]]; then
    exec $CMD
fi
