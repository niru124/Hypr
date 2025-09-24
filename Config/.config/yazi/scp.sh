#!/bin/bash

REMOTE_USER="u0_a361"
REMOTE_HOST="192.168.29.146"
REMOTE_PORT="8022"
REMOTE_BASE_PATH="/data/data/com.termux/files/home/storage"

FILE_PATH="$1"
FILE_NAME=$(basename "$FILE_PATH")

LOCAL_DEST="$HOME/Downloads/uncle"

scp -P "$REMOTE_PORT" -r "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE_PATH}/${FILE_NAME}" "$LOCAL_DEST"
