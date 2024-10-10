#!/bin/bash

quit_setup() {
    echo "Aborting setup"
    exit 0
}

cd docker


# Quick check for app config (run time variables are all authentication related, not app parameters)
if [ ! -f "app_config.env" ]; then
    echo "app_config.env is not found, we need it to for configure the fast probing application"
    quit_setup
fi

# Two ways to setup: 1. .env (if authentication is provid) 2. run-time variables
# If .env is missing, user will be prompted to input run-time variables
if [ ! -f "auth.env" ]; then
    echo "auth.env file is not found, we need it to connect to database"
    read -p "Do you want to continue with runtime variables? (y/n or q to quit): " USE_RUNTIME_VARS
    if [ "$USE_RUNTIME_VARS" == "q" ] || [ "$USE_RUNTIME_VARS" == "n" ]; then
        quit_setup
    fi
else
    read -p "Do you want to use the .env file for environment variables? You will be prompt for runtime variable if not (y/n or q to quit): " USE_ENV_FILE
    if [ "$USE_ENV_FILE" == "q" ]; then
        quit_setup
    elif [ "$USE_ENV_FILE" == "n" ]; then
        USE_RUNTIME_VARS="y"
    else
        USE_RUNTIME_VARS="n"
    fi
fi



if [ "$USE_RUNTIME_VARS" == "y" ]; then
    echo "Entering runtime variables..."

    # Essential info: locaitons, username, passwords, and uuid
    read -p "Enter remote storage locations, seperated by ',' (or type 'q' to quit): " REMOTE_STORAGES
    if [ "$REMOTE_STORAGES" == "q" ]; then
        quit_setup
    fi
    read -p "Enter remote storage usernames, seperated by ',' (or type 'q' to quit): " REMOTE_STORAGE_USERS
    if [ "$REMOTE_STORAGE_USERS" == "q" ]; then
        quit_setup
    fi
    read -s -p "Enter remote storage passwords, seperated by ',' (or type 'q' to quit): " REMOTE_STORAGE_PASSWORDS
    echo
    if [ "$REMOTE_STORAGE_PASSWORDS" == "q" ]; then
        quit_setup
    fi
    read -p "Enter UUID (or type 'q' to quit): " UUID
    if [ "$UUID" == "q" ]; then
        quit_setup
    fi

    export REMOTE_STORAGES
    export REMOTE_STORAGE_USERS
    export REMOTE_STORAGE_PASSWORDS
    export UUID

    # run time variable collected, use it to initialize container
    echo "run time variable collected, setting up..."
    docker-compose --env-file app_config.env up --build -d \
        -e REMOTE_STORAGES="$REMOTE_STORAGES" \
        -e REMOTE_STORAGE_USERS="$REMOTE_STORAGE_USERS" \
        -e REMOTE_STORAGE_PASSWORDS="$REMOTE_STORAGE_PASSWORDS" \
        -e UUID="$UUID"

else
    # .env exists, use it directly to initialize container
    echo ".env detected, setting up..."
    docker-compose --env-file app_config.env --env-file auth.env up --build -d
fi


echo "container is built"